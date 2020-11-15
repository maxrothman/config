#!/usr/bin/env bb -i -o

; There's probably a better way to do the shebang, but since you can't use command substitution in
; shebangs, I'm stuck with copying the output of `clojure -Spath -Sdeps '{:deps {table {:mvn/version "0.5.0"}}}'`

(ns docker-ps-table
  (:require [clojure.string :refer [split split-lines trim join]]
            [clojure.java.shell :refer [sh]]))


; ---- Text wrapping ----

; Things I have tried for text wrapping that have failed:
; - fold (shell): only breaks on whitespace, or if necessary just breaks in the middle of the word
; - fmt (shell): only a soft wrap, doesn't break long words if necessary
; - Apache Commons WordUtils: not in babashka, and who knoes if it even does better than fold or fmt
; The only satisfactory solution I've seen is Python's textwrap.wrap, so I'm reimblementing it in
; Clojure..
; Ref: https://github.com/python/cpython/blob/3.8/Lib/textwrap.py#L77-L97

(defn tokenize [text]
  ; I've overhauled the tokenizing regex. The original was more focused on English prose, with
  ; special cases for em-dashes, hyphenated words, etc. Since this application is more likely to
  ; encounter non-prose identifiers (e.g. "postgres:11.5-alpine") I've made the regex dumber.
  (let [
        ; "#" has to be escaped so it doesn't accidentally start a comment
        breakable ":?$\\#@;></\\\\|+=\\-_~"
        tokenizer (re-pattern (format
          
          "(?x)  # Ignore whitespace and comments in this regex
          ( # any whitespace
            \\s+
          | # a word, possibly followed by a breakable character
            [^\\s%1$s]+ (?: [%1$s]+)?
          | # anything else, e.g a breakable character at the start of a word
            \\S+
          )"
           breakable))]

    (->> (re-seq tokenizer text)
         (map first))))

