(local fennel (require :fennel))
(local compiler (require :fennel.compiler))
(local view (require :fennel.view))

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

(fn load-in-sandbox [f module-name]
  #(fennel.dofile f {: module-name
                     :env :_COMPILER
                     :compiler-env (make-compiler-sandbox)}))

{: load-in-sandbox}
