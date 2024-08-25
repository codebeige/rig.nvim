(import-macros {: p2} :rig.rtp-macros)

(fn greet []
  (vim.print "HELLO (from rtp)")
  (p2 [1 2 3]))

{: greet}
