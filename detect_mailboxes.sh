#!/bin/sh
muttdir="$HOME/.config/mutt/"

find ~/.mail/$1 -maxdepth 1 -mindepth 1 -type d | sed -e "s/.*\///g;s/^/=/g" > /tmp/$1_boxes
oneline=$(cat /tmp/$1_boxes | tr "\n" " ")
sed -i "/^mailboxes/d" "$muttdir"accounts/$1.muttrc
echo mailboxes $oneline >> "$muttdir"accounts/$1.muttrc

formatShortcut() { \
	while read data; do
	echo "macro index,pager g$1 \"<change-folder>$data<enter>\" \"Go to $2.\"" >> "$muttdir"accounts/$3.muttrc
	done ;}

sed -i "/^macro index,pager g/d" "$muttdir"accounts/$1.muttrc

grep -vi /tmp/$1_boxes -e "trash\|drafts\|sent\|trash\|spam\|junk\|archive" | sort -n | sed 1q | formatShortcut i inbox $1
grep -i /tmp/$1_boxes -e sent | formatShortcut s sent $1
grep -i /tmp/$1_boxes -e trash | formatShortcut t trash $1
grep -i /tmp/$1_boxes -e spam | formatShortcut S spam $1
grep -i /tmp/$1_boxes -e draft | formatShortcut d drafts $1
grep -i /tmp/$1_boxes -e archive | formatShortcut a archive $1

