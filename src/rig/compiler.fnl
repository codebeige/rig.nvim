(fn eval-env [env opts]
  (if (= env :_COMPILER)
      (let [env (specials.make-compiler-env nil compiler.scopes.compiler {} opts)]
        ;; re-enable globals-checking; previous globals-checking below doesn't
        ;; work on the compiler env because of the sandbox.
        (when (= opts.allowedGlobals nil)
          (set opts.allowedGlobals (specials.current-global-names env)))
        (specials.wrap-env env))
      (and env (specials.wrap-env env))))

(fn eval-opts [options str]
  (let [opts (utils.copy options)]
    ;; eval and dofile are considered "live" entry points, so we can assume
    ;; that the globals available at compile time are a reasonable allowed list
    (when (= opts.allowedGlobals nil)
      (set opts.allowedGlobals (specials.current-global-names opts.env)))
    ;; if the code doesn't have a filename attached, save the source in order
    ;; to provide targeted error messages.
    (when (and (not opts.filename) (not opts.source))
      (set opts.source str))
    (when (= opts.env :_COMPILER)
      (set opts.scope (compiler.make-scope compiler.scopes.compiler)))
    opts))

(fn eval [str ?options ...]
  (let [opts (eval-opts ?options str)
        env (eval-env opts.env opts)
        lua-source (compiler.compile-string str opts)
        loader (specials.load-code lua-source env
                                   (if opts.filename
                                       (.. "@" opts.filename)
                                       str))]
    (set opts.filename nil)
    (loader ...)))






(fn compile [src src-path]
  (let [{: compile-string} (require :fennel)]
    (compile-string src {:filename src-path})))

{: compile}
