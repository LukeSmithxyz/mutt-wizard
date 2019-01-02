#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ];
then
	sslcert="/etc/ssl/certs/ca-certificates.crt"
else
	sslcert="/usr/local/etc/openssl/cert.pem"
fi

muttdir="$HOME/.config/mutt"
namere="^[a-z_][a-z0-9_-]*$"
emailre=".+@.+\\..+"

createMailboxes() { \
	tmpdir=$(mktemp -d)
	offlineimap --info -a "$1" 2&> "$tmpdir"/log
	sed -n '/^Folderlist/,/^Folderlist/p' "$tmpdir"/log |
		grep "^ " | sed -e "s/\\//./g;s/(.*//g;s/^ //g" > "$tmpdir"/lognew
	while read -r box; do mkdir -p "$HOME/.mail/$1/$box"; done <"$tmpdir"/lognew ;}

testSync() { (crontab -l | grep mailsync.sh && removeSync) || addSync ;}

addSync() { min=$(dialog --inputbox "How many minutes should be between mail syncs?" 8 60 3>&1 1>&2 2>&3 3>&-)
	(crontab -l; echo "*/$min * * * * eval \"export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME -x i3)/environ)\"; "$muttdir"/etc/mailsync.sh") | crontab - &&
	dialog --msgbox "Cronjob successfully added. Remember you may need to restart or tell systemd/etc. to start your cron manager for this to take effect." 7 60 ;}

removeSync() { ( (crontab -l | sed -e '/mailsync.sh/d') | crontab - >/dev/null) && dialog --msgbox "Cronjob successfully removed. To reactivate, select this option again." 6 60 ;}

msmtp_header="defaults
auth	on
tls	on
tls_trust_file	$sslcert
logfile	~/.msmtp.log
"

offlineimap_header="[general]
accounts =
starttls = yes
ssl = true
pythonfile = ~/.config/mutt/credentials/imappwd.py
"

