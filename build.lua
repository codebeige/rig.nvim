local fs = vim.fs
local uv = vim.uv
local fn = vim.fn

local dir = fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
local fennel = dofile(fs.joinpath(dir, "lib/fennel.lua"))

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

function pr(message)
  if not pcall(coroutine.yield, message) then
    vim.print(message)
  end
end

function compile_at(dir, source, opts)
  local before = {
    fennel_path = fennel.path,
    fennel_macro_path = fennel["macro-path"],
    dir = vim.fn.chdir(dir),
  }
  if current_dir == "" then
    return false, "Could not enter directory '" .. dir .. "'"
  end
  fennel.path = "src/?.fnl;src/?/init.fnl"
  fennel["macro-path"] = "src/?.fnl;src/?/init-macros.fnl;src/?/init.fnl"

  local success, result = pcall(fennel.compileString, source, opts)

  fennel.path = before.fennel_path
  fennel["macro-path"] = before.fennel_macro_path
  vim.fn.chdir(before.dir)

  return success, result
end

local did_compile, result = compile_at(dir, source, opts)

if did_compile then
  fn.mkdir(fs.dirname(out), "p")
  local out_file = assert(uv.fs_open(out, "w+", 438))
  assert(uv.fs_write(out_file, result, 0))
  assert(uv.fs_close(out_file))
  pr("Successfully compiled '" .. out .. "'.")
else
  pr("[Error] Failed to compile '" .. src .. "': " .. result)
end


