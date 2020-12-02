#lang racket
(require threading
         racket/file
         srfi/13) ;; string utilities

(module+ test
  (require rackunit))


(define (parse-line str)
  (match-let ([(list _ lower upper letter password)
               (regexp-match #px"(\\d+)-(\\d+) (\\w+): (\\w+)" str)])
    (list (string->number lower)
          (string->number upper)
          letter
          password)))

(module+ test
  (check-equal? (parse-line "1-3 a: abcde")
                '(1 3 "a" "abcde")))


(define (old-valid-password? lower upper substring password)
  (~>> password
       (regexp-match* substring)
       length
       (<= lower _ upper)))

(module+ test
  (check-true (old-valid-password? 1 3 "a" "abcde"))
  (check-false (old-valid-password? 1 3 "b" "cdefg"))
  (check-true (old-valid-password? 2 9 "c" "ccccccccc")))


(define (new-valid-password? lower upper substring password)
  (define (at-pos? pos text)
    (~>> (sub1 pos)
         (string-drop password)
         (string-prefix? text)))
  (xor (at-pos? lower substring)
       (at-pos? upper substring)))

(module+ test
  (check-true (new-valid-password? 1 3 "a" "abcde"))
  (check-false (new-valid-password? 1 3 "b" "cdefg"))
  (check-false (new-valid-password? 2 9 "c" "ccccccccc")))


(define (answer strategy)
  (~>> "./aoc-day02.input"
       file->lines
       (map (λ~>> parse-line
                  (apply strategy)))
       (filter identity)
       length))

(printf "Day 02 - star 1: ~a\n" (answer old-valid-password?))
(printf "Day 02 - star 2: ~a\n" (answer new-valid-password?))
