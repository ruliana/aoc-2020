#lang racket
(require threading
         racket/file
         math/base
         data/collection)

(module+ test
  (require rackunit))


(define (find-combination n-elements success? seq)
  (for/first ([e (in-combinations (sequence->list seq) n-elements)]
              #:when (success? e))
    e))

(define (find-inconsistency seq #:previous [previous 25])
  (for/first ([i (range 0 (- (length seq) previous))]
              [j (range previous (length seq))]
              #:unless (find-combination
                        2
                        (λ~> sum (equal? (nth seq j)))
                        (subsequence seq i j)))
    (nth seq j)))


(module+ test
  (define test-sequence
    #(35
      20
      15
      25
      47
      40
      62
      55
      65
      95
      102
      117
      150
      182
      127
      219
      299
      277
      309
      576))
  (find-inconsistency test-sequence #:previous 5))


(~> "./aoc-day09.input"
    file->list
    list->vector
    vector->immutable-vector
    (find-inconsistency #:previous 25))
