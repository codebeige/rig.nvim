(fn load [src ?opts]
  #(let [{: eval} (require :fennel)]
     (eval src ?opts)))

{: load}
