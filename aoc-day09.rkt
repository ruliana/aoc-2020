#lang racket
(require threading
         racket/file
         math/base
         data/collection)

(module+ test
  (require rackunit))

(define (in-windows n seq)
  (for/sequence ([i (range 0 (- (length seq) n))]
                 [j (range n (length seq))])
    (subsequence seq i j)))


(define (find-combination success? n-elements seq)
  (for/first ([e (in-combinations (sequence->list seq) n-elements)]
              #:when (success? e))
    e))

(define (find-inconsistent-pos seq previous)
  (define (sum-equal-pos? i) (λ~>> (apply +) (equal? (nth seq i))))
  (for/first ([w (in-windows previous seq)]
              [i (in-naturals previous)]
              #:unless (find-combination (sum-equal-pos? i) 2 w))
    i))

(define (find-inconsistency seq #:previous [previous 25])
  (~>> (find-inconsistent-pos seq previous)
       (nth seq)))


(define (find-consistent-sum seq #:previous [previous 25])
  (define inconsistent-pos (find-inconsistent-pos seq previous))
  (define inconsistent-val (nth seq inconsistent-pos))
  (define (in-moving-window n)
    (~>> seq (take (add1 inconsistent-pos)) (in-windows n)))
  (for*/first ([n (in-range 2 (add1 inconsistent-pos))]
               [w (in-moving-window n)]
               #:when (equal? inconsistent-val (apply + w)))
    (+ (find-min w)
       (find-max w))))


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
  (check-equal? (find-inconsistency test-sequence #:previous 5) 127)
  (check-equal? (find-consistent-sum test-sequence #:previous 5) 62))


(define (answer strategy)
  (~> "./aoc-day09.input"
      file->list
      list->vector
      vector->immutable-vector
      strategy))

(printf "Day 09 - star 1: ~a\n" (answer find-inconsistency))
(printf "Day 09 - star 2: ~a\n" (answer find-consistent-sum))
