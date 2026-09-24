#!/usr/bin/env bash
# Copies the latest release of an upstream packaging repo into this one.
#
#   mirror.sh <name> <owner/repo> [<rename-sed>]
#
# Two releases per package end up here:
#   <name>-<tag>  a frozen copy of that upstream release, kept forever, so a bad or
#                 deleted upstream build never takes the last good one with it;
#   <name>        a rolling release with version-free file names, which LimCore
#                 downloads from: releases/download/<name>/<file>. Its title is the
#                 upstream tag it currently holds, and is only set once every file is
#                 uploaded, so a run that dies half-way is simply redone next time.
#
# Files are copied byte for byte, so upstream signatures stay valid.
set -euo pipefail

name=$1
src=$2
rename=${3:-}
repo=${GITHUB_REPOSITORY:?}

tag=$(gh api "repos/$src/releases/latest" --jq .tag_name)
[ -n "$tag" ] || { echo "no release in $src"; exit 1; }

current=$(gh release view "$name" -R "$repo" --json name --jq .name 2>/dev/null || true)
if [ "$current" = "$tag" ]; then
	echo "$name: already at $tag"
	exit 0
fi
echo "$name: ${current:-none} -> $tag"

work=$(mktemp -d)
gh release download "$tag" -R "$src" -D "$work/orig"
n=$(find "$work/orig" -type f | wc -l)
[ "$n" -gt 0 ] || { echo "$name: upstream release $tag has no files"; exit 1; }

notes="Copy of https://github.com/$src/releases/tag/$tag"

if ! gh release view "$name-$tag" -R "$repo" >/dev/null 2>&1; then
	gh release create "$name-$tag" -R "$repo" --title "$name $tag" --notes "$notes" \
		--latest=false "$work"/orig/*
fi

mkdir "$work/roll"
for f in "$work"/orig/*; do
	b=$(basename "$f")
	[ -n "$rename" ] && b=$(printf '%s' "$b" | sed -E "$rename")
	cp "$f" "$work/roll/$b"
done

if ! gh release view "$name" -R "$repo" >/dev/null 2>&1; then
	gh release create "$name" -R "$repo" --title "uploading" --notes "$notes" --latest=false
fi
gh release upload "$name" -R "$repo" --clobber "$work"/roll/*

# Drop files upstream no longer ships (a retired architecture, say).
gh release view "$name" -R "$repo" --json assets --jq '.assets[].name' | while read -r a; do
	[ -e "$work/roll/$a" ] || gh release delete-asset "$name" "$a" -R "$repo" --yes
done

gh release edit "$name" -R "$repo" --title "$tag" --notes "$notes"
echo "$name: now at $tag ($n files)"
