local root_dir = vim.fs.root(debug.getinfo(1).source, "README.md")

local function require_fennel(src)
  package.preload["fennel"] = package.preload["fennel"] or loadfile(
     src or vim.fs.joinpath(root_dir, "lib", "fennel.lua")
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
    vim.fs.joinpath(root_dir, "fnl", "?.fnl"),
    vim.fs.joinpath(root_dir, "fnl", "?", "init.fnl"),
  }
  for _, k in pairs({"path", "macro-path"}) do
    fennel[k] = prepend(fennel[k], unpack(plugin_paths))
  end
  require("rig.runtime").install()
end

return { setup = setup }
