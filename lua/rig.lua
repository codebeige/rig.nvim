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
  local fragments = vim.split(path, path_separator)
  local index = {}
  for i, p in ipairs({...}) do
    index[p] = i
  end
  local path_ = table.concat({...}, path_separator)
  for _,  fragment in ipairs(fragments) do
    if not index[fragment] then
      path_ = path_ .. path_separator .. fragment
    end
  end
  return path_
end

local function setup()
  vim.loader.enable()
  local fennel = require_fennel(vim.env.RIG_NVIM_FENNEL)
  insert_at(package.loaders, 2, fennel.searcher)
  fennel.path = prepend(
    fennel.path,
    plugin_path("fnl", "?.fnl"),
    plugin_path("fnl", "?", "init.fnl")
  )
  fennel["macro-path"] = prepend(
    fennel["macro-path"],
    plugin_path("fnl", "?.fnl"),
    plugin_path("fnl", "?", "init.fnl"),
    plugin_path("fnl", "?", "init-macros.fnl")
  )
  require("rig.runtime").install()
end

return { setup = setup }
