;; fennel-ls: macro-file

(fn p2 [x]
  `(doto ,x (vim.print " from rtp")))

{: p2}
