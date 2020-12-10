#lang racket
(require threading
         racket/file
         data/collection
         "utils.rkt")

(module+ test
  (require rackunit))

(define (difference-in-jolts-1-3 seq)
  (define (diff ab) (- (second ab) (first ab)))
  (define new-seq (extend seq (list 0 (+ 3 (maximum seq)))))
  (define sorted-seq (sort new-seq <))
  (define ones
    (sequence-count (λ (w) (one? (diff w)))
                    (in-windows 2 sorted-seq)))
  (define threes
    (sequence-count (λ (w) (three? (diff w)))
                    (in-windows 2 sorted-seq)))
  (* ones threes))



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
  (check-equal? (difference-in-jolts-1-3 test-adapters-large) 220))

(~> "./aoc-day10.input"
    file->list
    difference-in-jolts-1-3)
