#!/usr/bin/env sh

mydir="$(dirname "$0")"

export MOZ_ALLOW_DOWNGRADE=1
export MOZ_LEGACY_PROFILES=1

exec "$mydir"/betterbird-bin
