.PHONY: clean dotfiles install test update

all:
	@echo "Select one of the targets clean, dotfiles, install or update."

clean:
	./bin/clean.sh

dotfiles:
	cp .bashrc ~/ && chmod 600 ~/.bashrc
	cp .vimrc ~/ && chmod 600 ~/.vimrc

install:
	./bin/setup-remnux.sh

test:
	shellcheck -f checkstyle bin/*.sh > checkstyle.out || true

update:
	git pull
	./bin/update-remnux.sh

