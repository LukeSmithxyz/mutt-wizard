#!/bin/bash

muttdir="$HOME/.config/mutt/"

changePassword() { \
	gpgemail=$( dialog --title "Luke's mutt/offlineIMAP password wizard" --inputbox "Insert the email address with which you originally created your GPG key pair. This is NOT necessarily the email you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
	dialog --title "Luke's mutt/offlineIMAP password wizard" --passwordbox "Enter the new password for the \"$1\" account." 10 60 2> /tmp/$1
	gpg2 -r $gpgemail --encrypt /tmp/$1 || (dialog --title "GPG decryption failed." --msgbox "GPG decryption failed. This is either because you do not have a GPG key pair or because your distro uses GPG1 and you thus need to symlink /usr/bin/gpg2 to /usr/bin/gpg." 7 60 && break)
	shred -u /tmp/$1
	mv /tmp/$1.gpg ~/.config/mutt/credentials/ ;}

chooseDetect() { for x in $(cat ~/.offlineimaprc | grep "^accounts =" | sed -e 's/accounts =\( \)//g;s/\(,\) /\n/g;'); do detectMailboxes $x; done && detectSuccess ;}

detectWarning() { \
	dialog --title "Mailbox detect requirement" --yesno "In order for the mailbox detection system to work, you must have

1) already have added the email account with this wizard, and
2) already have run offlineimap at least once to synchronize your mail.

This detection system only works if you already have begun your first sync. If you have, press 'yes' to continue." 12 70 ;}

