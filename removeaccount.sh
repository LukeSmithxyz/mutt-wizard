#!/bin/sh
muttdir="$HOME/Repos/email-mutt-offline/"

# This script will remove an account from ~/.offlineimaprc and the
# designated location in ~/.config/mutt/accounts.

# Feed the script the title of the account.

title=$1

removeAccount() { sed -ie "
	/Account $title]/,/Account/{//!d}
	/Account $title]/d
	s/ $title\(,\|$\)//g
	s/=$title\(,\|$\)/=/g
	s/,$//g
	" ~/.offlineimaprc
	rm "$muttdir"accounts/$title.muttrc
	echo $title deleted. ;}
removeAccount $title
