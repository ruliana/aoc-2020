;; After a while, commonalities start to pop up.
#lang racket
(require threading
         racket/generator
         data/collection
         math/array)

(provide (all-defined-out))

(module+ test
  (require rackunit))

(define (in-groups keep? seq)
  (let loop ([rem seq]
             [acc empty])
    (cond [(empty? rem) (if (empty? acc)
                            empty-stream
                            (stream acc))]
          [(keep? (first rem)) (loop (rest rem) (cons (first rem) acc))]
          [(empty? acc) (loop (rest rem) acc)]
          [else (stream-cons acc (loop (rest rem) empty))])))

(module+ test
  (check-equal? (sequence->list (in-groups one? empty)) empty)
  (check-equal? (sequence->list (in-groups one? '(1))) '((1)))
  (check-equal? (sequence->list (in-groups one? '(1 1 2))) '((1 1)))
  (check-equal? (sequence->list (in-groups one? '(3 1 2))) '((1)))
  (check-equal? (sequence->list (in-groups one? '(1 1 2 2 1 1 1))) '((1 1) (1 1 1))))


;; Gives a procedure which return an element on a position
(define ((positioner seq) i)
  (nth seq i))

;; Element at position is equals to something
(define ((equal-positioner seq) i value)
  (equal? value (nth seq i)))

;; Is equal this number?
(define one? (λ~> (equal? 1)))
(define two? (λ~> (equal? 2)))
(define three? (λ~> (equal? 3)))

;; Generic sum and product
(define (sum seq) (apply + seq))
(define (prod seq) (apply * seq))

;; Max/Min for collections
(define (maximum seq) (apply max seq))
(define (minimum seq) (apply min seq))

;; Gives a sequence of moving windows.
;; Each window is a sequence itself (stream).
;; This is a lazy operation.
(define (in-windows n seq)
  (define size (add1 (length seq)))
  (for/sequence ([i (in-range 0 (- size n))]
                 [j (in-range n size)])
    (subsequence seq i j)))
