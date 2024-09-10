(fn with-env [?opts]
  (let [{: scope} (require :fennel)
        {: current-global-names
         : make-compiler-env
         : scopes
         : wrap-env} (require :fennel.specials)
        opts (or ?opts {})
        compiler-env? (= :_COMPILER opts.env)
        env (if compiler-env?
              (make-compiler-env nil scopes.compiler {} opts)
              (or opts.env _G))]
    (let [o (collect [k v (pairs opts)] k v)]
      (set o.env (wrap-env env))
      (set o.allowedGlobals (current-global-names env))
      (when compiler-env?
        (set o.requireAsInclude false)
        (set o.scope (scope scopes.compiler)))
      o)))

(fn load* [src ?opts]
  (let [{: compile-string} (require :fennel)
        {: env &as opts} (with-env ?opts)]
     (-> (compile-string src opts)
         (load (.. "@" opts.filename) :t env))))

{:load load*}
