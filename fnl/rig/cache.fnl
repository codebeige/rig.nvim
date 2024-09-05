(local fennel (require :fennel))

(local prefix (vim.fs.joinpath (vim.fn.stdpath :cache) :fnlc))

(macro with-file-open [[f open] ...]
  `(let [{:traceback traceback#} (require :fennel)
         ,f (assert ,open)]
     ((fn [ok# ...]
        (vim.uv.fs_close ,f)
        (if ok# ... (error ... 0)))
      (xpcall (fn [] ,...) traceback#))))

(fn read-file [f {: mode : size}]
  (with-file-open [f* (vim.uv.fs_open f :r mode)]
    (vim.uv.fs_read f* size)))

(fn src->fnlc [f]
  (let [src (assert (vim.uv.fs_realpath f))]
    (values (vim.fs.joinpath prefix
                             (-> src (vim.uri_encode :rfc2396) (.. :c)))
            src)))

(fn stat->header [{: size :mtime {: sec : nsec}}]
  (-> [size sec nsec] (table.concat "-") (.. "\0")))

(fn read-chunk [f {: mode &as stat}]
  (case (vim.uv.fs_open f :r mode)
    fd (with-file-open [f* fd]
         (let [header (stat->header stat)
               header-length (length header)]
           (case (vim.uv.fs_read f* header-length)
             (where (= header)) (let [{: size} (vim.uv.fs_fstat f*)
                                      size* (- size header-length)]
                                  (vim.uv.fs_read f* size*)))))))

(fn write-chunk [chunk f {: mode &as stat}]
  (vim.fn.mkdir (vim.fs.dirname f) :p)
  (with-file-open [f* (vim.uv.fs_open f :w mode)]
    (vim.uv.fs_write f* (.. (stat->header stat) (string.dump chunk)))))

(fn loadfile* [f ?env]
  (let [(cache-path src-path) (src->fnlc f)
        stat (vim.uv.fs_stat src-path)
        chunk-name (.. "@" src-path)]
    (case (read-chunk cache-path stat)
      c (load c chunk-name :b ?env)
      _ (-> (read-file src-path stat)
            (fennel.compile-string {:filename src-path})
            (load chunk-name :t ?env)
            (doto (write-chunk cache-path stat))))))

(fn clear []
  (vim.fn.delete prefix :rf))

{: clear
 :loadfile loadfile*}
