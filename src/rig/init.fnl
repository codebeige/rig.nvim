(local path (require :rig.path))
(local seq (require :rig.seq))
(local {: fennel-searcher
        : rtp-searcher
        : rtp-macro-searcher
        &as searchers} (require :rig.searchers))

(fn find-fennel-src []
  (-> (debug.getinfo 2 :S)
      (. :source)
      (string.sub 2)
      (vim.fs.root "lib/fennel.lua")
      (vim.fs.joinpath "fennel.lua")))

(fn load-fennel [src]
  #(let [fennel (dofile (or src (find-fennel-src)))]
     (set fennel.path
          (path.prepend fennel.path
                        "./?.fnl"
                        "./?/init.fnl"
                        "fnl/?.fnl"
                        "fnl/?/init.fnl"))
     (set fennel.macro-path
          (path.prepend fennel.macro-path
                        "./?.fnl"
                        "./?/init-macros.fnl"
                        "./?/init.fnl"
                        "fnl/?.fnl"
                        "fnl/?/init-macros.fnl"
                        "fnl/?/init.fnl"))
     (set fennel.macro-searchers
          (seq.append fennel.macro-searchers rtp-macro-searcher))
     fennel))

(fn setup []
  (vim.loader.enable)
  (when (not package.preload.fennel)
    (set package.preload.fennel (load-fennel vim.env.RIG_NVIM_FENNEL)))
  (set package.loaders
       (-> package.loaders
           (searchers.insert 5 fennel-searcher)
           (searchers.insert 6 rtp-searcher))))

{: setup}
