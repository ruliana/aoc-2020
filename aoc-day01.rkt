#lang racket
(require threading
         racket/file
         math/base)

(module+ test
  (require rackunit)
  (define test-sequence '(1721 979 366 299 675 1456)))


;; Helper methods
(define ((sum-equal? target) lst) (equal? target (sum lst)))

(module+ test
  (check-false ((sum-equal? 2020) '()))
  (check-false ((sum-equal? 2020) '(2020 19)))
  (check-true ((sum-equal? 2020) '(2000 20))))


(define prod (curry apply *))


(define file->number-list
  (λ~>> file->lines 
        (map string->number)))


(define (answer strategy)
  (~>> "./aoc-day01.input"
       file->number-list
       strategy
       prod))


;; Here's the "meat" of the algorithm.
;; Going recursive makes easy to specify the number
;; of elements that satifies the condition we want,
;; like 2 or 3 numbers.
(define (find-combination n-elements success? seq)
  (let loop ([n-elements n-elements]
             [seq seq]
             [rslt '()])
    (match (list n-elements seq)
      [(list 0 _) #:when (success? rslt) (reverse rslt)]
      [(list 0 _) #f]
      [(list _ '()) #f]
      [(list n (list x xs ...))
       (or (loop (sub1 n) xs (cons x rslt))
           (loop n xs rslt))])))

(module+ test
  (check-false (find-combination 2 (sum-equal? 10) test-sequence))
  (check-equal? '(299) (find-combination 1 (sum-equal? 299) test-sequence))
  (check-equal? '(1721 299) (find-combination 2 (sum-equal? 2020) test-sequence))
  (check-equal? '(366 675) (find-combination 2 (sum-equal? (+ 366 675)) test-sequence))
  (check-equal? '(979 366 675) (find-combination 3 (sum-equal? 2020) test-sequence)))

;; The actual answers
(printf "Day 01 - star 1: ~a\n" (answer (curry find-combination 2 (sum-equal? 2020))))
(printf "Day 01 - star 2: ~a\n" (answer (curry find-combination 3 (sum-equal? 2020))))