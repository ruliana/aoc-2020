#lang racket
(require (rename-in racket
                    [map list-map]))

(module+ test
  (require rackunit))

;; Basic transducer
;; (define/match (transduce xform f . args)
;;   [(xform f (list coll))
;;    (transduce xform f (f) coll)]
;;   [(xform f (list init coll))
;;    (let ([func (xform f)])
;;      (func (foldl func init coll)))])

;; Breakable transducer
;; This avoids the need of "reduced"
(define break (make-parameter (λ args (values args))))
(define/match (transduce xform f . args)
  [(xform f (list coll))
   (transduce xform f (f) coll)]
  [(xform f (list init coll))
   (let* ([func (xform f)]
          [value (let/cc escape
                     (parameterize ([break escape])
                        (foldl func init coll)))])
     (func value))])

(define acc
  (match-lambda*
    [(list) empty]
    [(list coll) (reverse coll)]
    [(list e coll) (cons e coll)]))

;; Simple transducer
(define ((mapping proc) xf)
  (match-lambda*
    [(list) (xf)]
    [(list result) (xf result)]
    [(list input result) (xf (proc input) result)]))

;; Overriding "map" to work as transducer
(define/match (map . args)
  ;; Transducer
  [((list proc))
   (lambda (xf)
     (match-lambda*
       [(list) (xf)]
       [(list result) (xf result)]
       [(list input result) (xf (proc input) result)]))]
  ;; Normal operation
  [((list proc coll colls ...))
   (apply list-map proc coll colls)])

(define ((filtering proc) xf)
  (match-lambda*
    [(list) (xf)]
    [(list result) (xf result)]
    [(list input result)
     (if (proc input)
         (xf input result)
         result)]))

(define ((take n) xf)
  (define current n)
  (match-lambda*
    [(list) (xf)]
    [(list result) (xf result)]
    [(list input result)
     (if (zero? current) ((break) result)
         (begin
           (set! current (sub1 current))
           (xf input result)))]))

(module+ test
  (check-equal? (map add1 '(1 2 3))
                '(2 3 4))
  (check-equal? (map + '(1 2 3) '(3 2 1))
                '(4 4 4))
  (check-equal? (transduce (map add1) acc '(1 2 3))
                '(2 3 4))
  (check-equal? (transduce (mapping add1) acc '() '(1 2 3))
                '(2 3 4))
  (check-equal? (transduce (mapping add1) + '(1 2 3))
                9)
  ;; Apply composition in the right order
  (let ([map-then-filter (compose (mapping add1) (filtering even?))])
    (check-equal? (transduce map-then-filter acc '(1 2 3))
                  '(2 4)))
  (let ([filter-then-map (compose (filtering even?) (mapping add1))])
    (check-equal? (transduce filter-then-map acc '(1 2 3))
                  '(3)))
  (check-equal? (transduce (take 2) acc '(1 2 3))
                '(1 2))
  ;; Inner state is not preserved between calls
  (let ([taker (take 2)])
    (check-equal? (transduce taker acc '(1 2 3))
                  '(1 2))
    (check-equal? (transduce taker acc '(1 2 3))
                  '(1 2)))
  ;; Test if break works as intended
  (let ([take-then-add (compose (take 2) (mapping add1))])
    (check-equal? (transduce take-then-add acc '(1 8 3))
                  '(2 9)))
  (let ([add-then-take (compose (mapping add1) (take 2))])
    (check-equal? (transduce add-then-take acc '(1 8 3))
                  '(2 9))))
