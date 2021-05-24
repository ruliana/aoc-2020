;; --- Day 11: Seating System ---

;; Your plane lands with plenty of time to spare. The final leg of your journey
;; is a ferry that goes directly to the tropical island where you can finally start
;; your vacation. As you reach the waiting area to board the ferry, you realize
;; you're so early, nobody else has even arrived yet!

;; By modeling the process people use to choose (or abandon) their seat in the
;; waiting area, you're pretty sure you can predict the best place to sit. You make
;; a quick map of the seat layout (your puzzle input).

;; The seat layout fits neatly on a grid. Each position is either floor (.), an
;; empty seat (L), or an occupied seat (O). For example, the initial seat layout
;; might look like this:

;; L.LL.LL.LL
;; LLLLLLL.LL
;; L.L.L..L..
;; LLLL.LL.LL
;; L.LL.LL.LL
;; L.LLLLL.LL
;; ..L.L.....
;; LLLLLLLLLL
;; L.LLLLLL.L
;; L.LLLLL.LL

;; Now, you just need to model the people who will be arriving shortly.
;; Fortunately, people are entirely predictable and always follow a simple set of
;; rules. All decisions are based on the number of occupied seats adjacent to a
;; given seat (one of the eight positions immediately up, down, left, right, or
;; diagonal from the seat). The following rules are applied to every seat
;; simultaneously:

;; If a seat is empty (L) and there are no occupied seats adjacent to it, the seat
;; becomes occupied.
;; If a seat is occupied (O) and four or more seats adjacent to it are also
;; occupied, the seat becomes empty.  Otherwise, the seat's state does not change.
;; Floor (.) never changes; seats don't move, and nobody sits on the floor.

;; After one round of these rules, every seat in the example layout becomes
;; occupied:

;; O.OO.OO.OO
;; OOOOOOO.OO
;; O.O.O..O..
;; OOOO.OO.OO
;; O.OO.OO.OO
;; O.OOOOO.OO
;; ..O.O.....
;; OOOOOOOOOO
;; O.OOOOOO.O
;; O.OOOOO.OO

;; After a second round, the seats with four or more occupied adjacent seats become
;; empty again:

;; O.LL.LO.OO
;; OLLLLLL.LO
;; L.L.L..L..
;; OLLL.LL.LO
;; O.LL.LL.LL
;; O.LLLLO.OO
;; ..L.L.....
;; OLLLLLLLLO
;; O.LLLLLL.L
;; O.OLLLL.OO

;; This process continues for three more rounds:

;; O.OO.LO.OO
;; OLOOOLL.LO
;; L.O.O..O..
;; OLOO.OO.LO
;; O.OO.LL.LL
;; O.OOOLO.OO
;; ..O.O.....
;; OLOOOOOOLO
;; O.LLOOOL.L
;; O.OLOOO.OO
;; O.OL.LO.OO
;; OLLLOLL.LO
;; L.L.L..O..
;; OLLL.OO.LO
;; O.LL.LL.LL
;; O.LLOLO.OO
;; ..L.L.....
;; OLOLLLLOLO
;; O.LLLLLL.L
;; O.OLOLO.OO
;; O.OL.LO.OO
;; OLLLOLL.LO
;; L.O.L..O..
;; OLOO.OO.LO
;; O.OL.LL.LL
;; O.OLOLO.OO
;; ..L.L.....
;; OLOLOOLOLO
;; O.LLLLLL.L
;; O.OLOLO.OO

;; At this point, something interesting happens: the chaos stabilizes and further
;; applications of these rules cause no seats to change state! Once people stop
;; moving around, you count 37 occupied seats.

;; Simulate your seating area by applying the seating rules repeatedly until no
;; seats change state. How many seats end up occupied?

;; Your puzzle answer was [spoiler].

;; The first half of this puzzle is complete! It provides one gold star: *

;; --- Part Two ---

;; As soon as people start to arrive, you realize your mistake. People don't just
;; care about adjacent seats - they care about the first seat they can see in each
;; of those eight directions!

;; Now, instead of considering just the eight immediately adjacent seats, consider
;; the first seat in each of those eight directions. For example, the empty seat
;; below would see eight occupied seats:

