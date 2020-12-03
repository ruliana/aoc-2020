#lang racket
(require threading
         racket/file
         math/base
         math/matrix)

(module+ test
  (require rackunit)
  (define test-field
    (matrix [[0 0 1 1 0 0 0 0 0 0 0]
             [1 0 0 0 1 0 0 0 1 0 0]
             [0 1 0 0 0 0 1 0 0 1 0]
             [0 0 1 0 1 0 0 0 1 0 1]
             [0 1 0 0 0 1 1 0 0 1 0]
             [0 0 1 0 1 1 0 0 0 0 0]
             [0 1 0 1 0 1 0 0 0 0 1]
             [0 1 0 0 0 0 0 0 0 0 1]
             [1 0 1 1 0 0 0 1 0 0 0]
             [1 0 0 0 1 1 0 0 0 0 1]
             [0 1 0 0 1 0 0 0 1 0 1]])))

;; The main logic
(define (tree-hits by-row by-col test-field)
  (define (at-pos r c) (matrix-ref test-field r c))
  (define num-rows (matrix-num-rows test-field))
  (define num-cols (matrix-num-cols test-field))
  (let loop ([r 0]
             [c 0]
             [rslt empty])
    (cond [(>= r num-rows) (sum rslt)]
          [else (loop (+ r by-row)
                      (remainder (+ c by-col) num-cols)
                      (cons (at-pos r c) rslt))])))

(module+ test
  (check-equal? (tree-hits 1 3 test-field) 7))

;; Just massaging parameters :(
(define ((field-trier field) coord)
  (tree-hits (car coord) (cadr coord) field))

(module+ test
  (check-equal? ((field-trier test-field) '(1 3)) 7))

;; Answers the second star (multiplication not here)
(define (multi-field-tries field tries)
  (map (field-trier field) tries))

(module+ test
  (check-equal? (multi-field-tries test-field '((1 1) (1 3) (1 5) (1 7) (2 1)))
                '(2 7 3 4 2)))


;; Deal with the input
(define (.#->01 char)
  (if (equal? char #\.) 0 1))

(define (string->01-list str)
  (~>> str
       string->list
       (map .#->01)))

;; Create inputs used in the problems
(define field
  (~>> "./aoc-day03.input"
       file->lines
       (map string->01-list)
       list*->matrix))

(define tries '((1 1) (1 3) (1 5) (1 7) (2 1)))

;; The answers
(printf "Day 03 - star 1: ~a\n" (tree-hits 1 3 field))
(printf "Day 03 - star 2: ~a\n" (apply * (multi-field-tries field tries)))