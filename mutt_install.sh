#!/bin/bash

muttdir="$HOME/.config/mutt/"
mkdir -p ~/.config/mutt/credentials

# Email for GPG
youremail=$(\
	dialog --title "Luke's mutt/offlineIMAP password wizard" --inputbox "Insert the email address with which you originally created your key pair. This is NOT necessarily the email you want to configure." 10 60 \
	3>&1 1>&2 2>&3 3>&- \
	)

# Get email address
fulladdr=$(\
	dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Insert your full email address." 10 60 \
	3>&1 1>&2 2>&3 3>&- \
	)

# Check to see if domain is in domain list
serverinfo=$(cat "$muttdir"autoconf/domains.csv | grep -w ^${fulladdr##*@})
if [ -z "$serverinfo" ];
	then
		echo No suitable match. && exit
	else
# Read in server data as variables
IFS=, read service imap iport smtp sport spoolfile postponed record <<EOF
$serverinfo
EOF
fi

realname=$(\
	dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Enter the full name you'd like to be identified by on this email account." 10 60 \
	3>&1 1>&2 2>&3 3>&- \
	)

title=$(\
	dialog --title "Luke's mutt/offlineIMAP autoconfig" --inputbox "Give a short, one-word name for this email account that will differentiate it from other email accounts." 10 60 \
	3>&1 1>&2 2>&3 3>&- \
	)


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
cat "$muttdir"muttrc | grep i[0-9] | awk '{print $3}' | sed -e 's/i//g' > /tmp/mutt_used
echo -e "1\n2\n3\n4\n5\n6\n7\n8\n9" > /tmp/mutt_all_possible
idnum=$(diff /tmp/mutt_all_possible /tmp/mutt_used | sed -n 2p | awk '{print $2}')

addAccount() {
	# First, adding the encrypted password.
	dialog --title "Luke's mutt/offlineIMAP password wizard" --passwordbox "Enter the password for the \"$title\" account." 10 60 2> /tmp/$title
	gpg -r $youremail --encrypt /tmp/$title
	shred -u /tmp/$title && echo "Password encrypted and memory shredded."
	mv /tmp/$title.gpg ~/.config/mutt/credentials/

	# Creating the offlineimaprc if it doesn't exist already.
	if [ ! -f ~/.offlineimaprc ]; then cp "$muttdir"autoconf/offlineimap_header ~/.offlineimaprc; fi
	cat "$muttdir"autoconf/offlineimap_profile | sed -e "$replacement" >> ~/.offlineimaprc

	# Add the mutt profile.
	cat "$muttdir"autoconf/mutt_profile | sed -e "$replacement" > "$muttdir"accounts/$title.muttrc
	# Add a numbered shortcut in the muttrc
	echo "macro index,pager i$idnum '<sync-mailbox><enter-command>source "$muttdir"accounts/$title.muttrc<enter><change-folder>!<enter>'" >> "$muttdir"muttrc

	# Adding directory structure for cache.
	mkdir -p "$muttdir"accounts/$title/cache/bodies "$muttdir"accounts/$title/cache/headers

	# Add to offlineimaprc sync list.
	sed -i "s/^accounts =.*[a-zA-Z]$/&, $title/g;s/^accounts =$/accounts = $title/g" ~/.offlineimaprc

	# Makes account default if there is no default account.
	grep "$muttdir"muttrc -e "^source .*accounts.*" >/dev/null && echo there || \
	echo "source ${muttdir}accounts/$title.muttrc" >> "$muttdir"muttrc ;}

addAccount
clear
