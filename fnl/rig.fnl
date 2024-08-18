(local bootstrap (require :rig.bootstrap))

(fn index-of [xs x]
  (accumulate [i 0 i* x* (ipairs xs) &until (< 0 i)]
    (if (= x x*) i* 0)))

(fn remove! [xs x]
  (case (index-of xs x)
    (where i* (< 0 i*)) (table.remove xs i*)))

(fn insert! [xs i x]
  (while (remove! xs x))
  (table.insert xs i x))

(fn setup []
  (vim.loader.enable)
  (when (not package.preload.fennel)
    (set package.preload.fennel (bootstrap.fennel-loader)))
  (let [fennel (require :fennel)]
    (insert! package.loaders 2 (bootstrap.package-loader fennel))))

{: setup}
