(fn index-of [xs x]
  "Returns integer position of first occurence of x inside sequence xs.

  Returns nil if sequence xs does not contain item x."
  (accumulate [i 0 i* x* (ipairs xs) &until (< 0 i)]
    (if (= x x*) i* 0)))

(fn remove! [xs x]
  "Remove all occurences of item x by mutating sequence xs.

  Returns removed item x when it was previously present in sequence xs."
  (case (index-of xs x)
    (where i* (< 0 i*)) (table.remove xs i*)))

(fn insert-at! [xs i x]
  "Insert item x at position i by mutating sequence xs.

  Ensures that x is present exactly once at the given position. All other
  occurences are removed. Returns sequence xs for chaining."
  (while (remove! xs x))
  (table.insert xs i x)
  xs)

(fn append! [xs x]
  "Insert item x after last item in sequence xs.

  Ensures that x is present exactly once as the last item. All other occurences
  are removed. Returns sequence xs for chaining."
  (insert-at! xs (+ 1 (length xs)) x))

(fn prepend! [xs x]
  "Insert item x at beginning of sequence xs.

  Ensures that x is present exactly once as the first item. All other
  occurences are removed. Returns sequence xs for chaining."
  (insert-at! xs 1 x))

{: append!
 : index-of
 : insert-at!
 : prepend!
 : remove!}
