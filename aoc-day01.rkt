;; --- Day 1: Report Repair ---

;; After saving Christmas five years in a row, you've decided to take a vacation at
;; a nice resort on a tropical island. Surely, Christmas will go on without you.

;; The tropical island has its own currency and is entirely cash-only. The gold
;; coins used there have a little picture of a starfish; the locals just call them
;; stars. None of the currency exchanges seem to have heard of them, but somehow,
;; you'll need to find fifty of these coins by the time you arrive so you can pay
;; the deposit on your room.

;; To save your vacation, you need to get all fifty stars by December 25th.

;; Collect stars by solving puzzles. Two puzzles will be made available on each day
;; in the Advent calendar; the second puzzle is unlocked when you complete the
;; first. Each puzzle grants one star. Good luck!

;; Before you leave, the Elves in accounting just need you to fix your expense
;; report (your puzzle input); apparently, something isn't quite adding up.
;; Specifically, they need you to find the two entries that sum to 2020 and then
;; multiply those two numbers together.

;; For example, suppose your expense report contained the following:

;; 1721 979 366 299 675 1456

;; In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying
;; them together produces 1721 * 299 = 514579, so the correct answer is 514579.

;; Of course, your expense report is much larger. Find the two entries that sum to
;; 2020; what do you get if you multiply them together?

;; Your puzzle answer was [spoiler].

;; --- Part Two ---

;; The Elves in accounting are thankful for your help; one of them even offers you
;; a starfish coin they had left over from a past vacation. They offer you a second
;; one if you can find three numbers in your expense report that meet the same
;; criteria.

;; Using the above example again, the three entries that sum to 2020 are 979, 366,
;; and 675. Multiplying them together produces the answer, 241861950.

;; In your expense report, what is the product of the three entries that sum to
;; 2020?

;; Your puzzle answer was [spoiler].

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