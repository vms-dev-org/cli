#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: formula.sh <version> <SHA256SUMS file>" >&2
  exit 2
fi

version="$1"
sums="$2"
base_url="https://github.com/vms-dev-org/cli/releases/download/v${version}"

sum_of() {
  local file="$1"
  local sum
  sum="$(awk -v file="$file" '$2 == file || $2 == "*" file { print $1 }' "$sums")"

  if [[ ! "$sum" =~ ^[0-9a-f]{64}$ ]]; then
    echo "error: ${sums} has no SHA-256 sum for ${file}." >&2
    exit 1
  fi

  echo "$sum"
}

darwin_arm64="$(sum_of vms-darwin-arm64)"
darwin_x64="$(sum_of vms-darwin-x64)"
linux_x64="$(sum_of vms-linux-x64)"
bottle_darwin_arm64="$(sum_of "vms-${version}.arm64_ventura.bottle.tar.gz")"
bottle_darwin_x64="$(sum_of "vms-${version}.ventura.bottle.tar.gz")"
bottle_linux_x64="$(sum_of "vms-${version}.x86_64_linux.bottle.tar.gz")"

cat <<FORMULA
class Vms < Formula
  desc "Create and use vms.dev sandboxes from your terminal"
  homepage "https://vms.dev/docs/reference/cli"
  version "${version}"
  license "MIT"

  bottle do
    root_url "${base_url}"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "${bottle_darwin_arm64}"
    sha256 cellar: :any_skip_relocation, ventura:       "${bottle_darwin_x64}"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "${bottle_linux_x64}"
  end

  on_macos do
    on_arm do
      url "${base_url}/vms-darwin-arm64"
      sha256 "${darwin_arm64}"
    end

    on_intel do
      url "${base_url}/vms-darwin-x64"
      sha256 "${darwin_x64}"
    end
  end

  on_linux do
    on_intel do
      url "${base_url}/vms-linux-x64"
      sha256 "${linux_x64}"
    end
  end

  def install
    bin.install Dir["vms-*"].first => "vms"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/vms --version").strip
  end
end
FORMULA
