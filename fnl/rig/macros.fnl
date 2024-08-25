;; fennel-ls: macro-file

(fn p [x]
  `(doto ,x vim.print))

{: p}
