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
  (define (at pos) (nth seq pos))
  (for*/first ([i (in-range (sub1 (length seq)))]
               [j (in-range (add1 i) (length seq))]
               #:when (equal? target (+ (at i) (at j))))
    (list (at i) (at j))))

(module+ test
  (check-equal? '(1721 299) (two-sum 2020 test-sequence)))


(define (three-sum target seq)
  (define (at pos) (nth seq pos))
  (for*/first ([i (in-range (sub1 (length seq)))]
               [j (in-range (add1 i) (sub1 (length seq)))]
               [z (in-range (add1 j) (length seq))]
               #:when (equal? target (+ (at i) (at j) (at z))))
    (list (at i) (at j) (at z))))

(module+ test
  (check-equal? '(979 366 675) (three-sum 2020 test-sequence)))


(define file->number-vector
  (λ~>> file->lines 
        (map string->number)
        sequence->vector))

(define (answer strategy)
  (~>> "./aoc-day01.input"
       file->number-vector
       (strategy 2020)
       (apply *)))

(printf "Day 01 - star 1: ~a\n" (answer two-sum))
(printf "Day 01 - star 2: ~a\n" (answer three-sum))