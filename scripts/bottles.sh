#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: bottles.sh <version> <binaries folder>" >&2
  exit 2
fi

version="$1"
binaries="$(cd "$2" && pwd)"

declare -A bottle_tags=(
  [darwin-arm64]=arm64_ventura
  [darwin-x64]=ventura
  [linux-x64]=x86_64_linux
)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

for target in "${!bottle_tags[@]}"; do
  tag="${bottle_tags[$target]}"
  keg="${work}/${target}/vms/${version}"

  mkdir -p "${keg}/bin"
  cp "${binaries}/vms-${target}" "${keg}/bin/vms"
  chmod 755 "${keg}/bin/vms"
  tar --create --gzip --owner=0 --group=0 --numeric-owner \
    --file "${binaries}/vms-${version}.${tag}.bottle.tar.gz" \
    --directory "${work}/${target}" vms
done
