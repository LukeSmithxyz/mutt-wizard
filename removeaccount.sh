#!/bin/sh
muttdir="$HOME/.config/mutt/"

# This script will remove an account from ~/.offlineimaprc and the
# designated location in ~/.config/mutt/accounts.

# Feed the script the title of the account.

cat ~/.offlineimaprc | grep "^accounts =" | sed -e 's/accounts =\( \)//g;s/\(,\) /\n/g;' | nl --number-format=ln > /tmp/numbered

removeAccount() { sed -ie "
	/Account $1]/,/Account/{//!d}
	/Account $1]/d
	s/ $1\(,\|$\)//g
	s/=$1\(,\|$\)/=/g
	s/,$//g
	" ~/.offlineimaprc
	rm "$muttdir"accounts/$1.muttrc
	rm "$muttdir"credentials/$1.gpg
	echo $1 deleted. ;}

#/tmp/numbered

accounts=()
while read n s ; do
	accounts+=($n "$s" off)
done < /tmp/numbered

choices=$(dialog --separate-output --checklist "Choose an email account to remove." 22 76 16 "${accounts[@]}" 2>&1 >/dev/tty)
clear

if [ -z "$choices" ];
	then
		echo no selection
	else
		todelet=$(IFS="|"; keys="${choices[*]}"; keys="${keys//|/\\|}"; grep -w "${keys}" /tmp/numbered  | awk '{print $2}')
		for i in $todelet; do removeAccount $i; done
fi



