(local cache (require :rig.cache))
(local path (require :rig.path))

(local default-fennel-path
  (path.prepend vim.env.FENNEL_PATH
                "./?.fnl"
                "./?/init.fnl"))

(fn readable? [f]
  (< 0 (vim.fn.filereadable f)))

(fn find-in-fennel-path [module-name]
  (let [fennel-path (or (?. package.loaded :fennel :path) default-fennel-path)]
    (accumulate [(f errors) (values nil "")
                 _ p (ipairs (vim.split fennel-path ";" {:plain true}))
                 &until f]
      (let [f* (vim.fn.expand (path.expand module-name p))]
        (if (readable? f*)
          f*
          (values nil (.. errors "\n\tno file '" f* "'")))))))

(fn find-in-runtime-path* [module-name ...]
  (accumulate [(f errors) (values nil "")
               _ pattern (ipairs [...])
               &until f]
    (let [path (path.expand module-name pattern)]
      (case (vim.fn.globpath vim.o.runtimepath path false true)
        [f] f
        [] (values nil (.. errors "\n\tno file on runtimepath '" path "'"))))))

(fn find-in-runtime-path [module-name]
  (find-in-runtime-path* module-name
                         "fnl/?.fnl"
                         "fnl/?/init.fnl"))

(fn find-macro-in-runtime-path [module-name]
  (find-in-runtime-path* module-name
                         "fnl/?.fnl"
                         "fnl/?/init-macros.fnl"
                         "fnl/?/init.fnl"))

(fn fennel-searcher [module-name]
  (case (find-in-fennel-path module-name)
    f (values (cache.loadfile f {: module-name}) f)
    (nil err) err))


(fn rtp-searcher [module-name]
  (case (find-in-runtime-path module-name)
    f (values (cache.loadfile f {: module-name}) f)
    (nil err) err))

(fn rtp-macro-searcher [module-name]
  (case (find-macro-in-runtime-path module-name)
    f (values (cache.loadfile f {: module-name :env :_COMPILER}) f)
    (nil err) err))

{: fennel-searcher
 : rtp-searcher
 : rtp-macro-searcher}
