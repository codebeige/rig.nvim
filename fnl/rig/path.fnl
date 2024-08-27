(local seq (require :rig.sequence))

(local separator (-> package (. :config) (: :sub 3 3)))

(fn join [...]
  "Create path string from fragments."

  {:fnl/arglist [& fragments]}

  (table.concat [...] separator))

(fn split [path]
  "Split path into a sequence of path fragments."

  (vim.split path separator {:plain true}))

(fn remove [path ...]
  "Remove fragments from path string."

  {:fnl/arglist [path & fragments]}

  (let [fs (collect [_ f (ipairs [...])] f true)]
    (-> path split (seq.filter #(. fs $1)) unpack join)))

(fn append [path ...]
  "Append fragments after last element of path string.

  Added fragements are guaranteed to be present exactly once. Strips previously
  existing occurences of a each fragment."

  {:fnl/arglist [path & fragments]}

  (join (remove path ...) ...))

(fn prepend [path ...]
  "Prepend fragments before first element of path string.

  Added fragements are guaranteed to be present exactly once. Strips previously
  existing occurences of a each fragment."

  {:fnl/arglist [path & fragments]}

  (join (join ...) (remove path ...)))

{: append
 : prepend
 : remove}
