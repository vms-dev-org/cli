#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { accessSync, chmodSync, constants } from "node:fs";
import { createRequire } from "node:module";

const PLATFORM_PACKAGES = {
  "darwin-arm64": "@vms.dev/cli-darwin-arm64",
  "darwin-x64": "@vms.dev/cli-darwin-x64",
  "linux-x64": "@vms.dev/cli-linux-x64",
};

function fail(message) {
  process.stderr.write(`error: ${message}\n`);
  process.exit(1);
}

function binaryOf(packageName) {
  try {
    return createRequire(import.meta.url).resolve(`${packageName}/bin/vms`);
  } catch {
    return null;
  }
}

function makeExecutable(binary) {
  try {
    accessSync(binary, constants.X_OK);
  } catch {
    chmodSync(binary, 0o755);
  }
}

const platform = `${process.platform}-${process.arch}`;
const packageName = PLATFORM_PACKAGES[platform];

if (!packageName) {
  fail(
    `vms has no binary for ${platform}. Use macOS or Linux on x86-64, or macOS on Apple silicon.`,
  );
}

const binary = binaryOf(packageName);

if (!binary) {
  fail(
    `${packageName} is not installed. Install @vms.dev/cli again, with its optional dependencies.`,
  );
}

makeExecutable(binary);

const result = spawnSync(binary, process.argv.slice(2), { stdio: "inherit" });

if (result.error) fail(result.error.message);

if (result.signal) process.kill(process.pid, result.signal);

process.exit(result.status ?? 1);