getprofiles() { \
offlineimap_profile="
[Account $title]
localrepository = $title-local
remoterepository = $title-remote

[Repository $title-remote]
auth_mechanisms = LOGIN
type = $type
remoteuser = $login
remotepasseval = mailpasswd(\"$title\")
remoteport = $iport
sslline = $sslcert
$ifgoogleline

[Repository $title-local]
type = Maildir
localfolders = ~/.mail/$title
"

msmtp_profile="

account $title
host $smtp
port $sport
from $login
user $login
passwordeval \"gpg -d --quiet --for-your-eyes-only --no-tty ~/.config/mutt/credentials/$title.gpg | sed -e '\$a\\'\"
"

mutt_profile="# vim: filetype=neomuttrc
# muttrc file for account $title
set realname = \"$realname\"
set from = \"$fulladdr\"
set sendmail = \"/usr/bin/msmtp -a $title\"
set folder = \"~/.mail/$title\"
set header_cache = ~/.config/mutt/accounts/$title/cache/headers
set message_cachedir = ~/.config/mutt/accounts/$title/cache/bodies
set certificate_file = ~/.config/mutt/accounts/$title/certificates
source \"~/.config/mutt/credentials/getmuttpass $title |\"

alias me $realname <$fulladdr>

set mbox_type = Maildir
set ssl_starttls = yes
set ssl_force_tls = yes

bind index,pager gg noop
bind index,pager g noop
bind index gg first-entry
unmailboxes *
"

mbsync_profile="IMAPAccount $title
Host $imap
User $login
PassCmd \"gpg -d ~/.config/mutt/credentials/$title.gpg\"
SSLType IMAPS
CertificateFile $sslcert

IMAPStore $title-remote
Account $title

MaildirStore $title-local
Subfolders Verbatim
Path ~/.mail/$title
Inbox ~/.mail/$title/INBOX

Channel $title
Master :$title-remote:
Slave :$title-local:

Ceate Both
SyncState *
"

}

changePassword() { \
	gpgemail=$( dialog --title "Luke's mutt/offlineIMAP password wizard" --inputbox "Insert the email address with which you originally created your GPG key pair. This is NOT necessarily the email you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
	while ! [[ "${gpgemail}" =~ ${emailre} ]]; do
		gpgemail=$(dialog --no-cancel --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "That's not a valid email address. Please input the entire address." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	dialog --title "Luke's mutt/offlineIMAP password wizard" --passwordbox "Enter the new password for the \"$1\" account." 10 60 2> "/tmp/$1"
	gpg2 -r "$gpgemail" --encrypt "/tmp/$1" || (dialog --title "GPG decryption failed." --msgbox "GPG decryption failed. This is either because you do not have a GPG key pair or because your distro uses GPG1 and you thus need to symlink /usr/bin/gpg2 to /usr/bin/gpg." 7 60 && break)
	shred -u "/tmp/$1"
	mv "/tmp/$1.gpg" "$muttdir"/credentials/
	dialog --title "Finalizing your account." --infobox "The account \"$title\"'s password has been changed. Now attempting to configure mail directories...

	This may take several seconds..." 10 70
	createMailboxes "$title" || (clear && exit)
	detectMailboxes "$title"
	dialog --title "Password changed." --msgbox "Your \"$fulladdr\" password has been changed. To start the download of your mail, you can manually run \`offlineimap -a $title\` in a terminal. The first sync may take some time depending on the amount of your mail." 8 60 ;}

chooseDetect() { for x in $(grep "^accounts =" ~/.offlineimaprc | sed -e 's/accounts =\( \)//g;s/\(,\) /\n/g;'); do detectMailboxes "$x"; done && detectSuccess ;}

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
	while read -r data; do
	echo "macro index,pager g$1 \"<change-folder>$data<enter>\" \"Go to $2.\"" >> "$muttdir/accounts/$3.muttrc"
	done ;}

gen_delim() { \
	delim="="
	for i in $(seq $(( $1 - 1 )))
	do
		delim="$delim-"
	done
	echo $delim ;}

detectMailboxes() { \
	find ~/.mail/"$1" -maxdepth 1 -mindepth 1 -type d | sed -e "s/.*\\///g;s/^/=/g" > "/tmp/$1_boxes"
	sidebar_width=$(sed -n -e '/^set sidebar_width/p' "$muttdir"/muttrc | awk -F'=' '{print $2}')
	delim=$(gen_delim "$sidebar_width")
	oneline=$(sed -e "s/^\\|$/\"/g" "/tmp/$1_boxes" | tr "\\n" " ")
	oneline="=$1 $delim $oneline"
	sed -i "/^mailboxes\\|^set record\\|^set postponed\\|^set trash\\|^set spoolfile/d" "$muttdir/accounts/$1.muttrc"
	echo mailboxes "$oneline" >> "$muttdir/accounts/$1.muttrc"
	sed -i "/^macro index,pager g/d" "$muttdir/accounts/$1.muttrc"
	grep -i "/tmp/$1_boxes" -e inbox | sed 1q | formatShortcut i inbox "$1"
	grep -i "/tmp/$1_boxes" -e sent | sed 1q | formatShortcut s sent "$1"
	grep -i "/tmp/$1_boxes" -e draft | sed 1q | formatShortcut d drafts "$1"
	grep -i "/tmp/$1_boxes" -e trash | sed 1q | formatShortcut t trash "$1"
	grep -i "/tmp/$1_boxes" -e spam | sed 1q | formatShortcut S spam "$1"
	grep -i "/tmp/$1_boxes" -e junk | sed 1q | formatShortcut j junk "$1"
	grep -i "/tmp/$1_boxes" -e archive | sed 1q | formatShortcut a archive "$1"
	spoolfile=$(grep -i "/tmp/$1_boxes" -e inbox | sed -e 's/=/+/g' | sed 1q)
	record=$(grep -i "/tmp/$1_boxes" -e sent | sed -e 's/=/+/g' | sed 1q)
	postponed=$(grep -i "/tmp/$1_boxes" -e draft | sed -e 's/=/+/g' | sed 1q)
	trash=$(grep -i "/tmp/$1_boxes" -e trash | sed -e 's/=/+/g' | sed 1q)
	{ echo "set spoolfile = \"$spoolfile\"";
	echo "set record = \"$record\"";
	echo "set postponed = \"$postponed\"";
	echo "set trash = \"$trash\""; } >> "$muttdir/accounts/$1.muttrc"
	}

# Get all accounts in ~/.offlineimaprc and load into variable `accounts`.
getAccounts() { \
	grep "^accounts =" ~/.offlineimaprc | sed -e 's/accounts =\( \)//g;s/\(,\) /\n/g;' | nl --number-format=ln > /tmp/numbered
	accounts=()
	while read -r n s ; do
		accounts+=("$n" "$s" off)
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
	s/ $1\\(,\\|$\\)//g
	s/=$1\\(,\\|$\\)/=/g
	s/,$//g
	" ~/.offlineimaprc
	rm "$muttdir/accounts/$1.muttrc"
	rm "$muttdir/credentials/$1.gpg"
	rm -rf "$muttdir/accounts/$1"
	sed -i "/$1.muttrc/d" "$muttdir"/personal.muttrc ;}

manual() { \
	imap=$( dialog --inputbox "Insert the IMAP server for your email provider (excluding the port number)" 10 60 3>&1 1>&2 2>&3 3>&- )
	iport=$(dialog --inputbox "What is your server's IMAP port number? (Usually 993)" 10 60 3>&1 1>&2 2>&3 3>&-)
	smtp=$( dialog --inputbox "Insert the SMTP server for your email provider (excluding the port number)" 10 60 3>&1 1>&2 2>&3 3>&- )
	sport=$( dialog --inputbox "What is your server's SMTP port number? (Usually 587 or 465)" 10 60 3>&1 1>&2 2>&3 3>&- ) ;}


addloop() { \
	serverlist=$(mktemp -u)
	curl -sL https://raw.githubusercontent.com/LukeSmithxyz/mutt-wizard/master/autoconf/domains.csv 2>/dev/null > "$serverlist" &
	fulladdr=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Insert the full email address for the account you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
	while ! [[ "${fulladdr}" =~ ${emailre} ]]; do
		fulladdr=$(dialog --no-cancel --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "That's not a valid email address. Please input the entire address." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	# Check to see if domain is in domain list
	serverinfo=$(grep -w "^${fulladdr##*@}" "$serverlist")
if [ -z "$serverinfo" ];
	then
		manual
	else
# Read in server data as variables
IFS=, read -r service imap iport smtp sport <<EOF
$serverinfo
EOF
fi
	realname=$( dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Enter the full name you'd like to be identified by on this email account." 10 60 3>&1 1>&2 2>&3 3>&- )
	title=$(dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Give a short, one-word name for this email account that will differentiate it from other email accounts." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	while ! [[ "${title}" =~ ${namere} ]]; do
		title=$(dialog --no-cancel --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Account title not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	login=$(dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "If you have a username for the \"$title\" account which is different from your email address, enter it here. Otherwise leave this prompt blank." 10 60 3>&1 1>&2 2>&3 3>&- )
	# Sets the repo type and other variables for the sed regex.
	if [[ "$service" == "gmail.com" ]];
		then
			type="Gmail"
			ifgoogleline="remotehost = $imap"
		else
			type="IMAP"
			ifgoogleline="folderfilter = lambda foldername: foldername not in ['[Gmail]/All Mail']"
	fi
	[[ -z "$login" ]] && login=$fulladdr
	# Gets the first unused shortcut number in the muttrc and puts it in $idnum.
	grep "i[0-9]" "$muttdir/personal.muttrc" | awk '{print $3}' | sed -e 's/i//g' > /tmp/mutt_used
	echo -e "1\\n2\\n3\\n4\\n5\\n6\\n7\\n8\\n9" > /tmp/mutt_all_possible
	idnum=$(diff /tmp/mutt_all_possible /tmp/mutt_used | sed -n 2p | awk '{print $2}')
	addAccount \
	;}

addAccount() {
	# First, adding the encrypted password.
	dialog --title "Luke's mutt/offlineIMAP password wizard" --passwordbox "Enter the password for the \"$title\" account." 10 60 2> "/tmp/$title"
	gpg2 -r "$gpgemail" --encrypt "/tmp/$title" || (dialog --title "GPG decryption failed." --msgbox "GPG decryption failed. This is either because you do not have a GPG key pair or because your distro uses GPG1 and you thus need to symlink /usr/bin/gpg2 to /usr/bin/gpg." 7 60 && break)
	shred -u "/tmp/$title"
	mv "/tmp/$title.gpg" "$muttdir"/credentials/

	# Adding directory structure for cache.
	mkdir -p "$muttdir/accounts/$title/cache/bodies"

	# Prepare the account's config variables.
	getprofiles

	# Creating the offlineimaprc if it doesn't exist already.
	[ ! -f ~/.offlineimaprc ] && echo "$offlineimap_header" > ~/.offlineimaprc
	echo "$offlineimap_profile" >> ~/.offlineimaprc
	mkdir -p "$HOME/.mail/$title"

	# Creating msmtprc if it doesn't exist already.
	[ ! -f ~/.msmtprc ] && echo "$msmtp_header" > ~/.msmtprc
	echo "$msmtp_profile" >> ~/.msmtprc

	# Add the mutt profile.
	echo "$mutt_profile" >> "$muttdir/accounts/$title.muttrc"
	# Add a numbered shortcut in the muttrc
	echo "macro index,pager i$idnum '<sync-mailbox><enter-command>source \"$muttdir\"/accounts/$title.muttrc<enter><change-folder>!<enter>;<check-stats>'" >> "$muttdir/personal.muttrc"

	# Add to offlineimaprc sync list.
	sed -i "s/^accounts =.*[a-zA-Z]$/&, $title/g;s/^accounts =\\s*$/accounts = $title/g" ~/.offlineimaprc

	# Makes account default if there is no default account.
	grep "$muttdir/personal.muttrc" -e "^source .*accounts.*" >/dev/null || \
	echo "source ${muttdir}/accounts/$title.muttrc" >> "$muttdir/personal.muttrc"

	dialog --title "Finalizing your account." --infobox "The account \"$title\" has been added. Now attempting to configure mail directories...

	This may take several seconds..." 10 70
	createMailboxes "$title" || (clear && exit)
	detectMailboxes "$title"
	dialog --title "Account added." --msgbox "Your \"$fulladdr\" account has been added. To start the download of your mail, you can manually run \`offlineimap -a $title\` in a terminal. The first sync may take some time depending on the amount of your mail." 8 60 ;}

# This is run when a user chooses to add an account.
chooseAdd() { \
	mkdir -p "$muttdir"/credentials/ "$muttdir"/accounts/
	gpgemail=$( dialog --title "Luke's mutt/offlineIMAP password wizard" --inputbox "Insert the email address with which you originally created your GPG key pair. This is NOT necessarily the email you want to configure." 10 60 3>&1 1>&2 2>&3 3>&- )
	addloop
	while : ;
	do
		dialog --title "Luke's mutt/offlineIMAP password wizard" --yesno "Would you like to add another email account?" 5 60 || break
		addloop
	done ;}

wipe () { rm -f "$HOME/.offlineimaprc"
	rm -rf "$muttdir"/accounts
	rm -f "$muttdir"/credentials/*gpg
	rm -f "$muttdir"/personal.muttrc ;}

while : ;
	do
choice=$(dialog --title "Luke's mutt/offlineIMAP wizard" --nocancel \
	--menu "What would you like to do?" 15 45 8 \
	0 "List all email accounts configured." \
	1 "Add an email account." \
	2 "Enable/disable autosync." \
	3 "Redetect mailboxes." \
	4 "Change an account's password." \
	5 "Remove an email account." \
	6 "Remove all email accounts." \
	7 "Exit this wizard." \
	 3>&1 1>&2 2>&3 3>&1 )

case $choice in
	0) dialog --title "Accounts detected" --msgbox "The following accounts have been detected:
$(grep ~/.offlineimaprc -e "^accounts =" | sed 's/accounts =//g')
" 6 60;;
	1) chooseAdd;;
	2) testSync;;
	3) detectWarning && chooseDetect;;
	4) inventory && for i in $userchoices; do changePassword "$i" ; done;;
	5) inventory && for i in $userchoices; do removeAccount "$i" ; done;;
	6) (dialog --defaultno --title "Wipe all custom neomutt/offlineIMAP settings?" --yesno "Would you like to wipe all of the mutt/offlineIMAP settings generated by the system?" 6 60 && wipe) ;;
	7) clear && break ;;
	*) echo "Unable to read response from dialog. Exiting." >&2; exit 2
esac
done