;; .......O.
;; ...O.....
;; .O.......
;; .........
;; ..OL....O
;; ....O....
;; .........
;; O........
;; ...O.....

;; The leftmost empty seat below would only see one empty seat, but cannot see any
;; of the occupied ones:

;; .............
;; .L.L.O.O.O.O.
;; .............

;; The empty seat below would see no occupied seats:

;; .OO.OO.
;; O.O.O.O
;; OO...OO
;; ...L...
;; OO...OO
;; O.O.O.O
;; .OO.OO.

;; Also, people seem to be more tolerant than you expected: it now takes five or
;; more visible occupied seats for an occupied seat to become empty (rather than
;; four or more from the previous rules). The other rules still apply: empty seats
;; that see no occupied seats become occupied, seats matching no rule don't change,
;; and floor never changes.

;; Given the same starting layout as above, these new rules cause the seating area
;; to shift around as follows:

;; L.LL.LL.LL
;; LLLLLLL.LL
;; L.L.L..L..
;; LLLL.LL.LL
;; L.LL.LL.LL
;; L.LLLLL.LL
;; ..L.L.....
;; LLLLLLLLLL
;; L.LLLLLL.L
;; L.LLLLL.LL
;; O.OO.OO.OO
;; OOOOOOO.OO
;; O.O.O..O..
;; OOOO.OO.OO
;; O.OO.OO.OO
;; O.OOOOO.OO
;; ..O.O.....
;; OOOOOOOOOO
;; O.OOOOOO.O
;; O.OOOOO.OO
;; O.LL.LL.LO
;; OLLLLLL.LL
;; L.L.L..L..
;; LLLL.LL.LL
;; L.LL.LL.LL
;; L.LLLLL.LL
;; ..L.L.....
;; LLLLLLLLLO
;; O.LLLLLL.L
;; O.LLLLL.LO
;; O.LO.OO.LO
;; OLOOOOO.LL
;; L.O.O..O..
;; OOLO.OO.OO
;; O.OO.OL.OO
;; O.OOOOO.OL
;; ..O.O.....
;; LLLOOOOLLO
;; O.LOOOOO.L
;; O.LOOOO.LO
;; O.LO.LO.LO
;; OLLLLLL.LL
;; L.L.L..O..
;; OOLL.LL.LO
;; L.LL.LL.LO
;; O.LLLLL.LL
;; ..L.L.....
;; LLLLLLLLLO
;; O.LLLLLO.L
;; O.LOLLO.LO
;; O.LO.LO.LO
;; OLLLLLL.LL
;; L.L.L..O..
;; OOLO.OL.LO
;; L.LO.OL.LO
;; O.LOOOO.LL
;; ..O.O.....
;; LLLOOOLLLO
;; O.LLLLLO.L
;; O.LOLLO.LO
;; O.LO.LO.LO
;; OLLLLLL.LL
;; L.L.L..O..
;; OOLO.OL.LO
;; L.LO.LL.LO
;; O.LLLLO.LL
;; ..O.L.....
;; LLLOOOLLLO
;; O.LLLLLO.L
;; O.LOLLO.LO

;; Again, at this point, people stop shifting around and the seating area reaches
;; equilibrium. Once this occurs, you count 26 occupied seats.

;; Given the new visibility method and the rule change for occupied seats becoming
;; empty, once equilibrium is reached, how many seats end up occupied?

#lang racket
(require threading
         srfi/13
         racket/file
         "array-utils.rkt"
         syntax/parse/define)

;; -- Things I'm testing (a.k.a. support code)

(define-syntax-parse-rule (with-context name:id (function:expr ...) body ...+)
  (let ([function (λ args (apply function name args))] ...)
    body ...))

(module+ test
  (require rackunit)
  (define x 1)
  (define (plus a b) (+ a b))
  (with-context x
    [plus]
    (check-equal? (plus 2) 3)))


;; -- Actual code

