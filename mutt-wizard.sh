#!/bin/bash

muttdir="$HOME/.config/mutt/"

# Sees what accounts have been generated bny the wizard
# by checking ~/.offlineimap and yields a menu of them.
inventory() { \
	cat ~/.offlineimaprc | grep "^accounts =" | sed -e 's/accounts =\( \)//g;s/\(,\) /\n/g;' | nl --number-format=ln > /tmp/numbered
	accounts=()
	while read n s ; do
		accounts+=($n "$s" off)
	done < /tmp/numbered

	choices=$(dialog --separate-output --checklist "Choose an email account." 22 76 16 "${accounts[@]}" 2>&1 >/dev/tty)

	if [ -z "$choices" ];
		then
			clear
		else
		userchoices=$(IFS="|"; keys="${choices[*]}"; keys="${keys//|/\\|}"; grep -w "${keys}" /tmp/numbered  | awk '{print $2}')
	fi ;}


removeAccount() { sed -ie "
	/Account $1]/,/Account/{//!d}
	/Account $1]/d
	s/ $1\(,\|$\)//g
	s/=$1\(,\|$\)/=/g
	s/,$//g
	" ~/.offlineimaprc
	rm "$muttdir"accounts/$1.muttrc
	rm "$muttdir"credentials/$1.gpg
	rm -rf "$muttdir"accounts/$1
	echo $1 deleted. ;}

manual() { \
	imap=$( dialog --inputbox "Insert the IMAP server for your email provider (excluding the port number)" 10 60 3>&1 1>&2 2>&3 3>&- )
	iport=$(dialog --inputbox "What is your server's IMAP port number? (Usually 993)" 10 60 3>&1 1>&2 2>&3 3>&-)
	smtpserver=$( dialog --inputbox "Insert the SMTP server for your email provider (excluding the port number)" 10 60 3>&1 1>&2 2>&3 3>&- )
	sport=$( dialog --inputbox "What is your server's SMTP port number? (Usually 587 or 465)" 10 60 3>&1 1>&2 2>&3 3>&- ) ;}


addloop() { fulladdr=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Insert the full email address for the account you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
# Check to see if domain is in domain list
serverinfo=$(cat "$muttdir"autoconf/domains.csv | grep -w ^${fulladdr##*@})
if [ -z "$serverinfo" ];
	then
		manual
	else
# Read in server data as variables
IFS=, read service imap iport smtp sport spoolfile postponed record <<EOF
$serverinfo
EOF
fi
realname=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Enter the full name you'd like to be identified by on this email account." 10 60 3>&1 1>&2 2>&3 3>&- )
title=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Give a short, one-word name for this email account that will differentiate it from other email accounts." 10 60 3>&1 1>&2 2>&3 3>&- )
# Sets the repo type and other variables for the sed regex.
if [[ "$service" == "gmail.com" ]];
	then
		type="Gmail"
		delet="remotehost"
	else
		type="IMAP"
		delet="Gmail]\/"
fi
# The replacements
replacement="
	s/\$realname/$realname/g;
	s/\$title/$title/g;
	s/\$fulladdr/$fulladdr/g;
	s/\$imap/$imap/g;
	s/\$iport/$iport/g;
	s/\$smtp/$smtp/g;
	s/\$sport/$sport/g;
	s/\$spoolfile/$spoolfile/g;
	s/\$postponed/$postponed/g;
	s/\$record/$record/g;
	s/\$type/$type/g;
	/$delet/d"

# Gets the first unused shortcut number in the muttrc and puts it in $idnum.
cat "$muttdir"personal.muttrc | grep i[0-9] | awk '{print $3}' | sed -e 's/i//g' > /tmp/mutt_used
echo -e "1\n2\n3\n4\n5\n6\n7\n8\n9" > /tmp/mutt_all_possible
idnum=$(diff /tmp/mutt_all_possible /tmp/mutt_used | sed -n 2p | awk '{print $2}')
addAccount \
;}

addAccount() {
	# First, adding the encrypted password.
	dialog --title "Luke's mutt/offlineIMAP password wizard" --passwordbox "Enter the password for the \"$title\" account." 10 60 2> /tmp/$title
	gpg -r $gpgemail --encrypt /tmp/$title
	shred -u /tmp/$title
	mv /tmp/$title.gpg ~/.config/mutt/credentials/

	# Creating the offlineimaprc if it doesn't exist already.
	if [ ! -f ~/.offlineimaprc ]; then cp "$muttdir"autoconf/offlineimap_header ~/.offlineimaprc; fi
	cat "$muttdir"autoconf/offlineimap_profile | sed -e "$replacement" >> ~/.offlineimaprc

	# Add the mutt profile.
	cat "$muttdir"autoconf/mutt_profile | sed -e "$replacement" > "$muttdir"accounts/$title.muttrc
	# Add a numbered shortcut in the muttrc
	echo "macro index,pager i$idnum '<sync-mailbox><enter-command>source "$muttdir"accounts/$title.muttrc<enter><change-folder>!<enter>'" >> "$muttdir"personal.muttrc

	# Adding directory structure for cache.
	mkdir -p "$muttdir"accounts/$title/cache/bodies

	# Add to offlineimaprc sync list.
	sed -i "s/^accounts =.*[a-zA-Z]$/&, $title/g;s/^accounts =$/accounts = $title/g" ~/.offlineimaprc

	# Makes account default if there is no default account.
	grep "$muttdir"personal.muttrc -e "^source .*accounts.*" >/dev/null && echo there || \
	echo "source ${muttdir}accounts/$title.muttrc" >> "$muttdir"personal.muttrc ;}

# This is run when a user chooses to add an account.
addChosen() { \
	mkdir -p "$muttdir"credentials/ "$muttdir"accounts/
	gpgemail=$( dialog --title "Luke's mutt/offlineIMAP password wizard" --inputbox "Insert the email address with which you originally created your GPG key pair. This is NOT necessarily the email you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
	addloop
	while : ;
	do
		dialog --title "Luke's mutt/offlineIMAP password wizard" --yesno "Would you like to add another email account?" 10 60 || break
		addloop
	done ;}

wipe () { rm $HOME/.offlineimaprc
	rm -rf "$muttdir"/accounts
	rm -f "$muttdir"credentials/*gpg
	rm "$muttdir"personal.muttrc ;}



while : ;
	do
choice=$(dialog --title "Luke's mutt/offlineIMAP wizard" \
	--menu "What would you like to do?" 14 45 5 \
	0 "List all email accounts configured." \
	1 "Add an email account." \
	2 "Remove an email account." \
	3 "Remove all email accounts." \
	4 "Exit this wizard." \
	 3>&1 1>&2 2>&3 3>&1 )


case $choice in
0) dialog --title "Accounts detected" --msgbox "The following accounts have been detected:
$(grep ~/.offlineimaprc -e "^accounts =" | sed 's/accounts =//g')
" 6 60;;
1) addChosen;;
2) inventory && for i in $userchoices; do removeAccount $i ; done;;
3) (dialog --defaultno --title "Wipe all custom neomutt/offlineIMAP settings?" --yesno "Would you like to wipe all of the mutt/offlineIMAP settings generated by the system?" 6 60 && wipe) ;;
4) clear && break
esac
done
