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
serverinfo=$(cat autoconf/domains.csv | grep -w ^${fulladdr##*@})
if [ -z "$serverinfo" ]; then echo No suitable match. && exit; fi

# Read in server data as variables
IFS=, read service imap iport smtp sport spoolfile postponed record <<EOF
$serverinfo
EOF
clear

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


addAccount() {
	if [ ! -f ~/.offlineimaprc ]; then cp "$muttdir"autoconf/offlineimap_header ~/.offlineimaprc; fi
	cat "$muttdir"autoconf/offlineimap_profile | sed -e "$replacement" >> ~/.offlineimaprc
	# Add the mutt profile.
	cat "$muttdir"autoconf/mutt_profile | sed -e "$replacement" > "$muttdir"accounts/$title.muttrc
	# Add on offlineimaprc sync list.
	sed -i "s/^accounts =.*[a-zA-Z]$/&, $title/g;s/^accounts =$/accounts = $title/g" ~/.offlineimaprc ;}

addAccount

dialog --title "Luke's mutt/offlineIMAP password wizard" --passwordbox "Enter the password for the \"$title\" account." 10 60 2> /tmp/$title
gpg -r $youremail --encrypt /tmp/$title
shred -u /tmp/$title && echo "Password encrypted and memory shredded."
mv /tmp/$title.gpg ~/.config/mutt/credentials/

echo Done lmao.
exit
