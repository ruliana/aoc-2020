#lang racket
(require threading
         racket/file
         srfi/13) ;; string utilities

(module+ test
  (require rackunit))


(define/match (ticket->binary letter)
  [(#\F) #\0]
  [(#\B) #\1]
  [(#\L) #\0]
  [(#\R) #\1])

(define (ticket->number ticket)
  (~>> ticket
       (string-map ticket->binary)
       (string->number _ 2)))


(define (row ticket)
  (~> (ticket->number ticket)
      (arithmetic-shift -3)))

(module+ test
  (require rackunit)
  (check-equal? (row "FBFBBFFRLR") 44)
  (check-equal? (row "BFFFBBFRRR") 70)
  (check-equal? (row "FFFBBBFRRR") 14)
  (check-equal? (row "BBFFBBFRLL") 102))


(define (col ticket)
  (~> (ticket->number ticket)
      (bitwise-and #b111)))

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


(define sorted-seat-ids
  (~>> "./aoc-day05.input"
       file->list
       (map symbol->string)
       (map seat-id)
       (sort _ <)))

(define (missing-seat sorted-seat-ids)
  (for/first ([t sorted-seat-ids]
              [n (in-naturals (first sorted-seat-ids))]
              #:unless (equal? t n))
    n))

;; The answers
(printf "Day 04 - star 1: ~a\n" (last sorted-seat-ids))
(printf "Day 04 - star 2: ~a\n" (missing-seat sorted-seat-ids))
    

