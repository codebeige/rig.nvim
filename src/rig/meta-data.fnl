(local meta-data-key :__rig_metadata)

(fn make-meta-data-table []
  "Create a weak table in global scope for storing meta-data.

  Values persist reloading chunks and will automatically be garbage collected
  together with the targets."
  (let [t {}]
    (setmetatable t {:__mode :k})
    (rawset _G meta-data-key t)
    t))

(local meta-data
  (or (rawget _G meta-data-key)
      (make-meta-data-table)))

(fn set* [x t]
  "Update meta-data attached to x."
  (tset meta-data x t))

(fn get [x]
  "Get meta-data for x."
  (. meta-data x))

{: get :set set*}
