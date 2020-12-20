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
  (define arr-shape (vector->array (array-shape arr)))
  (define kernel-shape (vector->array (array-shape kernel)))
  (define final-shape (array->vector (array- arr-shape kernel-shape (array -1))))
  (for/array:
      #:shape final-shape
      ([top-left : Indexes (in-array-indexes final-shape)]) : Float
      (match-let* ([bottom-right (array+ (vector->array top-left) kernel-shape)]
                   [slice-ix (map (λ (x y) (:: x y))
                                  (vector->list top-left)
                                  (array->list bottom-right))]
                   [slice (array-slice-ref arr slice-ix)])
        (array-all-sum (array* slice kernel)))))

(module+ test
  (check-true (equal?
               (array-convolve (array #[2.0])
                               (array #[3.0]))
               (array #[6.0])))
  (check-true (equal?
               (array-convolve (array #[2.0 3.0])
                               (array #[3.0]))
               (array #[6.0 9.0])))
  (check-true (equal?
               (array-convolve (array #[#[1.0 2.0 3.0]
                                        #[4.0 5.0 6.0]
                                        #[7.0 8.0 9.0]])
                               (array #[#[1.0 0.0]
                                        #[0.0 1.0]]))
               (array #[#[ 6.0  8.0]
                        #[12.0 14.0]])))
  (check-true (equal?
               (array-convolve (array-surround (array #[#[1.0 2.0 3.0]
                                                        #[4.0 5.0 6.0]
                                                        #[7.0 8.0 9.0]]))
                               (array #[#[1.0 1.0 1.0]
                                        #[1.0 0.0 1.0]
                                        #[1.0 1.0 1.0]]))
               (array #[#[11.0 19.0 13.0]
                        #[23.0 40.0 27.0]
                        #[17.0 31.0 19.0]])))
  (check-true (equal?
               (array-convolve (array-surround (array #[#[1.0 2.0 3.0]
                                                        #[4.0 5.0 6.0]
                                                        #[7.0 8.0 9.0]]))
                               (array #[#[-1.0 -2.0 -1.0]
                                        #[ 0.0  0.0  0.0]
                                        #[ 1.0  2.0  1.0]]))
               (array #[#[ 13.0  20.0  17.0]
                        #[ 18.0  24.0  18.0]
                        #[-13.0 -20.0 -17.0]]))))
