#lang racket
(require threading
         racket/file
         math/number-theory
         data/collection
         "utils.rkt")

(module+ test
  (require rackunit))

; Append first and last, then sort
(define (prepare-adapters seq)
  (define new-seq (extend seq (list 0 (+ 3 (maximum seq)))))
  (sort new-seq <))

(define (diff ab) (- (second ab) (first ab)))

(define (diffs seq)
  (define sorted-seq (prepare-adapters seq))
  (for/list ([w (in-windows 2 sorted-seq)])
    (diff w)))


(define (difference-in-jolts-1-3 seq)
  (define differences (diffs seq))
  (* (count one? differences)
     (count three? differences)))

(define (jolt-combinations seq)
  ;; Probabilities are:
  ;; All combinations possible for removing one element
  ;; Minus the probability of 3 sequential removals
  ;; 2^n - 2^(n-3)
  (define/match (jolt-combos n)
    [(1) 2] ;; One element between 2. It can be there or not.
    [(2) 4] ;; Two elements at 1 distance. We have 4 ways.
    [(n) (- (expt 2 n) ;; More elements
            (expt 2 (- n 3)))])
  (~>> (diffs seq)        ;; Differences in sequences
       (in-groups one?)   ;; Consecutives ones
       (map length)       ;; Size of each groups
       (map sub1)         ;; Actual number or "free" slots
       (filter positive?) ;; No "free" slots, no calc
       (map jolt-combos)  ;; Combinations for each group
       prod))             ;; Multiply combinations

(module+ test
  (define test-adapters-short
    '(16
      10
      15
      5
      1
      11
      7
      19
      6
      12
      4))
  (define test-adapters-large
    '(28
      33
      18
      42
      31
      14
      46
      20
      48
      47
      24
      23
      49
      45
      19
      38
      39
      11
      1
      32
      25
      35
      8
      17
      7
      9
      4
      2
      34
      10
      3))
  (check-equal? (difference-in-jolts-1-3 test-adapters-short) 35)
  (check-equal? (difference-in-jolts-1-3 test-adapters-large) 220)
  (check-equal? (jolt-combinations test-adapters-short) 8)
  (check-equal? (jolt-combinations test-adapters-large) 19208))


(define (answer strategy)
  (~> "./aoc-day10.input"
      file->list
      strategy))

(printf "Day 10 - star 1: ~a\n" (answer difference-in-jolts-1-3))
(printf "Day 10 - star 2: ~a\n" (answer jolt-combinations))
