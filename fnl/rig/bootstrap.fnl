(fn inject-fennel-loader []
  (when (not package.preload.fennel)
    (let [fennel-src (or vim.env.RIG_NVIM_FENNEL
                         (vim.fn.globpath vim.o.runtimepath "lib/fennel.lua"))]
      (set package.preload.fennel (loadfile fennel-src)))))

(fn index-of [xs x]
  (accumulate [i 0 i* x* (ipairs xs) &until (< 0 i)]
    (if (= x x*) i* 0)))

(fn remove! [xs x]
  (case (index-of xs x)
    (where i* (< 0 i*)) (table.remove xs i*)))

(fn insert! [xs i x]
  (while (remove! xs x))
  (table.insert xs i x))

(fn enable-fennel []
  (vim.loader.enable)
  (let [fennel (require :fennel)]
    (insert! package.loaders 2 fennel.searcher)
    (print "fennel.searcher is at index:" (index-of package.loaders fennel.searcher))
    ; TODO: inject rtp module loader
    ))

{: enable-fennel
 : inject-fennel-loader}
