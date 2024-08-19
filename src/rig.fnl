(fn index-of [xs x]
  (accumulate [i 0 i* x* (ipairs xs) &until (< 0 i)]
    (if (= x x*) i* 0)))

(fn remove! [xs x]
  (case (index-of xs x)
    (where i* (< 0 i*)) (table.remove xs i*)))

(fn insert! [xs i x]
  (while (remove! xs x))
  (table.insert xs i x))

(fn load-fennel []
  (let [src (or vim.env.RIG_NVIM_FENNEL
                (vim.fn.globpath vim.o.runtimepath "lib/fennel.lua"))]
    (dofile src)))

(local dir-separator (package.config:sub 1 1))
(local fennel-dir "fnl")

(fn module-path [module-name]
  (let [fragments (vim.split module-name "." {:plain true})]
    (table.insert fragments 1 fennel-dir)
    (table.concat fragments dir-separator)))

(fn rtp-file [path]
  (case (vim.fn.globpath vim.o.runtimepath path false true)
    [f] f))

(fn rtp-searcher [module-name]
  (let [p (module-path module-name)]
    (case (or (rtp-file (.. p ".fnl"))
              (rtp-file (.. p dir-separator "init.fnl")))
      f #(let [fennel (require :fennel)]
           (fennel.dofile f)))))

(fn setup []
  (vim.loader.enable)
  (when (not package.preload.fennel)
    (set package.preload.fennel load-fennel))
  (let [fennel (require :fennel)]
    (insert! package.loaders 2 rtp-searcher)
    (insert! package.loaders 3 fennel.searcher)))

{: setup}
