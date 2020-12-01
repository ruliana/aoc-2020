#lang racket
(require threading
         data/collection
         racket/file)

(module+ test
  (require rackunit)

  (define test-sequence #(1721 979 366 299 675 1456)))


(define sequence->vector
  (λ~> sequence->list
       list->vector
       vector->immutable-vector))


(define (two-sum target seq)
  (for*/first ([i (in-range (sub1 (length seq)))]
               [j (in-range (add1 i) (length seq))]
               #:when (equal? target (+ (nth seq i) (nth seq j))))
    (list (nth seq i) (nth seq j))))


(module+ test
  (check-equal? '(1721 299) (two-sum 2020 test-sequence)))

(define file->number-vector
  (λ~>> file->lines 
        (map string->number)
        sequence->vector))

(~>> "./aoc-day01.input"
     file->number-vector
     (two-sum 2020)
     (apply *))