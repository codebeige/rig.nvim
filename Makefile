build: lua/rig/init.lua

clean:
	rm -rf tmp
	rm -rf lua/rig

.PHONY: build clean

lua/rig:
	mkdir -p lua/rig

lua/rig/init.lua: src/rig/init.fnl $(wildcard src/rig/*.fnl) lua/rig
	bin/compile $< > $@
