local _root_dir

local function plugin_path(...)
  local src = debug.getinfo(2, "S").short_src
  _root_dir = _root_dir or vim.fs.root(src, "README.md")
  assert(
    _root_dir,
    "Error resolving plugin path '" .. vim.fs.joinpath(...) .. "'"
  )
  return vim.fs.joinpath(_root_dir, ...)
end

local function require_fennel(src)
  package.preload["fennel"] = package.preload["fennel"] or loadfile(
     src or plugin_path("lib", "fennel.lua")
  )
  return require("fennel")
end

local function index_of(xs, x)
  for x_, v in pairs(xs) do
    if x_ == x then
      return i
    end
  end
end

local function insert_at(xs, i, x)
  local i_ = index_of(xs, x)
  if i_ ~= i then
    if i_ then
      table.remove(xs, i_)
    end
    table.insert(xs, i, x)
  end
end

local path_separator = package.config:sub(3, 3)

local function prepend(path, ...)
  local path_ = path
  for _, fragment in pairs({...}) do
    path_ = path_:gsub(fragment .. path_separator, "", 1, true)
    path_ = path_:gsub(path_separator .. fragment, "", 1, true)
  end
  return table.concat({...}, path_separator) .. path_separator .. path_
end

local function setup()
  local fennel = require_fennel(vim.env.RIG_NVIM_FENNEL)
  insert_at(package.loaders, 2, fennel.searcher)
  local plugin_paths = {
    plugin_path("fnl", "?.fnl"),
    plugin_path("fnl", "?", "init.fnl"),
  }
  for _, k in pairs({"path", "macro-path"}) do
    fennel[k] = prepend(fennel[k], unpack(plugin_paths))
  end
  require("rig.runtime").install()
end

return { setup = setup }
