;; After a while, commonalities start to pop up.
#lang racket
(require threading
         racket/generator
         data/collection
         math/array
         syntax/parse/define)

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

;; Joins strings or list of strings using a separator.
(define (join sep . strs)
  (let loop ([rslt #f]
             [args strs])
    (match (list rslt args)
      [(list #f (sequence)) ""]
      [(list rslt (sequence)) rslt]
      [(list #f (sequence (? string? str) rest ...))
       (loop str rest)]
      [(list #f (sequence (? sequence? lst) rest ...))
       (loop (apply join sep lst) rest)]
      [(list rslt (sequence (? string? str) rest ...))
       (loop (string-append rslt sep str) rest)]
      [(list rslt (sequence (? sequence? lst) rest ...))
       (loop (string-append rslt sep (apply join sep lst)) rest)])))

(module+ test
  (check-equal? (join "-") "")
  (check-equal? (join "-" "ab") "ab")
  (check-equal? (join "-" "ab" "cd") "ab-cd")
  (check-equal? (join "-" (list "ab" "cd")) "ab-cd")
  (check-equal? (join "-" (list "ab" "cd") "de" "fg" (list "hi")) "ab-cd-de-fg-hi"))


;; Helper to avoid repeating the same argument over and over again.
;; Creates a new function where the first parameter is already filled
;; by the value in with-context
;;
;; Useful for structs accessors.
(define-syntax-parse-rule (with-context expr:expr (proc:expr ...) body ...+)
  (let* ([value expr]
         [proc (λ args (apply proc value args))] ...)
    body ...))

(module+ test
  (require rackunit)
  (define x 1)
  (define (plus a b) (+ a b))
  (with-context x
    [plus]
    (check-equal? (plus 2) 3)))
