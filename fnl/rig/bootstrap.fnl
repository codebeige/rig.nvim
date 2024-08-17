(fn inject-fennel-loader []
  (when (not package.preload.fennel)
    (let [fennel-src (or vim.env.RIG_NVIM_FENNEL
                         (vim.fn.globpath vim.o.runtimepath "lib/fennel.lua"))]
      (set package.preload.fennel (loadfile fennel-src)))))

(fn enable-fennel []
  (vim.loader.enable)
  (let [fennel (require :fennel)]
    (table.insert package.loaders 2 fennel.searcher)
    ; TODO: inject rtp module loader
    ))

{: enable-fennel
 : inject-fennel-loader}
