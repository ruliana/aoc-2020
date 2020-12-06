#lang racket
(require threading
         math/base
         racket/file)

(module+ test
  (require rackunit))


(define unique-answers
  (λ~> string-append*
       string->list
       list->set
       set-count))

(module+ test
  (check-equal? (unique-answers '("abc"))
                3)
  (check-equal? (unique-answers '("a" "b" "c"))
                3)
  (check-equal? (unique-answers '("ab" "bc"))
                3)
  (check-equal? (unique-answers '("a" "a" "a" "a"))
                1)
  (check-equal? (unique-answers '("b"))
                1))


(define (splitf-by lst pred)
  (let loop ([rslt empty]
             [remaining lst])
        (let-values ([(head tail) (splitf-at remaining pred)])
            (if (empty? tail) (reverse (cons head rslt))
                (loop (cons head rslt) (rest tail))))))

(module+ test
  (check-equal? (splitf-by '("a" "b" "" "c" "" "b" "c" "a") non-empty-string?)
                '(("a" "b") ("c") ("b" "c" "a"))))

(~> "./aoc-day06.input"
    file->lines
    (splitf-by non-empty-string?)
    (map unique-answers _)
    sum)
