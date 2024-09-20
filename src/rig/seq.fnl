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

(fn first [xs]
  "Return the first item from the sequence xs.

  Returns nil when xs is empty or nil."
  (. (or xs []) 1))

(fn rest [xs n]
  "Return a sequence of all remaining items after the first or n items."
  (icollect [i x (ipairs xs)] (if (< (or n 1) i) x)))

(fn take [xs n]
  "Create a new sequence of the first n items from the sequence xs."
  (icollect [i x (ipairs xs)] (if (>= n i) x)))

(fn concat [...]
  {:fnl/docstring
   "Create a single sequence from all items in xs, ys, and more.

   Returns an empty sequence when called with no arguments. Returns a copy of
   xs when called with a single argument."
   :fnl/arglist [xs ys & more]}
  (case (values (select :# ...) ...)
    (0) []
    (1 xs) (icollect [_ x (ipairs xs)] x)
    (2 xs ys) (icollect [_ y (ipairs ys) &into (concat xs)] y)
    (_ xs ys) (concat (concat xs ys) (select 3 ...)))) ; TODO: wrap with tail!

(fn append [xs ...]
  {:fnl/docstring
   "Return a sequence with item x (and optionally more) added the end of all
   items in xs."
   :fnl/arglist [xs x & more]}
  (concat xs [...]))

(fn prepend [xs ...]
  {:fnl/docstring
   "Return a sequence from item x (and optionally more) followed by all items
   in xs."
   :fnl/arglist [xs x & more]}
  (concat [...] xs))

(fn insert [xs i ...]
  {:fnl/docstring
   "Return a sequence with item x (and optionally more) inserted at position i
   of the sequence xs."
   :fnl/arglist [xs i x & more]}
  (let [n (- i 1)]
    (concat (take xs n) [...] (rest xs n))))

(fn filter [xs f]
  "Return a new sequence with items from xs for which (f x) is truthy."
  (icollect [_ x (ipairs xs)] (if (f x) x)))

(fn remove [xs f]
  "Return a new sequence without items from xs for which (f x) is truthy."
  (filter xs #(not (f $1))))

{: append
 : append!
 : concat
 : filter
 : first
 : index-of
 : insert
 : insert-at!
 : prepend
 : prepend!
 : remove
 : remove!
 : rest}
