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

setup()
{
    #run_only_test 4
    XDG_CONFIG_HOME=mwtesttmp/config \
    MAILDIR=mwtesttmp/share/mail \
    XDG_CACHE_HOME=mwtesttmp/cache \
    source ../bin/mw
    export NOTMUCH_CONFIG=mwtesttmp/config/notmuch-config
    export mwrealname="real name"
    export mwfulladdr="full.addr@gmail.com"
    export mwlogin="$mwfulladdr"
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
    export mwtype=online
    run mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ ! -f mwtesttmp/config/notmuch-config ]
}

#3
@test "add offline unsuccessful" {
    export mwtype=offline
    export mwmaxmes="0"
    run mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
    [ ! -f mwtesttmp/config/notmuch-config ]
}

#4
@test "add offline successfully" {
    export mwtype=offline
    export mwmaxmes="0"
    export mailboxes="[Gmail]/Drafts"
    run mwadd
    [ -f mwtesttmp/config/mutt/muttrc ]
    [ -d mwtesttmp/config/mutt/accounts ]
    [ -f mwtesttmp/config/notmuch-config ]
    cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p'
    [ ! "$(cat mwtesttmp/config/isync/mbsyncrc | sed -ne '/^\s*\w/p')" = "" ]
    [ ! "$(cat mwtesttmp/config/msmtp/config | sed -ne '/^account/p')" = "" ]
}

