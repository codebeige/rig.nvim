(local bootstrap (require :rig.bootstrap))

(fn setup []
  (bootstrap.inject-fennel-loader)
  (bootstrap.enable-fennel))

{: setup}
