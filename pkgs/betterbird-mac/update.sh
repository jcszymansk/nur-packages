#!/usr/bin/env bash

major=115

tmpfile=$(mktemp -p .)

curl -s -o $tmpfile https://www.betterbird.eu/downloads/sha256-"$major".txt || exit 1

sha=$(grep mac.dmg $tmpfile | head -1 | cut -d' ' -f1)
fileraw=$(grep mac.dmg $tmpfile | head -1 | cut -d' ' -f2)

version=$(echo $fileraw | sed -e 's/^\*betterbird-//' -e 's/\.en-US\.mac\.dmg//g')
file=$(echo $fileraw | sed -e 's/^\*//')

rm -f $tmpfile

cat > betterbird.json <<__EOF
{
  "url": "https://www.betterbird.eu/downloads/MacDiskImage/$file",
  "sha256": "$sha",
  "version": "$version"
}
__EOF
