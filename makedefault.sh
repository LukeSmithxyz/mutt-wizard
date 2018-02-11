#!/bin/bash

# Give this script the abstract name of an account and it will make it the default.

title=$1
muttdir="$HOME/.config/mutt/"
muttdirsed=$(echo $muttdir | sed -e 's/\//\\\//g')

grep "$muttdir"personal.muttrc -e "^source .*accounts.*" >/dev/null && \
	sed -i "s/^source .*accounts.*/source ${muttdirsed}accounts\/$title.muttrc/g" "$muttdir"personal.muttrc
