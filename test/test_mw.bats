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

# these are called for every test
setup()
{
    # run_only_test 2
    rm -rf mwtesttmp
    XDG_CONFIG_HOME=mwtesttmp/config \
    MAILDIR=mwtesttmp/share/mail \
    XDG_CACHE_HOME=mwtesttmp/cache \
    prefix="$PWD" \
    source ../bin/mw
    export NOTMUCH_CONFIG=mwtesttmp/config/notmuch-config
    export mwname="real name"
    export mwaddr="full.addr@gmail.com"
    export mwlogin="$mwaddr"
    export mwmailboxes="[Gmail]/INBOX"
    export mwshare=$PWD/../share
    function pass() { return 0; }
    export pass
    function _mwcheckinternet() { return 0; }
    export _mwcheckinternet
    function _mwcheckcert() { return 0; }
    export _mwcheckcert
    function pgrep() { return 0; }
    export pgrep
    function crontab() { echo 'none'; }
    export crontab
    function _mwsyncandnotify() { echo "$mwaddr"; }
    export _mwsyncandnotify
}
teardown()
{
    if [ -z "$TEST_FUNCTION" ]
    then
        rm -rf mwtesttmp
    fi
}

# 1
@test "check config" {
    [ "$mwmbsyncrc" = "mwtesttmp/config/isync/mbsyncrc" ]
    [ "$mwmsmtprc" = "mwtesttmp/config/msmtp/config" ]
}

# 2
@test "add online" {
    mwtype="online" run _mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.online.muttrc ]
    [ "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.online.muttrc | sed -ne '/smtp_url/p')" = "" ]
    [ ! -f mwtesttmp/config/notmuch-config ]
}

# 3
@test "add offline unsuccessful" {
    export mwmailboxes="[Gmail]/OTHER"
    mwtype="offline" run _mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ ! -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.offline.muttrc ]
    [ "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ ! -f mwtesttmp/config/notmuch-config ]
}

# 4
@test "add offline successfully" {
    mwtype="offline" run _mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.offline.muttrc ]
    [ -f mwtesttmp/config/notmuch-config ]
    [ ! "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ "$(cat mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.online.muttrc | sed -ne '/smtp_url/p')" = "" ]
    run _mwlist
    [ "$(echo $lines | awk '{print $2}')" = "$mwaddr" ]
}

# 5
@test "delete account" {
    mwtype="online" run _mwadd
    mwtype="offline" run _mwadd

    pick_delete()
    {
      _mwpick delete && _mwdelete
    }
    export pick_delete

    mwpick="1" run pick_delete
    [ ! -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.online.muttrc ]
    [ ! "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
}

# 6
@test "cron" {
    mwcronminutes=99 run _mwcron
    chkline="${lines[2]}"
    [ "${chkline::14}" = "Cronjob added." ]
    function crontab() { echo 'mw sync'; }
    export crontab
    mwcronremove=y run _mwcron
    chkline="${lines[1]}"
    [ "${chkline#*turned}" = " off." ]
}

# 7
@test "sync" {
    mwtype="offline" run _mwadd
    function pgrep() { [ "$1" = "-u" ] && return 0 || return 1; }
    export pgrep
    run _mwsync
    [ "${lines// /}" = "full.addr@gmail.com" ]
}

# 8
@test "add pop" {
    export mwaddr="full.addr@chello.at"
    mwtype="offline" run _mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ -f mwtesttmp/config/mutt/accounts/1-$mwaddr.mwonofftype.offline.muttrc ]
    [ -f mwtesttmp/config/notmuch-config ]
    [ ! "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/getmail/$mwaddr | sed -ne '/^\s*\w/p')" = "" ]
    run _mwlist
    [ "$(echo $lines | awk '{print $2}')" = "$mwaddr" ]
}
