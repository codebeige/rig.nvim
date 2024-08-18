(fn fennel-loader []
  (let [src (or vim.env.RIG_NVIM_FENNEL
                (vim.fn.globpath vim.o.runtimepath "lib/fennel.lua"))]
    (loadfile src)))

(fn package-loader [fennel]
  fennel.searcher)

{: fennel-loader
 : package-loader}
