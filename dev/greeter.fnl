(import-macros {: p} :rig.macros)

(fn greet [name]
  (print (.. "Hello " (p name) "! Enjoy fennel inside nvim...")))

{: greet}
