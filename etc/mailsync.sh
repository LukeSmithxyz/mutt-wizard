#!/bin/sh
# This script will run offlineimap and check
# for new email if there is an internet connection.
#
# If it detects new mail, it uses mpv to play a
# notification sound: notify.opus
#
# I have this run as a cronjob every 5 minutes.

# Check for internet connection. Exit script if none. (timeout in mac is `-t`)
if [ "$(uname)" == "Darwin" ]
then
	ping -q -t 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` >/dev/null || exit
else
	ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` >/dev/null || exit
fi

# Get current number of new mail, then begin sync.
ori=$(find ~/.mail -wholename '*/new/*' | grep -vi "spam\|trash\|junk" | wc -l)
offlineimap -o "$@"

# Recount new mail.
new=$(find ~/.mail -wholename '*/new/*' | grep -vi "spam\|trash\|junk" | wc -l)

# If new mail has grown, play a notification.
if [ "$new" -gt "$ori" ]; then
	mpv --quiet ~/.config/mutt/etc/notify.opus
fi
