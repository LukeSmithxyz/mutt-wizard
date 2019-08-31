#!/usr/bin/env bats

# needs:
# bash-bats
#
# run with:
# bats --tap test_mw.bats

run_only_test() {
    if [ "$BATS_TEST_NUMBER" -ne "$1" ]; then
        skip
    fi
}

#these are called for every test
setup()
{
    rm -rf mwtesttmp
    XDG_CONFIG_HOME=mwtesttmp/config \
    MAILDIR=mwtesttmp/share/mail \
    XDG_CACHE_HOME=mwtesttmp/cache \
    source ../bin/mw
    export NOTMUCH_CONFIG=mwtesttmp/config/notmuch-config
    export mwname="real name"
    export mwaddr="full.addr@gmail.com"
    export mwlogin="$mwaddr"
    export mailboxes="[Gmail]/INBOX"
    export mwshare=$PWD/../share
    function pass() { return 0; }
    export pass
}
teardown()
{
    if [ -z "$TEST_FUNCTION" ]
    then
        rm -rf mwtesttmp
    fi
}

#1
@test "check config" {
    [ "$mwmbsyncrc" = "mwtesttmp/config/isync/mbsyncrc" ]
    [ "$mwmsmtprc" = "mwtesttmp/config/msmtp/config" ]
}

#2
@test "add online" {
    mwtype="online" run _mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.online.muttrc ]
    [ "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ ! -f mwtesttmp/config/notmuch-config ]
}

#3
@test "add offline unsuccessful" {
    export mailboxes="[Gmail]/OTHER"
    mwtype="offline" run _mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ ! -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.offline.muttrc ]
    [ "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ ! -f mwtesttmp/config/notmuch-config ]
}

#4
@test "add offline successfully" {
    mwtype="offline" run _mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.offline.muttrc ]
    [ -f mwtesttmp/config/notmuch-config ]
    cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p'
    [ ! "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    run _mwlist
    [ "$(echo $lines | awk '{print $2}')" = "$mwaddr" ]
}

#5
@test "delete account" {
    mwtype="online" run _mwadd
    mwtype="offline" run _mwadd
    mwpick="1" _mwpick delete && _mwdelete
    [ ! -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.online.muttrc ]
    [ ! "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
}

#6
@test "cron" {
    mwtype="online" run _mwadd
    function pgrep() { return 0; }
    export pgrep
    function crontab() { echo 'none'; }
    export crontab
    mwcronminutes=99 run _mwcron
    chkline="${lines[2]}"
    [ "${chkline::14}" = "Cronjob added." ]
    function crontab() { echo 'mailsync'; }
    export crontab
    mwcronremove=y run _mwcron
    chkline="${lines[1]}"
    [ "${chkline#*turned}" = " off." ]
}

