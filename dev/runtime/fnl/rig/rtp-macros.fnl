;; fennel-ls: macro-file

(fn p2 [x]
  ; (vim.print "p2")
  `(doto ,x (vim.print " from rtp")))

{: p2}
