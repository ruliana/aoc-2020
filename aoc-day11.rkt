#lang typed/racket
(require threading
         racket/file
         math/array
         "array-utils.rkt")

(module+ test
  (require typed/rackunit)
  (define test-seats : String
    "L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL"))

(: text->floor (-> String (Array Float)))
(define (text->floor text)
  (define lines (string-split text))
  (define rows (length lines))
  (define cols (string-length (first lines)))
  (for*/array: #:shape (vector rows cols)
      ([line : String lines]
       [cell : Char (string->list line)]) : Float
      (if (equal? #\. cell) 0.0 1.0)))

(module+ test
  (check-true (equal? (text->floor test-seats)
                      (array
                       #[#[1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0]
                         #[1.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0]
                         #[1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 0.0]
                         #[1.0 1.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0]
                         #[1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 1.0 1.0]
                         #[1.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0]
                         #[0.0 0.0 1.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
                         #[1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0]
                         #[1.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0 1.0]]))))


(: initial-state (-> (Array Float) (Array Float)))
(define (initial-state floor)
  (make-array (array-shape floor) 0.0))

(module+ test
  (check-true (equal? (initial-state (array #[#[1.0 2.0] #[3.0 4.0]]))
                      (array #[#[0.0 0.0] #[0.0 0.0]]))))


(: rule-applier (-> (Array Float) (->* () ((Array Float)) (Array Float))))
(define (rule-applier floor)
  (define kernel (array #[#[1.0 1.0 1.0]
                          #[1.0 0.0 1.0]
                          #[1.0 1.0 1.0]]))
  (define state0 (initial-state floor))
  (define occupy (array 1.0))
  (define leave (array 0.0))
  (λ ([state state0])
    (let* ([neighbors (array-convolve state kernel)]
           [spacious? (array= neighbors (array 0.0))]
           [crowded?  (array>= neighbors (array 4.0))]
           [temp-state (array-if spacious?
                                 occupy
                                 (array-if crowded?
                                           leave
                                           state))]
           [new-state (array* temp-state floor)])
      new-state)))

(module+ test
  (define floor (text->floor test-seats))
  (define apply-rule (rule-applier floor))
  (check-true (equal? (apply-rule) floor))
  (check-true (equal? (~> (apply-rule)
                          (apply-rule))
                      (array
                       #[#[1.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 1.0 1.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0]
                         #[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 1.0 1.0]
                         #[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 1.0 1.0]])))
  (check-true (equal? (~> (apply-rule)
                          (apply-rule)
                          (apply-rule))
                      (array
                       #[#[1.0 0.0 1.0 1.0 0.0 0.0 1.0 0.0 1.0 1.0]
                         #[1.0 0.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0]
                         #[0.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0 0.0 0.0]
                         #[1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 0.0 1.0]
                         #[1.0 0.0 1.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0 1.0]
                         #[0.0 0.0 1.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0]
                         #[1.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 0.0 1.0 1.0 1.0 0.0 1.0 1.0]])))
  (check-true (equal? (~> (apply-rule)
                          (apply-rule)
                          (apply-rule)
                          (apply-rule))
                      (array
                       #[#[1.0 0.0 1.0 0.0 0.0 0.0 1.0 0.0 1.0 1.0]
                         #[1.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0]
                         #[0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0]
                         #[1.0 0.0 0.0 0.0 0.0 1.0 1.0 0.0 0.0 1.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 0.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0]
                         #[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 0.0 1.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0]])))
  (check-true (equal? (~> (apply-rule)
                          (apply-rule)
                          (apply-rule)
                          (apply-rule)
                          (apply-rule)
                          (apply-rule))
                      (array
                       #[#[1.0 0.0 1.0 0.0 0.0 0.0 1.0 0.0 1.0 1.0]
                         #[1.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0]
                         #[0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0]
                         #[1.0 0.0 1.0 1.0 0.0 1.0 1.0 0.0 0.0 1.0]
                         #[1.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0]
                         #[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0]
                         #[1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
                         #[1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 1.0]]))))

(: stable-seats (-> String Float))
(define (stable-seats text-seats)
  (define floor (text->floor text-seats))
  (define apply-rule (rule-applier floor))
  (let loop ([state (~> text-seats text->floor)]
             [previous-state : (Array Float) (array 0.0)])
    (display ".")
    (flush-output)
    (if (equal? previous-state state)
        (array-all-sum state)
        (loop (apply-rule state) state))))

(module+ test
  (check-equal? (stable-seats test-seats)
                37.0))

(~> (file->string "./aoc-day11.input")
    (stable-seats))