(defn wrap [width text]
  (letfn [(str-len [ss] (reduce + (map count ss)))
          (inner [[cur-line & lines] new-chunk]
            (cond
              ; If we can fit the next chunk on the current line, stick it on
              (<= (str-len (cons new-chunk cur-line)) width) (cons (cons new-chunk cur-line) lines)
              ; new-chunk is too long on its own, gotta break it in the middle
              (> (count new-chunk) width)
                (let [[pre-split post-split] (split-at (- width (str-len cur-line)) new-chunk)]
                  (conj lines (cons (join pre-split) cur-line) (list (join post-split))))
              ; Adding new-chunk onto cur-line would be too long, start a new line
              (> (str-len (cons new-chunk cur-line)) width)
                ; Don't start a line with whitespace, and remove whitespace from the end of lines
                ; Chunks are all-whitespace or no-whitespace, so there's no way the prior cond could
                ; end up starting a line with whitespace.
                (let [whitespace #"\s"
                      new-line (if (re-matches whitespace new-chunk) '() (list new-chunk))
                      cur-line-trimmed (if (re-matches whitespace (first cur-line)) (rest cur-line) cur-line)]
                  (conj lines cur-line-trimmed new-line))))]

    (->> (tokenize text)
         (reduce inner '(()))
         ; Since we were prepending chunks as we encountered them, all of the chunks in the lines
         ; are in reverse order and the lines themselves are in reverse order
         (map reverse)
         reverse
         (map join))))


; ---- And now, the main attraction ----

(defn transpose [x] (partition (count x) (apply interleave x)))

(defn distribute-width
  "Given a list of original widths, distribute max-width among them such that
   each final width is equal to or less than the original, and all final widths
   less than their originals are the same."
  [max-width orig-widths]
  (let [orig-widths (vec orig-widths)]  ; We need to be able to use "get" on orig-widths
   (loop [widths (-> orig-widths count (repeat 0) vec)
         [col-index & indices] (-> orig-widths count range cycle)
         width-left max-width]
    (let [satisfied (map #(>= (get widths %) (get orig-widths %)) (range (count widths)))]
      (cond
        (or (every? true? satisfied) (zero? width-left)) widths
        (get satisfied col-index) (recur widths indices width-left)
        :else (recur (update widths col-index inc) indices (dec width-left)))))))

(defn pad-right [width padding text]
  (join (take width (concat text (repeat padding)))))

(defn join-table-row
  "Takes a table row, each cell of which might contain multiple terminal lines,
   and returns a list of terminal lines with empty strings as placeholders
   where a table column is empty"
  [data]
  (let [term-rows-needed (apply max (map count data))]
    (->> data
         (map #(concat % (repeat "")))
         (map #(take term-rows-needed %))
         transpose)))

(defn get-term-width []
  ; This hack courtesy of https://github.com/trptcolin/reply/issues/75#issuecomment-7198393
  (-> (sh "/bin/sh" "-c" "stty size < /dev/tty")  ; outputs something like "49 97\n", where 97 is the width of the terminal
      :out
      trim
      (split #" ")
      second
      Integer/parseInt))

(defn deepmap
  "Map f through a nested collection coll n levels deep
   
   (deepmap 2 #(+ 1 %) [[1 2] [3 4]]) => [[2 3] [4 5]]
   (deepmap 2 concat [['a' 'b'] ['c' 'd']] [['e' 'f'] ['g' 'h']]) => [['ae' 'bf'] ['cg' 'dh']]"
  [n f & colls]
  (apply ((apply comp (repeat n #(partial map %))) f) colls))

(defn spy-args [f]
  (fn [& args] (prn args) (apply f args)))

;; These functions constitute an abstract interface over the type (Table a).
;; The table is currently stored as a collection of rows, but that could be
;; changed if a constructor were added.
;;
;; Examples:
;;   (map-values #(+ 1 %) [[1 2] [3 4]])
;;   => ((2 3) (4 5))
;;   
;;   (map-rows #(map (partial + %2) %1) [[1 2] [3 4]] [0 10])
;;   => ((1 2) (13 14))
;;   
;;   (map-cols #(map (partial + %2) %1) [[1 2] [3 4]] [0 10])
;;   => ((1 12) (3 14))

(defn map-rows [f table & colls]
  (apply map f table colls))

(defn map-cols [f table & colls]
  (transpose (apply map f (transpose table) colls)))

(defn map-values [f table]
  (deepmap 2 f table))

(defn cols [table]
  (transpose table))

;; -----------------

(def col-sep-width (count " | "))

(defn trace [x] (prn x) x)

(defn fmt-horizontal-sep
  "Return a horizontal separator string that consists of a number of
   straight-chars equal to each of the numbers in col-widths joined by cross-chars"
  [col-widths straight-char cross-char]
  (->> col-widths
       (map #(repeat % straight-char))
       (map #(join %))
       (join cross-char)))

(defn docker-ps-table []
  (let [;; parsed :: Table String
        parsed (->> ["docker" "ps" "--format"
                     "table {{.ID}},{{.Names}},{{.Image}},{{.Status}},{{.Ports}}"]
                    ;; Run the command and get the output
                    (apply sh)
                    :out
                    split-lines  ; Split into lines
                    (map #(split % #",")))  ; Split into columns

        ;; Reserve space for fancy column separators. -1 because only printing internal table
        ;; separators, if we printed separators around the whole table we'd subtract (count "| ") twice
        max-table-width (- (get-term-width) (* col-sep-width (-> parsed cols count (- 1))))

        ; Wrap table columns to fit the terminal
        desired-widths (distribute-width
                        max-table-width
                        ;; Width of each column
                        ;; Types     Table Long      [[Long]]  [Long]
                        (->> parsed (map-values count) cols (map #(apply max %))))

        ;; Wrapping has to happen before we render the rest of the table so we can get the final
        ;; column widths
        ;; wrapped :: Table (List String)
        wrapped (map-cols #(map (partial wrap %2) %1) parsed desired-widths)

        ;; We need the final column widths in a few different places, they might be different from
        ;; the desired widths if a word didn't exactly match up with the max line length

        col-widths (->> wrapped                      ; :: Table (List String)
                        (map-values #(map count %))  ; :: Table (List Long)
                        (map-values #(apply max %))  ; :: Table Long
                        cols                         ; :: List (Column Long)
                        (map #(apply max %)))        ; :: List Long

        ; TODO: I actually want to pad after joining so that the empty spots have the right width
        ; Padding should happen before adding separators but after joining, but adding separators
        ; should happen before joining. Impossible!
        ; The conflict, visualized:
        ; joining -> padding -> seps
        ; seps -> joining
        ; Conclusion: the approach of applying these computations across the whole table at once
        ; isn't working. Maybe I can work on a row-by-row or cell-by-cell basis? Yield the sequence
        ; of lines I want to print?
        ; 
        ; A sketch:
        ; (->> table
        ;      (row-mapcat f)
        ;      (join "\n"))
        ; where f =
        ; (->> row  :: Row (List String)
        ;      join-table-row  :: List (Row String)
        ;      (deepmap 2 pad)
        ;      (map #(join "|" %))
        ;      interpose (mk-hsep col-widths)
        ;      (append (mk-hsep col-widths)))
        ;
        ; You'd want to do the same thing but slightly different on the first row for the header
        ; hsep.
        ; mk-hsep should also be a constant, since it'll be the same for every row (except the
        ; first)
        ; Could handle the first row special case with
        ; (row-mapcat f table (cons header-hsep (repeat normal-hsep)))
        ; and have f take the hsep as an arg, but that might be a little indirect. ¯\_(ツ)_/¯
        ;; padded (map-cols #(deepmap 2 (partial pad-right %2 " ") %1) wrapped col-widths)
        ;; joined (mapcat join-table-row padded)
        horizontal-seps (cons
                         (fmt-horizontal-sep col-widths "═" "═╪═")
                         (repeat (fmt-horizontal-sep col-widths "─" "─┼─")))
        fmt-row (fn [hsep row] (concat
                                (->> row                  ; :: Row (List String)
                                     join-table-row       ; :: List (Row String)
                                     (map #(map pad-right col-widths (repeat " ") %))  ; :: List (Row String)
                                     (map #(join " │ " %))) ; :: List String
                                [hsep]))]
    (->> wrapped
         (mapcat fmt-row horizontal-seps)
         butlast  ; Drop the extra hsep at the end
         (join "\n"))))


    ; (->> wrapped
         
    ;      ((fn [in]                           ; Pad to the widest value in each column. Table might not take up all horizontal space
    ;        (let [max-widths (max-col-widths in)]
    ;          (map #(map pad-right max-widths (repeat " ") %) in))))
    ;     ;  ((fn [in]                           
    ;     ;    (let [[[fst] rst] (split-at 1 in)]
    ;     ;      (conj rst (->> fst (map count) (map #(join (repeat % "═")))) fst))))
    ;      (map #(join " │ " %))               ; Insert column separators
    ;     trace
    ;      ((fn [in]                           ; Insert row separators
    ;        (let [width (count (first in))   ; Widths are the same on every column, so we can just count the first
    ;              header-sep (repeat width "═")
    ;              other-sep (repeat width "─")])))
    ;         ; TODO: this approach isn't working, we can't build the table with threading like this.
    ;         ; The rows containing horizontal separators need "┼" as their separator, but the rest
    ;         ; need "│". Also, the headers need "╪". If we join columns before inserting horizontal
    ;         ; separators, then the vertical separators will be wrong. If we insert horizontal
    ;         ; separators first, then we'll have to detect whether we're on a data row or a separator
    ;         ; row when joining columns, which is ugly. Better to separate this all out
    ;      (join "\n"))
; TODO
; Because desired-widths are decided before wrapping, and I'm padding to the desired width, padding
; doesn't take wrapping into account, so we can end up with tables like this:
;
; CONTAINER ID NAMES                IMAGE               STATUS           PORTS
; 3bfad3d6e794 bifrost_postgres-    postgres:11.5-      Up About an hour 0.0.0.0:15434->
;              bifrost_1            alpine                               5432/tcp
; c1cc28ddefcd bengal_postgres-     postgres:11.5-      Up About an hour 0.0.0.0:15432->
;              sponsor_1            alpine                               5432/tcp
; a7db7e518dfb bengal_postgres-     postgres:11.5-      Up About an hour 0.0.0.0:15433->
;              site-us_1            alpine                               5432/tcp
;
; The extra space after the NAMES and IMAGE column is unnecessary, it'd be nice to redistribute it.
; What does texttable do?

; TODO: fancier table drawing

(docker-ps-table)
; (prn (join-table-row '(("a7db7e518dfb") ("bengal_postgres-site-" "us_1") ("postgres:11.5-alpine") ("Up 53 minutes") ("0.0.0.0:15433->5432/" "tcp"))))
; (prn (tokenize "postgres:11.5-alpine"))

; (->> (wrap 15 "Look, goof-ball -- use the -b option!")
;      trace)
; (->> (wrap 10 "asdfasdfasdfasdfasdfasdf")
;       trace)
    
; TODO
; - figure out how to build text lines out of possibly-multiline table cells

; Wrapping columns
; 1) Pick widths for the columns


; 2) Wrap columns to those widths


; 3) Draw wrapped columns (https://github.com/foutaise/texttable/blob/master/texttable.py)


; 4) PR to https://github.com/cldwalker/table (?)
