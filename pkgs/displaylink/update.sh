#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq unzip gnused gnugrep nix
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_nix="$root/default.nix"
page_url="https://www.synaptics.com/products/displaylink-usb-graphics-software-ubuntu-62"

html="$(curl -fsSL "$page_url")"

rel_url="$(grep -oE '/sites/default/files/exe_files/[^"]+\.zip' <<<"$html" | head -n1)"
if [[ -z "$rel_url" ]]; then
  echo "displaylink update: could not find a download link on $page_url" >&2
  exit 1
fi
url="https://www.synaptics.com${rel_url}"

current_url="$(grep -oE 'url = "[^"]+";' "$default_nix" | sed -E 's/url = "(.*)";/\1/')"
if [[ "$url" == "$current_url" ]]; then
  echo "displaylink: already up to date ($url)"
  exit 0
fi

echo "displaylink: fetching $url" >&2
prefetch_json="$(nix store prefetch-file --name displaylink.zip --json "$url")"
hash="$(jq -r '.hash' <<<"$prefetch_json")"
store_path="$(jq -r '.storePath' <<<"$prefetch_json")"

run_file="$(unzip -Z1 "$store_path" | grep -E '^displaylink-driver-.*\.run$' | head -n1)"
if [[ -z "$run_file" ]]; then
  echo "displaylink update: could not find displaylink-driver-*.run inside $url" >&2
  exit 1
fi
version="${run_file#displaylink-driver-}"
version="${version%.run}"

sed -i \
  -e "s|version = \"[^\"]*\";|version = \"${version}\";|" \
  -e "s|url = \"[^\"]*\";|url = \"${url}\";|" \
  -e "s|hash = \"[^\"]*\";|hash = \"${hash}\";|" \
  "$default_nix"

echo "displaylink: updated to ${version} (${url})"
