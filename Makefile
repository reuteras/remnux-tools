.PHONY: install

all: install

install:
	[ -e ~/.bashrc ] && mv -f ~/.bashrc{,.backup}
	[ -e ~/.vimrc ] && mv -f ~/.vimrc{,.backup}
	cp .bashrc ~/ && chmod 600 ~/.bashrc
	cp .vimrc ~/ && chmod 600 ~/.vimrc
	cp .bash_aliases ~/ && chmod 600 ~/.bash_aliases

