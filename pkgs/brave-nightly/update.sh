#!/usr/bin/env bash
set -euo pipefail

repo="brave/brave-browser"
api_url="https://api.github.com/repos/${repo}/releases?per_page=20"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
release_file="${script_dir}/latest-linux-x64.json"

for dependency in curl jq nix; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    echo "missing required dependency: $dependency" >&2
    exit 1
  fi
done

if [ ! -f "$release_file" ]; then
  echo "release data file not found: $release_file" >&2
  exit 1
fi

curl_args=(-fsSL)
if [ -n "${GITHUB_TOKEN:-}" ]; then
  curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

release_json=$(curl "${curl_args[@]}" "$api_url")
if ! asset_json=$(jq -cer '
  [
    .[]
    | select(.draft == false)
    | select(.prerelease == true)
    | . as $release
    | $release.assets[]
    | select(.name | test("^brave-browser-nightly_[0-9]+\\.[0-9]+\\.[0-9]+_amd64\\.deb$"))
    | {
        version: ($release.tag_name | sub("^v"; "")),
        url: .browser_download_url,
        digest: .digest
      }
  ][0]
' <<<"$release_json"); then
  echo "could not find a linux amd64 Brave nightly release asset" >&2
  exit 1
fi

version=$(jq -r '.version' <<<"$asset_json")
url=$(jq -r '.url' <<<"$asset_json")
digest=$(jq -r '.digest' <<<"$asset_json")

if [[ ! "$digest" =~ ^sha256:[0-9a-fA-F]{64}$ ]]; then
  echo "release asset does not expose a usable sha256 digest: $digest" >&2
  exit 1
fi

hash_hex=${digest#sha256:}
hash=$(nix hash convert --hash-algo sha256 --to sri "$hash_hex")

current_version=$(jq -r '.version' "$release_file")
current_url=$(jq -r '.url' "$release_file")
current_hash=$(jq -r '.sha256' "$release_file")

if [ "$current_version" = "$version" ] && [ "$current_url" = "$url" ] && [ "$current_hash" = "$hash" ]; then
  echo "brave-nightly is already up to date: $version"
  exit 0
fi

tmpfile=$(mktemp "${release_file}.XXXXXX")
trap 'rm -f "$tmpfile"' EXIT

jq -n \
  --arg version "$version" \
  --arg url "$url" \
  --arg sha256 "$hash" \
  '{
    version: $version,
    url: $url,
    sha256: $sha256
  }' >"$tmpfile"

mv "$tmpfile" "$release_file"
trap - EXIT

echo "updated brave-nightly to $version"
