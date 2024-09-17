# ⛵️ rig.nvim

First-class [fennel][1] support inside [neovim][2].

This plugin allows you to import fennel modules from `fennel.path` or any
`fnl/` directory on your runtime path. It works just the same as requiring lua
code from `package.path` or a `lua/` directory accordingly.

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
