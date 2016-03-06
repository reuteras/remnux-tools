.PHONY: install

all: install

install:
	if [[ -e ~/.bashrc ]] ; then /bin/mv -f ~/.bashrc{,.backup}; fi
	if [[ -e ~/.vimrc ]] ; then /bin/mv -f ~/.vimrc{,.backup}; fi
	cp .bashrc ~/ && chmod 600 ~/.bashrc
	cp .vimrc ~/ && chmod 600 ~/.vimrc
	cp .bash_aliases ~/ && chmod 600 ~/.bash_aliases

