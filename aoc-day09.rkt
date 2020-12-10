#lang racket
(require threading
         racket/file
         math/base
         data/collection)

(module+ test
  (require rackunit))

(define (in-windows seq n)
  (for/sequence ([i (range 0 (- (length seq) n))]
                 [j (range n (length seq))])
    (subsequence seq i j)))


(define (find-combination success? n-elements seq)
  (for/first ([e (in-combinations (sequence->list seq) n-elements)]
              #:when (success? e))
    e))

(define (find-inconsistency seq #:previous [previous 25])
  (define (sum-equal-pos? i)
    (λ~> sum (equal? (nth seq i))))
  (for/first ([w (in-windows seq previous)]
              [i (in-naturals previous)]
              #:unless (find-combination (sum-equal-pos? i) 2 w))
    (nth seq i)))


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
