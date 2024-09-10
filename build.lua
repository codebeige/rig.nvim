local fs = vim.fs
local uv = vim.uv
local fn = vim.fn
local dir = fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
local fennel = dofile(fs.joinpath(dir, "lib/fennel.lua"))

fennel.path = "src/?.fnl;src/?/init.fnl"
fennel["macro-path"] = "src/?.fnl;src/?/init-macros.fnl;src/?/init.fnl"

local src = fs.joinpath(dir, "src/rig/init.fnl")
local out = fs.joinpath(dir, "lua/rig.lua")
local opts = {
  requireAsInclude = true,
  skipInclude = { "fennel", "fennel.specials" },
}

local src_file = assert(uv.fs_open(src, "r", 438))
local src_stat = assert(uv.fs_fstat(src_file))
local source = assert(uv.fs_read(src_file, src_stat.size, 0))
assert(uv.fs_close(src_file))

local chunk = fennel.compileString(source, opts)

fn.mkdir(fs.dirname(out), "p")
local out_file = assert(uv.fs_open(out, "w+", 438))
assert(uv.fs_write(out_file, chunk, 0))
assert(uv.fs_close(out_file))

function pr(message)
  if not pcall(coroutine.yield, message) then
    vim.print(message)
  end
end

pr("Successfully compiled 'rig.lua'.")
