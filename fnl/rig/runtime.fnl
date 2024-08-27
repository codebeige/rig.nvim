(local fennel (require :fennel))
(local view (require :fennel.view))
(local compiler (require :fennel.compiler))
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
      f (values #(fennel.dofile f) f)
      (nil err) err)))

(fn copy [t]
  (vim.tbl_extend :keep t {}))

(fn safe-getmetatable [t]
  (let [mt (getmetatable t)
        str-mt (getmetatable "")]
    (assert (not= str-mt mt)
            "Can't access string metatable in compiler sandbox.")
    mt))

(fn safe-fennel-module [module-name]
  (if (or (= :fennel.macros module-name)
          (and (= :table (type (?. package.loaded module-name)))
               (= compiler.metadata (?. package.loaded module-name :metadata))))
    {: view :metadata {:setall (fn [_ ...] (compiler.metadata:setall ...))}}))


(fn load-macro-module [module-name]
  (let [m (accumulate [m nil
                       _ search (ipairs fennel.macro-searchers)
                       &until m]
            (case (search module-name)
              (loader filename) (loader module-name filename)))]
    (assert m (.. "Module not found: " module-name))
    (set (. fennel :macro-loaded module-name) m)
    m))

(fn safe-require [module-name]
  (or (. fennel :macro-loaded module-name)
      (safe-fennel-module module-name)
      (load-macro-module)))

(fn make-compiler-sandbox []
  {: _VERSION
   : assert
   : error
   : ipairs
   : next
   : pairs
   : pcall
   : print
   : rawequal
   : rawget
   : rawset
   : select
   : setmetatable
   : tonumber
   : tostring
   : type
   : vim
   : xpcall
   :bit (rawget _G :bit)
   :getmetatable safe-getmetatable
   :math (copy math)
   :rawlen (rawget _G :rawlen)
   :require safe-require
   :string (copy string)
   :table (copy table)})

(fn rtp-macro-searcher [module-name]
  (let [p (module-path module-name)]
    (case (find (.. p ".fnl")
                (vim.fs.joinpath p "init.fnl"))
      f (values #(fennel.dofile f {: module-name
                                   :compiler-env (make-compiler-sandbox)
                                   :env :_COMPILER})
                f))))

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
