(fn index-of [xs x]
  (accumulate [i 0 i* x* (ipairs xs) &until (< 0 i)]
    (if (= x x*) i* 0)))

(fn remove! [xs x]
  (case (index-of xs x)
    (where i* (< 0 i*)) (table.remove xs i*)))

(fn insert! [xs i x]
  (while (remove! xs x))
  (table.insert xs i x))

(local src (-> (debug.getinfo 1) (. :source) (vim.fs.root :Makefile)))
(local path (partial vim.fs.joinpath src))

(fn load-fennel []
  (let [src (or vim.env.RIG_NVIM_FENNEL (path "lib/fennel.lua"))]
    (dofile src)))

(fn module-path [module-name]
  (let [fragments (vim.split module-name "." {:plain true})]
    (vim.fs.joinpath "fnl" (unpack fragments))))

(fn rtp-file [path]
  (vim.print "RTP" path)
  (case (vim.fn.globpath vim.o.runtimepath path false true)
    [f] (doto f (vim.print))))

(fn rtp-searcher [module-name]
  (let [p (module-path module-name)]
    (case (or (rtp-file (.. p ".fnl"))
              (rtp-file (vim.fs.joinpath p "init.fnl")))
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
