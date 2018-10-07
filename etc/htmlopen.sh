#!/bin/sh

# Helps open an HTML file from mutt in a GUI browser without weird side effects.

file=$(mktemp -u --suffix=.html)

echo $file
cp "$1" "$file"

setsid firefox "$file" &