(module+ test
  (require rackunit)
  (define step-0
    "L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL")
  (define step-1
    "O.OO.OO.OO
OOOOOOO.OO
O.O.O..O..
OOOO.OO.OO
O.OO.OO.OO
O.OOOOO.OO
..O.O.....
OOOOOOOOOO
O.OOOOOO.O
O.OOOOO.OO")
  (define step-2
    "O.LL.LO.OO
OLLLLLL.LO
L.L.L..L..
OLLL.LL.LO
O.LL.LL.LL
O.LLLLO.OO
..L.L.....
OLLLLLLLLO
O.LLLLLL.L
O.OLLLL.OO")
  (check-equal? (step step-0) step-1))
  ;; (check-equal? (step step-1) step-2))


(define (row-count string-matrix)
  (~> string-matrix
      (string-count #\newline)
      add1))

(module+ test
  (check-equal? (row-count "") 1)
  (check-equal? (row-count "abc") 1)
  (check-equal? (row-count "abc\n") 2)
  (check-equal? (row-count "abc\ndef") 2)
  (check-equal? (row-count "abc\ndef\ng") 3))

(define (col-count string-matrix)
  (if (zero? (string-length string-matrix))
      0
      (~> string-matrix
          (string-split "\n" #:trim? #f)
          (map string-length _)
          (apply min _))))

(module+ test
  (check-equal? (col-count "") 0)
  (check-equal? (col-count "ab") 2)
  (check-equal? (col-count "abc\n") 0)
  (check-equal? (col-count "abc\nd") 1)
  (check-equal? (col-count "abc\ndefg") 3)
  (check-equal? (col-count "abc\ndef\nghi") 3))

(define (ref string-matrix row col)
  (let ([cols (col-count string-matrix)])
      (string-ref string-matrix (+ col row (* row cols)))))

(define floor #\.)
(define vacant #\L)
(define occupied #\O)

(define (floor? string-matrix row col) (equal? floor (ref string-matrix row col)))
(define (vacant? string-matrix row col) (equal? vacant (ref string-matrix row col)))
(define (occupied? string-matrix row col) (equal? occupied (ref string-matrix row col)))

(module+ test
  (define string-matrix "abc\ndef\nghi")
  (check-equal? (ref string-matrix 0 0) #\a)
  (check-equal? (ref string-matrix 0 2) #\c)
  (check-equal? (ref string-matrix 1 0) #\d)
  (check-equal? (ref string-matrix 1 1) #\e)
  (check-equal? (ref string-matrix 2 0) #\g)
  (check-equal? (ref string-matrix 2 2) #\i))

(define (neighbors-count string-matrix row col)
  (define row-min (max 0 (sub1 row)))
  (define col-min (max 0 (sub1 col)))
  (define row-max (min (+ 2 row) (row-count string-matrix)))
  (define col-max (min (+ 2 col) (col-count string-matrix)))
  (for*/sum ([c (in-range col-min col-max)]
             [r (in-range row-min row-max)]
             #:when (occupied? string-matrix r c)
             #:unless (and (= r row) (= c col)))
    1))

(module+ test
  (check-equal? (neighbors-count "" 0 0) 0)
  (check-equal? (neighbors-count "O" 0 0) 0)
  (check-equal? (neighbors-count "OO" 0 0) 1)
  (check-equal? (neighbors-count "...\n.O.\n..." 1 1) 0)
  (check-equal? (neighbors-count "...\n.O.\n..." 0 0) 1)
  (check-equal? (neighbors-count "...\n.O.\n..." 2 2) 1)
  (check-equal? (neighbors-count "OOO\nOOO\nOOO" 1 1) 8)
  (check-equal? (neighbors-count "OOO\nOOO\nOOO" 0 2) 3)
  (check-equal? (neighbors-count "OOO\nOOO\nOOO" 2 0) 3)
  (check-equal? (neighbors-count "OLO\nOLO\nOLO" 1 1) 6))


(define (step current-map)
  (with-context current-map
    [floor? vacant? occupied? neighbors-count]
    (string-trim
     (string-append*
      (for/list ([row (in-range (row-count current-map))])
        (string-append
         (list->string
          (for/list ([col (in-range (col-count current-map))])
            (cond
              [(floor? row col) floor]
              [(and (vacant? row col)
                    (zero? (neighbors-count row col))
                    occupied)]
              [(and (occupied? row col)
                    (<= 4 (neighbors-count row col))
                    vacant)]
              [(occupied? row col
                          occupied)])))
         "\n"))))))
