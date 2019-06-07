.POSIX:

OS = $(shell uname -s)
ifeq ($(OS), Darwin)
  PREFIX ?= /usr/local
else
  PREFIX ?= /usr
endif
MANPREFIX = $(PREFIX)/share/man

install:
	utils/install.sh -p "$(PREFIX)"

uninstall:
	for script in bin/*; do \
		rm -f $(DESTDIR)$(PREFIX)/bin/$$script; \
	done
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard

.PHONY: install uninstall
