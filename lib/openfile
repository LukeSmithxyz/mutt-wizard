#!/bin/sh

# Helps open a file with xdg-open from mutt in a external program without weird side effects.
tempdir="${XDG_CACHE_HOME:-$HOME/.cache}/mutt-wizard/files"
file="$tempdir/${1##*/}"
[ "$(uname)" = "Darwin" ] && opener="open" || opener="setsid -f xdg-open"
mkdir -p "$tempdir"
cp -f "$1" "$file"
$opener "$file" >/dev/null 2>&1
find "${tempdir:?}" -mtime +1 -type f -delete
