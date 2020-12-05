#lang racket
(require threading
         racket/file
         racket/struct
         math/base)

(module+ test
  (require rackunit))


(define (row ticket)
  (~> ticket
      (substring 0 7)
      (string-replace "F" "0")
      (string-replace "B" "1")
      (string->number 2)))

(module+ test
  (require rackunit)
  (check-equal? (row "FBFBBFFRLR") 44)
  (check-equal? (row "BFFFBBFRRR") 70)
  (check-equal? (row "FFFBBBFRRR") 14)
  (check-equal? (row "BBFFBBFRLL") 102))


(define (col ticket)
  (~> ticket
      (substring 7)
      (string-replace "L" "0")
      (string-replace "R" "1")
      (string->number 2)))

(module+ test
  (require rackunit)
  (check-equal? (col "FBFBBFFRLR") 5)
  (check-equal? (col "BFFFBBFRRR") 7)
  (check-equal? (col "FFFBBBFRRR") 7)
  (check-equal? (col "BBFFBBFRLL") 4))


(define (seat-id ticket)
  (+ (* 8 (row ticket))
     (col ticket)))

(module+ test
  (require rackunit)
  (check-equal? (seat-id "FBFBBFFRLR") 357)
  (check-equal? (seat-id "BFFFBBFRRR") 567)
  (check-equal? (seat-id "FFFBBBFRRR") 119)
  (check-equal? (seat-id "BBFFBBFRLL") 820))


(~>> "./aoc-day05.input"
     file->list
     (map symbol->string)
     (map seat-id)
     (apply max))
    

