#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq unzip gnused gnugrep nix
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_nix="$root/default.nix"
apt_packages_url="https://www.synaptics.com/sites/default/files/Ubuntu/dists/stable/non-free/binary-amd64/Packages"

# The Synaptics download page is versioned per Ubuntu release (e.g.
# .../displaylink-usb-graphics-software-ubuntu-64) and doesn't itself say
# what the latest driver is, so use their APT repo's package index as the
# source of truth for the current version instead.
packages="$(curl -fsSL "$apt_packages_url")"
version="$(grep -A2 '^Package: displaylink-driver$' <<<"$packages" | grep '^Version: ' | sed -E 's/^Version: //' | sort -V | tail -n1)"
if [[ -z "$version" ]]; then
  echo "displaylink update: could not find displaylink-driver in $apt_packages_url" >&2
  exit 1
fi

current_version="$(grep -oE 'version = "[^"]+";' "$default_nix" | sed -E 's/version = "(.*)";/\1/')"
if [[ "$version" == "$current_version" ]]; then
  echo "displaylink: already up to date ($version)"
  exit 0
fi

page_ver="$(cut -d. -f1,2 <<<"$version" | tr -d '.')"
page_url="https://www.synaptics.com/products/displaylink-usb-graphics-software-ubuntu-${page_ver}"

html="$(curl -fsSL "$page_url")"

rel_url="$(grep -oE '/sites/default/files/exe_files/[^"]+\.zip' <<<"$html" | head -n1)"
if [[ -z "$rel_url" ]]; then
  echo "displaylink update: could not find a download link on $page_url" >&2
  exit 1
fi
url="https://www.synaptics.com${rel_url}"

echo "displaylink: fetching $url" >&2
prefetch_json="$(nix store prefetch-file --name displaylink.zip --json "$url")"
hash="$(jq -r '.hash' <<<"$prefetch_json")"
store_path="$(jq -r '.storePath' <<<"$prefetch_json")"

run_file="$(unzip -Z1 "$store_path" | grep -E 'displaylink-driver-.*\.run$' | head -n1)"
if [[ -z "$run_file" ]]; then
  echo "displaylink update: could not find displaylink-driver-*.run inside $url" >&2
  exit 1
fi
zip_version="${run_file##*/}"
zip_version="${zip_version#displaylink-driver-}"
zip_version="${zip_version%.run}"
if [[ "$zip_version" != "$version" ]]; then
  echo "displaylink update: apt repo reports $version but $url contains $zip_version" >&2
  exit 1
fi

sed -i \
  -e "s|version = \"[^\"]*\";|version = \"${version}\";|" \
  -e "s|url = \"[^\"]*\";|url = \"${url}\";|" \
  -e "s|hash = \"[^\"]*\";|hash = \"${hash}\";|" \
  "$default_nix"

echo "displaylink: updated to ${version} (${url})"
