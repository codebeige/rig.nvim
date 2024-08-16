(fn inject-fennel-loader []
  (when (not package.preload.fennel)
    (let [fennel-src (or vim.env.RIG_NVIM_FENNEL
                         (vim.fn.globpath vim.o.runtimepath "lib/fennel.lua"))]
      (set package.preload.fennel (loadfile fennel-src)))))

(fn enable-fennel []
  (let [fennel (require :fennel)]
    (print fennel.version)
    ; TODO: inject module loaders
    ))

{: enable-fennel
 : inject-fennel-loader}
