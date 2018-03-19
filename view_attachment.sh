#!/bin/bash
#
# Author:  Eric Gebhart
#
# Purpose:  To be called by mutt as indicated by .mailcap to handle mail attachments.
#
# Function: Copy the given file to a temporary directory so mutt
#           Won't delete it before it is read by the application.
#
#           Along the way, discern the file type or use the type
#           That is given.
#
#           Finally use 'open' or 'open -a' if the third argument is
#           given.
#
#
# Arguments:
#
#     $1 is the file
#     $2 is the type - for those times when file magic isn't enough.
#                      I frequently get html mail that has no extension
#                      and file can't figure out what it is.
#
#                      Set to '-' if you don't want the type to be discerned.
#                      Many applications can sniff out the type on their own.
#                      And they do a better job of it too.
#
#                      Open Office and MS Office for example.
#
#     $3 is open with.  as in open -a 'open with this .app' foo.xls
#
# Examples:  These are typical .mailcap entries which use this program.
#
#     Image/JPEG; /Users/vdanen/.mutt/view_attachment %s
#     Image/PNG; /Users/vdanen/.mutt/view_attachment %s
#     Image/GIF; /Users/vdanen/.mutt/view_attachment %s
#
#     Application/PDF; /Users/vdanen/.mutt/view_attachment %s
#
#         #This HTML example passes the type because file doesn't always work and
#         #there aren't always extensions.
#
#     text/html; /Users/vdanen/.mutt/view_attachment %s html
#
#         # If your Start OpenOffice.org.app is spelled with a space like this one, <--
#         # then you'll need to precede the space with a \ .  I found that too painful
#         # and renamed it with an _.
#
#     Application/vnd.ms-excel; /Users/vdanen/.mutt/view_attachment %s "-" '/Applications/OpenOffice.org1.1.2/Start_OpenOffice.org.app'
#     Application/msword; /Users/vdanen/.mutt/view_attachment %s "-" '/Applications/OpenOffice.org1.1.2/Start_OpenOffice.org.app'
#
#
# Debugging:  If you have problems set debug to 'yes'.  That will cause a debug file
#             be written to /tmp/mutt_attach/debug so you can see what is going on.
#
# See Also:  The man pages for open, file, basename
#

# the tmp directory to use.
tmpdir="$HOME/.tmp/mutt_attach"

# the name of the debug file if debugging is turned on.
debug_file=$tmpdir/debug

# debug.  yes or no.
#debug="no"
debug="yes"

type=$2
open_with=$3

# make sure the tmpdir exists.
mkdir -p $tmpdir

# clean it out.  Remove this if you want the directory
# to accumulate attachment files.
rm -f $tmpdir/*

# Mutt puts everything in /tmp by default.
# This gets the basic filename from the full pathname.
filename=`basename $1`

# get rid of the extenson and save the name for later.
file=`echo $filename | cut -d"." -f1`

if [ $debug = "yes" ]; then
    echo "1:" $1 " 2:" $2 " 3:" $3 > $debug_file
    echo "Filename:"$filename >> $debug_file
    echo "File:"$file >> $debug_file
    echo "===========================" >> $debug_file
fi

# if the type is empty then try to figure it out.
if [ -z $type ]; then
    file  $1
    type=`file -bi $1 | cut -d"/" -f2`
fi

# if the type is '-' then we don't want to mess with type.
# Otherwise we are rebuilding the name.  Either from the
# type that was passed in or from the type we discerned.
if [ $type = "-" ]; then
    newfile=$filename
else
    newfile=$file.$type
fi

newfile=$tmpdir/$newfile

# Copy the file to our new spot so mutt can't delete it
# before the app has a chance to view it.
cp $1 $newfile

if [ $debug = "yes" ]; then
    echo "File:" $file "TYPE:" $type >> $debug_file
    echo "Newfile:" $newfile >> $debug_file
    echo "Open With:" $open_with >> $debug_file
fi

# If there's no 'open with' then we can let preview do it's thing.
# Otherwise we've been told what to use.  So do an open -a.

if [ -z $open_with ]; then
    open $newfile
else
    open -a "$open_with" $newfile
fi
