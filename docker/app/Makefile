SHELL = /bin/bash

_esy:
	esy install

.PHONY: clean-esy-build
clean-esy-build: 
	rm -rf _esy


_esy/default/build/default/bin/main.exe: _esy 
	esy

.PHONY: main.exe
main.exe: _esy/default/build/default/bin/main.exe

.PHONY: rebuild
rebuild: _esy
	esy

.PHONY: run
run: _esy/default/build/default/bin/main.exe
	./_esy/default/build/default/bin/main.exe

# Build and run main.exe
.PHONY: brun
brun: rebuild run
