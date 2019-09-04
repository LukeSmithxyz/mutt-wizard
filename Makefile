.POSIX:

OS = $(shell uname -s)
ifeq ($(OS), Darwin)
  PREFIX = /usr/local
else
  PREFIX = /usr
endif
MANPREFIX = $(PREFIX)/share/man

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	for script in bin/*; do \
		cp -f $$script $(DESTDIR)$(PREFIX)/bin/; \
		chmod 755 $(DESTDIR)$(PREFIX)/$$script; \
	done
	mkdir -p $(DESTDIR)$(PREFIX)/share/mutt-wizard
	for shared in share/*; do \
		cp -f $$shared $(DESTDIR)$(PREFIX)/share/mutt-wizard; \
	done
	if [ "$(OS)" = "Darwin" ]; then \
		sed -iba 's/\/usr\//\/usr\/local\//' $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc; \
		rm $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrcba; \
	fi
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f mw.1 $(DESTDIR)$(MANPREFIX)/man1/mw.1

uninstall:
	for script in bin/*; do \
		rm -f $(DESTDIR)$(PREFIX)/$$script; \
	done
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard

.PHONY: install uninstall
