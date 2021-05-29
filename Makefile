.POSIX:

OS = $(shell uname -s)
ifndef PREFIX
  PREFIX = /usr/local
endif
ifndef MANPREFIX
  MANPREFIX = $(PREFIX)/share/man
endif
ifndef XDG_DATA_HOME
  XDG_DATA_HOME = $(HOME)/.local/share
endif

DESTDIR = mutt-wizard
PREFIX_LOCAL = $(XDG_DATA_HOME)
BIN_LOCAL = $(HOME)/.local/bin
MANPREFIX_LOCAL = $(PREFIX_LOCAL)/man

install-local:
	cp -f bin/mw bin/mailsync bin/openfile $(BIN_LOCAL)
	mkdir -p $(PREFIX_LOCAL)/$(DESTDIR)
	cp -f share/mailcap share/domains.csv share/mutt-wizard.muttrc $(PREFIX_LOCAL)/$(DESTDIR)
	mkdir -p $(MANPREFIX_LOCAL)/man1
	cp -f mw.1 $(MANPREFIX_LOCAL)/man1/mw.1
	if [ "$(PREFIX_LOCAL)" ]; then \
		sed -iba 's:/usr/local:$(PREFIX_LOCAL):' $(PREFIX_LOCAL)/$(DESTDIR)/mutt-wizard.muttrc; \
		rm -f $(PREFIX_LOCAL)/$(DESTDIR)/mutt-wizard.muttrcba; \
		sed -iba 's:/usr/local:$(PREFIX_LOCAL):' $(BIN_LOCAL)/mw; \
		rm -f $(BIN_LOCAL)/mwba; \
		sed -iba 's:/usr/local:$(PREFIX_LOCAL):' $(MANPREFIX_LOCAL)/man1/mw.1; \
		rm -f $(MANPREFIX_LOCAL)/man1/mw.1ba; \
	fi

uninstall-local:
	rm -f $(BIN_LOCAL)/mw $(BIN_LOCAL)/mailsync $(BIN_LOCAL)/openfile
	rm -rf $(PREFIX_LOCAL)/$(DESTDIR)
	rm -f $(MANPREFIX_LOCAL)/man1/mw.1

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f bin/mw bin/mailsync bin/openfile $(DESTDIR)$(PREFIX)/bin/
	chmod 755 $(DESTDIR)$(PREFIX)/bin/mw $(DESTDIR)$(PREFIX)/bin/mailsync $(DESTDIR)$(PREFIX)/bin/openfile
	mkdir -p $(DESTDIR)$(PREFIX)/share/mutt-wizard
	chmod 755 $(DESTDIR)$(PREFIX)/share/mutt-wizard
	cp -f share/mailcap share/domains.csv share/mutt-wizard.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard
	chmod 644 $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcap $(DESTDIR)$(PREFIX)/share/mutt-wizard/domains.csv $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f mw.1 $(DESTDIR)$(MANPREFIX)/man1/mw.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/mw.1
	if [ "$(PREFIX)" ]; then \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc; \
		rm -f $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrcba; \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(PREFIX)/bin/mw; \
		rm -f $(DESTDIR)$(PREFIX)/bin/mwba; \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(MANPREFIX)/man1/mw.1; \
		rm -f $(DESTDIR)$(MANPREFIX)/man1/mw.1ba; \
	fi

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mw $(DESTDIR)$(PREFIX)/bin/mailsync $(DESTDIR)$(PREFIX)/bin/openfile
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard
	rm -f $(DESTDIR)$(MANPREFIX)/man1/mw.1

.PHONY: install-local uninstall-local install uninstall
