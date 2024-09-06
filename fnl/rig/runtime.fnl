(local fennel (require :fennel))
(local cache (require :rig.cache))
(local compiler (require :rig.compiler))
(local path (require :rig.path))
(local seq (require :rig.sequence))

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
      f (values (cache.loadfile f) f)
      (nil err) err)))

(fn rtp-macro-searcher [module-name]
  (let [p (module-path module-name)]
    (case (find (.. p ".fnl")
                (vim.fs.joinpath p "init.fnl"))
      f (values (cache.loadfile f (compiler.make-env)) f))))

(fn install []
  "Insert nvim runtimepath searchers into package.loaders table.

  The operation is idempotent. Previously inserted instances of runtimepath
  searchers are removed before inserting. Returns table package.loaders."

  (set fennel.path
       (path.prepend fennel.path
                     (vim.fs.joinpath "." "?.fnl")
                     (vim.fs.joinpath "." "?" "init.fnl")
                     (vim.fs.joinpath "." "fnl" "?.fnl")
                     (vim.fs.joinpath "." "fnl" "?" "init.fnl")))

  (set fennel.macro-path
       (path.prepend fennel.macro-path
                     (vim.fs.joinpath "." "?.fnl")
                     (vim.fs.joinpath "." "?" "init.fnl")
                     (vim.fs.joinpath "." "?" "init-macros.fnl")
                     (vim.fs.joinpath "." "fnl" "?.fnl")
                     (vim.fs.joinpath "." "fnl" "?" "init.fnl")
                     (vim.fs.joinpath "." "fnl" "?" "init-macros.fnl")))

  (seq.append! fennel.macro-searchers rtp-macro-searcher)
  (seq.insert-at! package.loaders 5 rtp-searcher))

{: install}
