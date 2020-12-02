#lang racket
(require threading
         racket/file)

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


(define (valid-password? lower upper substring password)
  (~>> password
       (regexp-match* substring)
       length
       (<= lower _ upper)))
 

(module+ test
  (check-true (valid-password? 1 3 "a" "abcde"))
  (check-false (valid-password? 1 3 "b" "cdefg"))
  (check-true (valid-password? 2 9 "c" "ccccccccc")))

(~>> "./aoc-day02.input"
       file->lines
       (map (λ~>> parse-line
                  (apply valid-password?)))
       (filter identity)
       length)