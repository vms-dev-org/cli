#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: npm-packages.sh <version> <binaries folder> <output folder>" >&2
  exit 2
fi

version="$1"
binaries="$2"
output="$3"
repository_root="$(cd "$(dirname "$0")/.." && pwd)"

targets=(darwin-arm64 darwin-x64 linux-x64)

rm -rf "$output"
mkdir -p "$output"

for target in "${targets[@]}"; do
  os="${target%-*}"
  cpu="${target#*-}"
  folder="${output}/cli-${target}"

  mkdir -p "${folder}/bin"
  cp "${binaries}/vms-${target}" "${folder}/bin/vms"
  chmod 755 "${folder}/bin/vms"
  cp "${repository_root}/LICENSE" "${folder}/LICENSE"
  printf '# @vms.dev/cli-%s\n\nThe `vms` binary for %s. Install `@vms.dev/cli`, not this package.\n' \
    "$target" "$target" >"${folder}/README.md"

  jq -n \
    --arg name "@vms.dev/cli-${target}" \
    --arg version "$version" \
    --arg description "The vms binary for ${target}." \
    --arg os "$os" \
    --arg cpu "$cpu" \
    '{
      name: $name,
      version: $version,
      description: $description,
      license: "MIT",
      homepage: "https://vms.dev/docs/reference/cli",
      repository: { type: "git", url: "git+https://github.com/vms-dev-org/cli.git" },
      os: [$os],
      cpu: [$cpu],
      files: ["bin/vms"],
      preferUnplugged: true
    }' >"${folder}/package.json"
done

launcher="${output}/cli"

mkdir -p "${launcher}/bin"
cp "${repository_root}/npm/vms.mjs" "${launcher}/bin/vms.mjs"
chmod 755 "${launcher}/bin/vms.mjs"
cp "${repository_root}/LICENSE" "${launcher}/LICENSE"
cp "${repository_root}/README.md" "${launcher}/README.md"

jq -n \
  --arg version "$version" \
  '{
    name: "@vms.dev/cli",
    version: $version,
    description: "Create and use vms.dev sandboxes from your terminal.",
    license: "MIT",
    homepage: "https://vms.dev/docs/reference/cli",
    repository: { type: "git", url: "git+https://github.com/vms-dev-org/cli.git" },
    keywords: ["vms", "sandbox", "cli"],
    type: "module",
    bin: { vms: "bin/vms.mjs" },
    files: ["bin/vms.mjs"],
    engines: { node: ">=18" },
    optionalDependencies: {
      "@vms.dev/cli-darwin-arm64": $version,
      "@vms.dev/cli-darwin-x64": $version,
      "@vms.dev/cli-linux-x64": $version
    }
  }' >"${launcher}/package.json"