detectSuccess() { dialog --title "Mailbox detect complete." --msgbox "The script has now smartly detected your different mailboxes and has enabled them in the sidebar and given you keyboard shortcuts as below:

gi for move to the Inbox.
gs for move to Sent Mail.
gd for move to Drafts
gS for move to Spam
ga for move to the Archive.
gj for move to Junk
gt for move to Trash

These shortcuts will only work if your email system does have that particular folder (i.e. if your email system has a Junk folder, but not a Trash folder, 'gt' will not work, etc." 20 60 ;}

formatShortcut() { \
	while read data; do
	echo "macro index,pager g$1 \"<change-folder>$data<enter>\" \"Go to $2.\"" >> "$muttdir"accounts/$3.muttrc
	done ;}

detectMailboxes() { \
	find ~/.mail/$1 -maxdepth 1 -mindepth 1 -type d | sed -e "s/.*\///g;s/^/=/g" > /tmp/$1_boxes
	oneline=$(cat /tmp/$1_boxes | tr "\n" " ")
	sed -i "/^mailboxes\|^set spoolfile\|^set record\|^set postponed/d" "$muttdir"accounts/$1.muttrc
	echo mailboxes $oneline >> "$muttdir"accounts/$1.muttrc
	sed -i "/^macro index,pager g/d" "$muttdir"accounts/$1.muttrc
	grep -vi /tmp/$1_boxes -e "trash\|drafts\|sent\|trash\|spam\|junk\|archive\|chat\|old\|new\|gmail\|sms\|call" | sort -n | sed 1q | formatShortcut i inbox $1
	grep -i /tmp/$1_boxes -e sent | formatShortcut s sent $1
	grep -i /tmp/$1_boxes -e draft | formatShortcut d drafts $1
	grep -i /tmp/$1_boxes -e trash | formatShortcut t trash $1
	grep -i /tmp/$1_boxes -e spam | formatShortcut S spam $1
	grep -i /tmp/$1_boxes -e archive | formatShortcut a archive $1
	spoolfile=$(grep -vi /tmp/$1_boxes -e "trash\|drafts\|sent\|trash\|spam\|junk\|archive\|chat\|old\|new\|gmail\|sms\|call" | sort -n | sed 1q | sed -e 's/=/+/g')
	record=$(grep -i /tmp/$1_boxes -e sent | sed -e 's/=/+/g')
	postponed=$(grep -i /tmp/$1_boxes -e draft | sed -e 's/=/+/g')
	echo "set spoolfile = \"$spoolfile\"" >> "$muttdir"accounts/$1.muttrc
	echo "set record = \"$record\"" >> "$muttdir"accounts/$1.muttrc
	echo "set postponed = \"$postponed\"" >> "$muttdir"accounts/$1.muttrc ;}

# Get all accounts in ~/.offlineimaprc and load into variable `accounts`.
getAccounts() { \
	cat ~/.offlineimaprc | grep "^accounts =" | sed -e 's/accounts =\( \)//g;s/\(,\) /\n/g;' | nl --number-format=ln > /tmp/numbered
	accounts=()
	while read n s ; do
		accounts+=($n "$s" off)
	done < /tmp/numbered ;}

# Yields a menu of available accounts.
inventory() { \
	getAccounts
	choices=$(dialog --separate-output --checklist "Select all desired email accounts with <SPACE>." 15 40 16 "${accounts[@]}" 2>&1 >/dev/tty)

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
	sed -i '/$1.muttrc/d' "$muttdir"personal.muttrc ;}

manual() { \
	imap=$( dialog --inputbox "Insert the IMAP server for your email provider (excluding the port number)" 10 60 3>&1 1>&2 2>&3 3>&- )
	iport=$(dialog --inputbox "What is your server's IMAP port number? (Usually 993)" 10 60 3>&1 1>&2 2>&3 3>&-)
	smtp=$( dialog --inputbox "Insert the SMTP server for your email provider (excluding the port number)" 10 60 3>&1 1>&2 2>&3 3>&- )
	sport=$( dialog --inputbox "What is your server's SMTP port number? (Usually 587 or 465)" 10 60 3>&1 1>&2 2>&3 3>&- ) ;}


addloop() { fulladdr=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Insert the full email address for the account you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
# Check to see if domain is in domain list
serverinfo=$(cat "$muttdir"autoconf/domains.csv | grep -w ^${fulladdr##*@})
if [ -z "$serverinfo" ];
	then
		manual
	else
# Read in server data as variables
IFS=, read service imap iport smtp sport <<EOF
$serverinfo
EOF
fi
realname=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Enter the full name you'd like to be identified by on this email account." 10 60 3>&1 1>&2 2>&3 3>&- )
title=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Give a short, one-word name for this email account that will differentiate it from other email accounts." 10 60 3>&1 1>&2 2>&3 3>&- )
login=$(dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Enter your login for the \"$title\" account.\n(If left empty, the full email address will be used instead.)" 10 60 3>&1 1>&2 2>&3 3>&- )
# Sets the repo type and other variables for the sed regex.
if [[ "$service" == "gmail.com" ]];
	then
		type="Gmail"
		delet="remotehost"
	else
		type="IMAP"
		delet="Gmail]\/"
fi
if [[ -z "$login" ]];
	then
		login=$fulladdr
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
	s/\$type/$type/g;
	s/\$login/$login/g;
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
	gpg2 -r $gpgemail --encrypt /tmp/$title || (dialog --title "GPG decryption failed." --msgbox "GPG decryption failed. This is either because you do not have a GPG key pair or because your distro uses GPG1 and you thus need to symlink /usr/bin/gpg2 to /usr/bin/gpg." 7 60 && break)
	shred -u /tmp/$title
	mv /tmp/$title.gpg ~/.config/mutt/credentials/

	# Creating the offlineimaprc if it doesn't exist already.
	if [ ! -f ~/.offlineimaprc ]; then cp "$muttdir"autoconf/offlineimap_header ~/.offlineimaprc; fi
	cat "$muttdir"autoconf/offlineimap_profile | sed -e "$replacement" >> ~/.offlineimaprc
	mkdir -p ~/.mail/$title

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
	echo "source ${muttdir}accounts/$title.muttrc" >> "$muttdir"personal.muttrc

	dialog --title "Finalizing your account." --msgbox "The account \"$title\" has been added. Now to finalize installation, do the following:

	1) Run offlineimap to start the sync. This will start your mail sync.
	2) After or while running offlineimap, choose the \"autodetect mailboxes\" option, which will finalize your config files based on the directory structure of the downloaded mailbox.

	After that, you will be able to open neomutt to your email account." 13 80 ;}

# This is run when a user chooses to add an account.
chooseAdd() { \
	mkdir -p "$muttdir"credentials/ "$muttdir"accounts/
	gpgemail=$( dialog --title "Luke's mutt/offlineIMAP password wizard" --inputbox "Insert the email address with which you originally created your GPG key pair. This is NOT necessarily the email you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
	addloop
	while : ;
	do
		dialog --title "Luke's mutt/offlineIMAP password wizard" --yesno "Would you like to add another email account?" 5 60 || break
		addloop
	done ;}

wipe () { rm $HOME/.offlineimaprc
	rm -rf "$muttdir"/accounts
	rm -f "$muttdir"credentials/*gpg
	rm "$muttdir"personal.muttrc ;}

while : ;
	do
choice=$(dialog --title "Luke's mutt/offlineIMAP wizard" --nocancel \
	--menu "What would you like to do?" 14 45 7 \
	0 "List all email accounts configured." \
	1 "Add an email account." \
	2 "Auto-detect mailboxes for an account." \
	3 "Change an account's password." \
	4 "Remove an email account." \
	5 "Remove all email accounts." \
	6 "Exit this wizard." \
	 3>&1 1>&2 2>&3 3>&1 )

case $choice in
0) dialog --title "Accounts detected" --msgbox "The following accounts have been detected:
$(grep ~/.offlineimaprc -e "^accounts =" | sed 's/accounts =//g')
" 6 60;;
1) chooseAdd;;
2) detectWarning && chooseDetect ;;
3) inventory && for i in $userchoices; do changePassword $i ; done;;
4) inventory && for i in $userchoices; do removeAccount $i ; done;;
5) (dialog --defaultno --title "Wipe all custom neomutt/offlineIMAP settings?" --yesno "Would you like to wipe all of the mutt/offlineIMAP settings generated by the system?" 6 60 && wipe) ;;
6) clear && break ;;
esac
done
