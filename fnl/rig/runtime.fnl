(local fennel (require :fennel))
(local {: insert-at! : prepend!} (require :rig.sequence))

(fn module-path [module-name]
  (let [fragments (vim.split module-name "." {:plain true})]
    (vim.fs.joinpath "fnl" (unpack fragments))))

(fn find [...]
  (accumulate [(f errors) (values nil "")
               _ path (ipairs [...])
               &until f]
    (case (vim.fn.globpath vim.o.runtimepath path false true)
      [f] f
      [] (values nil (.. errors "\n\tno file on runtimepath '" path "'")))))

(fn rtp-searcher [module-name]
  (let [p (module-path module-name)]
    (case (find (.. p ".fnl")
                (vim.fs.joinpath p "init.fnl"))
      f (values #(fennel.dofile f) f)
      (nil err) err)))

(fn rtp-macro-searcher [module-name]
  (let [p (module-path module-name)]
    (case (find (.. p ".fnl")
                (vim.fs.joinpath p "init.fnl"))
      f (values #(fennel.dofile f {: module-name :env :_COMPILER}) f))))

(fn install []
  "Insert nvim runtimepath searchers into package.loaders table.

  The operation is idempotent. Previously inserted instances of runtimepath
  searchers are removed before inserting. Returns table package.loaders."

  (insert-at! package.loaders 2 rtp-searcher)
  (prepend! fennel.macro-searchers rtp-macro-searcher))

{: install}
