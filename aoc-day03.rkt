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


(define (.#->01 char)
  (if (equal? char #\.) 0 1))

(define (string->01-list str)
  (~>> str
       string->list
       (map .#->01)))

(~>> "./aoc-day03.input"
     file->lines
     (map string->01-list)
     list*->matrix
     (tree-hits 1 3))