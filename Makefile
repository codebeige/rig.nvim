build: lua/rig.lua

clean:
	rm -rf lua
	rm -rf tmp

.PHONY: build clean

lua/rig.lua: $(wildcard src/rig/*.fnl)
	nvim -l build.lua
