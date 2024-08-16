build: lua/rig.lua

clean:
	rm -rf lua

.PHONY: build clean

lua:
	mkdir lua

lua/rig.lua: fnl/rig.fnl fnl/rig/bootstrap.fnl lua
	bin/compile $< > $@