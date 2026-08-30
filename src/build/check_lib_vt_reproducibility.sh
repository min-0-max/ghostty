#!/bin/sh
# Compare libghostty-vt archives produced from the same commit in two clean roots.
set -eu

[ "$#" -eq 2 ] && [ -n "$1" ] && [ -n "$2" ] || {
  echo 'usage: check_lib_vt_reproducibility.sh <left.a> <right.a>' >&2
  exit 2
}

left=$1
right=$2
for archive in "$left" "$right"; do
  [ -f "$archive" ] && [ ! -L "$archive" ] || {
    echo "libghostty-vt reproducibility input is not a regular archive: $archive" >&2
    exit 2
  }
done

if ! cmp -s "$left" "$right"; then
  left_size=$(wc -c < "$left" | tr -d ' ')
  right_size=$(wc -c < "$right" | tr -d ' ')
  left_sha=$(shasum -a 256 "$left" | awk '{print $1}')
  right_sha=$(shasum -a 256 "$right" | awk '{print $1}')
  printf 'LIBGHOSTTY_VT_CROSS_ROOT_MISMATCH left_size=%s left_sha256=%s right_size=%s right_sha256=%s\n' \
    "$left_size" "$left_sha" "$right_size" "$right_sha" >&2
  exit 1
fi

sha=$(shasum -a 256 "$left" | awk '{print $1}')
printf 'LIBGHOSTTY_VT_CROSS_ROOT_REPRODUCIBLE sha256=%s\n' "$sha"
