#!/usr/bin/env bash
# Releases the version named by the first "## X.Y.Z" heading of
# CHANGELOG.md, unless it is out already: pushes an annotated tag vX.Y.Z
# on the checked-out commit and creates a GitHub release whose notes are
# that changelog section. Each half is skipped when it exists, so a tag
# pushed by hand still gets its release.
#
# Needs git with push rights on the remote and the gh CLI (GH_TOKEN).
# REMOTE names the git remote or URL (default origin); DRY_RUN=1 prints
# what it would do and changes nothing.
set -euo pipefail

version=$(grep -m1 -oE '^## [0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | cut -d' ' -f2 || true)
if [ -z "$version" ]; then
  echo "CHANGELOG.md has no '## X.Y.Z' heading" >&2
  exit 1
fi
tag="v$version"
remote="${REMOTE:-origin}"

notes=$(mktemp)
awk -v heading="## $version" '
  $0 == heading || index($0, heading " ") == 1 { on = 1; next }
  /^## / { on = 0 }
  on
' CHANGELOG.md > "$notes"

run() { if [ -n "${DRY_RUN:-}" ]; then echo "would run: $*"; else "$@"; fi; }

# ls-remote exits 2 when the tag isn't there; anything else is a failure
# to reach the remote, which must not be read as "not released".
rc=0
git ls-remote --exit-code --tags "$remote" "refs/tags/$tag" > /dev/null || rc=$?
if [ "$rc" -eq 0 ]; then
  echo "tag $tag exists"
elif [ "$rc" -ne 2 ]; then
  echo "could not read tags from $remote" >&2
  exit "$rc"
else
  echo "tagging $(git rev-parse --short HEAD) as $tag"
  run git -c user.name="github-actions[bot]" \
    -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
    tag -a "$tag" -m "Release $tag"
  run git push "$remote" "$tag"
fi

if [ -z "${DRY_RUN:-}" ] && gh release view "$tag" > /dev/null 2>&1; then
  echo "release $tag exists"
else
  echo "releasing $tag with notes:"
  cat "$notes"
  run gh release create "$tag" --verify-tag --title "$tag" --notes-file "$notes"
fi
