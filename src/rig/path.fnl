(local seq (require :rig.seq))

(local config
  (let [[dir-separator path-separator path-mark]
        (or (-?> package (. :config) (vim.split "\n" {:plain true}))
            ["/" ";" "?"])]
    {: dir-separator : path-separator : path-mark}))

(fn blank? [x]
  (or (= nil x) (= "" x)))

(fn split [path]
  (if (not (blank? path))
    (vim.split path config.path-separator {:plain true})
    []))

(fn join [ps]
  (table.concat ps config.path-separator))

(fn prepend [path ...]
  (let [ps (split path)]
    (each [_ p (ipairs [...])] (seq.prepend! ps p))
    (join ps)))

(fn module->path [module-name]
  (vim.fn.join (vim.split module-name "." {:plain true}) config.dir-separator))

(fn expand [module-name pattern]
  (string.gsub pattern "[?]" (module->path module-name) 1))

{: expand
 : prepend}
