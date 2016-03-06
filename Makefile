.PHONY: install

all: install

install:
	test -e ~/.bashrc && /bin/mv -f ~/.bashrc{,.backup}; fi
	test -e ~/.vimrc && /bin/mv -f ~/.vimrc{,.backup}; fi
	cp .bashrc ~/ && chmod 600 ~/.bashrc
	cp .vimrc ~/ && chmod 600 ~/.vimrc
	cp .bash_aliases ~/ && chmod 600 ~/.bash_aliases

