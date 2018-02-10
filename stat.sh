#!/bin/sh

# Gets all accounts used by offlineimaps.

cat ~/.offlineimaprc | grep "^accounts =" | sed -e 's/accounts =\( \)//g;s/\(,\) /\n/g;'
# Another option
# Get current accounts
#accountsline=$(cat ~/.offlineimaprc | grep ^accou | sed 's/,//g')
