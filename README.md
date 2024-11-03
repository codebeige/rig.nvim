# ⛵️ rig.nvim

First-class [fennel][1] support inside [neovim][2].

This plugin allows you to import fennel modules from `fennel.path` or any
`fnl/` directory on your runtime path. It works just the same as requiring lua
code from `package.path` or a `lua/` directory accordingly.

## Usage

### Fennel Plugins

If you want to use a plugin that is purely written in fennel (i.e., the plugin
repository does *not* contain precompiled lua), simply ensure `rig.setup()`
will be called before initialization.

With [`lazy.nvim`][4] this can be achieved by adding `codebeige/rig.nvim` as a
dependency:

```lua
-- $XDG_CONFIG_HOME/nvim/lua/plugins/my-fennel-plugin.lua

return { "my-fennel-plugin", dependencies = { "codebeige/rig.nvim" } }
```

### Neovim Configuration

If you plan to write your own neovim configuration in fennel, the setup is a
little bit more involved. We need to make sure the code is downloaded for
bootstrapping before the first `require` that loads any fennel code.

The following example shows a more advanved setup including [`lazy.nvim`][4],
but this is *not* a requirement.

```lua
-- $XDG_CONFIG_HOME/nvim/init.lua

function fetch(repo, path)
  local url = "https://github.com/" .. repo .. ".git"
  if not vim.loop.fs_stat(path) then
    print("Fetching " .. url .. "...")
    local result = vim.system(
      {
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        url,
        path,
      }, { text = true }
    ):wait()
    if result.code == 0 then
      print("Successfully installed " .. repo .. " at " .. path .. ".")
    else
      error("Error [" .. result.code .. "]: " .. result.stderr)
    end
  end
end

local rig_plugin_dir = vim.fn.stdpath("data") .. "/lazy/rig.nvim"
fetch("codebeige/rig.nvim", rig_plugin_dir)
dofile(rig_plugin_dir .. "/build.lua")

vim.opt.rtp:prepend(rig_plugin_dir)
require("rig").setup()

-- we are all set, you can safely require fennel code here
require("config.base").setup()

-- load, configure, and update your plugins (including rig.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
fetch("folke/lazy.nvim", lazypath)
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  checker = { enabled = true },
})
```

### Configuration

By default, rig.nvim will use the provided fennel version from
`lib/fennel.lua`. You can easily change that by populating the
`RIG_NVIM_FENNEL` environment variable with a path to any other `fennel.lua`
source file.

```sh
export RIG_NVIM_FENNEL=~/.luarocks/share/lua/5.1/fennel.lua
```

## How does it work?

Sourcing `fennel.lua` takes by far the biggest toll on startup performance.
This is why rig.nvim defers loading the compiler until absolutely necessary.

Very much like with [`vim.loader`][3], this is achieved by hooking into
`package.loaders` and managing a cache of previously compiled lua chunks in
binary format. Most of the time, i.e. when there are no changes to the fennel
source files, we can even bypass fennel completely during startup.

All of this is completely transparent to the user, though. Neovim will always
load and compile the most recent version of any fennel source file. `require`
just works as expected.

## Alternatives

Why implement yet another solution when several good options are already out
there? Ultimately, it boils down to personal preference and a genuine desire to
fully comprehend the trade-offs involved in different approaches.

* [aniseed](https://github.com/Olical/aniseed)
* [hotpot](https://github.com/rktjmp/hotpot.nvim)
* [nfnl](https://github.com/Olical/nfnl)
* [tangerine](https://github.com/udayvir-singh/tangerine.nvim)

---
Copyright ©2024 Tibor Claassen under the [MIT License](LICENSE)

[1]: https://fennel-lang.org
[2]: https://neovim.io
[3]: https://neovim.io/doc/user/lua.html#_lua-module:-vim.loader
[4]: https://github.com/folke/lazy.nvim
