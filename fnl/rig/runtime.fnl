(local {: insert!} (require "rig.seq"))

(fn module-path [module-name]
  (let [fragments (vim.split module-name "." {:plain true})]
    (vim.fs.joinpath "fnl" (unpack fragments))))

(fn find [path]
  (case (vim.fn.globpath vim.o.runtimepath path false true)
    [f] (doto f (vim.print))))


(fn rtp-searcher [module-name]
  (let [p (module-path module-name)]
    (case (or (find (.. p ".fnl"))
              (find (vim.fs.joinpath p "init.fnl")))
      f #(let [fennel (require :fennel)]
           (fennel.dofile f)))))

; TODO: error handling & reporting
; TODO: macro-searcher

(fn install []
  (insert! package.loaders 2 rtp-searcher))

{: install}
