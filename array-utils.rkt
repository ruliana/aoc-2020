#lang typed/racket

(require math/array)

(provide (all-defined-out))

(module+ test
  (require typed/rackunit))

(module+ test
  (define arr (array #[#[1 1 1]
                       #[1 1 1]
                       #[1 1 1]])))

(: array-surround (->* ((Array Float)) (#:border-value Float #:border-size Natural) (Array Float)))
(define (array-surround arr #:border-value [value 0.0] #:border-size [size 1])
  (define surround : (Array Float) (array value))
  (for*/fold ([rslt : (Array Float) arr])
             ([axis : Natural (in-range 2)]
              [_ : Natural (in-range size)])
    (array-append* (list surround rslt surround) axis)))

(module+ test
  (check-true (equal? (array-surround (array #[#[1.0]]) #:border-value 2.0 #:border-size 2)
                      (array #[#[2.0 2.0 2.0 2.0 2.0]
                               #[2.0 2.0 2.0 2.0 2.0]
                               #[2.0 2.0 1.0 2.0 2.0]
                               #[2.0 2.0 2.0 2.0 2.0]
                               #[2.0 2.0 2.0 2.0 2.0]]))))


(: array-convolve (-> (Array Float) (Array Float) (Array Float)))
(define (array-convolve arr kernel)
  (define shape (array-shape arr))
  (define padded-array (array-surround arr))
  (for/array:
      #:shape shape
      ([ij : Indexes (in-array-indexes shape)]) : Float
    (match-let* ([(vector i j) (vector-map add1 ij)]
                 [north (sub1 i)]
                 [south (+ 2 i)]
                 [west (sub1 j)]
                 [east (+ 2 j)]
                 [slice (array-slice-ref padded-array
                                         (list (:: north south) (:: west east)))])
      (array-all-sum (array* slice kernel)))))

(module+ test
  (check-true (equal?
               (array-convolve (array #[#[1.0 2.0 3.0]
                                        #[4.0 5.0 6.0]
                                        #[7.0 8.0 9.0]])
                               (array #[#[-1.0 -2.0 -1.0]
                                        #[ 0.0  0.0  0.0]
                                        #[ 1.0  2.0  1.0]]))
               (array #[#[ 13.0  20.0  17.0]
                        #[ 18.0  24.0  18.0]
                        #[-13.0 -20.0 -17.0]]))))
