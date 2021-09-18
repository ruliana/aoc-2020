#lang racket
(require threading
         data/collection
         (for-syntax racket/syntax
                     syntax/parse))

(provide read-syntax
         ~>
         displayln
         ship
         north south east west forward left right
         manhattan-distance)

(module+ test
  (require rackunit))

(struct ship (x y waypoint-x waypoint-y) #:transparent)

(module+ test
  (check-equal? (~> (ship 0 0 10 1)
                    (forward 10)
                    (north 3)
                    (forward 7)
                    (right 90)
                    (forward 11)
                    (manhattan-distance))
                286))

(define-syntax (move stx)
  (syntax-parse stx
    [(_ a-ship:expr attr:id distance:expr)
     (with-syntax ([attribute (format-id #'attr "ship-~a" #'attr)])
       #'(struct-copy ship a-ship [attr (+ distance (attribute a-ship))]))]))

(define (north a-ship distance) (move a-ship waypoint-y distance))
(define (south a-ship distance) (move a-ship waypoint-y (- distance)))
(define (east a-ship distance) (move a-ship waypoint-x distance))
(define (west a-ship distance) (move a-ship waypoint-x (- distance)))

(define/match (forward a-ship distance)
  [((ship x y wx wy) d) (ship (+ x (* d wx))
                              (+ y (* d wy))
                              wx
                              wy)])

(module+ test
  (check-equal? (forward (ship 0 0 10 1) 10) (ship 100 10 10 1))
  (check-equal? (forward (ship 100 10 10 4) 7) (ship 170 38 10 4))
  (check-equal? (forward (ship 0 0 -10 -4) 2) (ship -20 -8 -10 -4)))


(define/match (right-90 a-ship)
  [((ship x y wx wy)) (ship x y wy (- wx))])

(define (right a-ship angle)
  (for/fold ([rslt a-ship])
            ([n (range (/ angle 90))])
    (right-90 rslt)))


(module+ test
  (check-equal? (right (ship 170 38 10 4) 90) (ship 170 38 4 -10))
  (check-equal? (right (ship 170 38 4 -10) 90) (ship 170 38 -10 -4))
  (check-equal? (right (ship 170 38 -10 -4) 90) (ship 170 38 -4 10))
  (check-equal? (right (ship 170 38 -4 10) 90) (ship 170 38 10 4))
  (check-equal? (right (ship 170 38 10 4) 180) (ship 170 38 -10 -4)))


(define/match (left-90 a-ship)
  [((ship x y wx wy)) (ship x y (- wy) wx)])

(define (left a-ship angle)
  (for/fold ([rslt a-ship])
            ([n (range (/ angle 90))])
    (left-90 rslt)))

(module+ test
  (check-equal? (left (ship 170 38 4 -10) 90) (ship 170 38 10 4))
  (check-equal? (left (ship 170 38 -10 -4) 90) (ship 170 38 4 -10))
  (check-equal? (left (ship 170 38 -4 10) 90) (ship 170 38 -10 -4))
  (check-equal? (left (ship 170 38 -10 -4) 90) (ship 170 38 4 -10))
  (check-equal? (left (ship 170 38 4 -10) 270) (ship 170 38 -10 -4)))


(define/match (manhattan-distance a-ship)
  [((ship x y _ _)) (+ (abs x) (abs y))])

;; Reader

(provide read-syntax)
(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define content (sequence->list (filter-map parse-translate src-lines)))
  (datum->syntax #f `(module aoc-2020-day-12 "aoc-day12b.rkt"
                       (~> (ship 0 0 10 1)
                           ,@content
                           manhattan-distance))))

(define (parse-line str)
  (let ([match (regexp-match #px"(\\w)(\\d+)" str)])
    (if match
        (list (ref match 1) (ref match 2))
        #f)))

(define/match (translate entry)
  [((list "F" n)) `(forward ,(string->number n))]
  [((list "R" n)) `(right ,(string->number n))]
  [((list "L" n)) `(left ,(string->number n))]
  [((list "N" n)) `(north ,(string->number n))]
  [((list "S" n)) `(south ,(string->number n))]
  [((list "E" n)) `(east ,(string->number n))]
  [((list "W" n)) `(west ,(string->number n))]
  [(anything) anything])

(define parse-translate (λ~> parse-line translate))

;; Expander

(define-syntax (aoc-module-begin stx)
  (syntax-case stx ()
    [(_ forms ...)
     #'(#%module-begin
        forms ...)]))

(provide (rename-out [aoc-module-begin #%module-begin])
         #%app
         #%datum)
