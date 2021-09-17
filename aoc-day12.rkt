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

(struct ship (direction x y) #:transparent)

(module+ test
  (check-equal? (~> (ship 0 0 0)
                    (forward 10)
                    (north 3)
                    (forward 7)
                    (right 90)
                    (forward 11)
                    (manhattan-distance))
                25))

(define-syntax (move stx)
  (syntax-parse stx
    [(_ a-ship:expr attr:id distance:expr)
     (with-syntax ([attribute (format-id #'attr "ship-~a" #'attr)])
       #'(struct-copy ship a-ship [attr (+ distance (attribute a-ship))]))]))

(define (north a-ship distance) (move a-ship y distance))
(define (south a-ship distance) (move a-ship y (- distance)))
(define (east a-ship distance) (move a-ship x distance))
(define (west a-ship distance) (move a-ship x (- distance)))

(define directions (vector-immutable east south west north))

(define (wrap size current n)
  (~> (quotient n size)
      abs
      add1
      (* size)
      (+ current n)
      (remainder size)))

(define (turn current-direction angle)
  (let* ([directions-count (vector-length directions)]
         [angle-idx (/ angle 90)])
    (wrap directions-count current-direction angle-idx)))

(define/match (forward a-ship distance)
  [((ship dir _ _) d) ((nth directions dir) a-ship d)])

(define/match (right a-ship angle)
  [((ship dir x y) a) (ship (turn dir a) x y)])

(module+ test
  (let ([sample-ship (ship 0 0 0)])
    (check-equal? (right sample-ship 0) (ship 0 0 0))
    (check-equal? (right sample-ship 90) (ship 1 0 0))
    (check-equal? (right sample-ship 180) (ship 2 0 0))
    (check-equal? (right sample-ship 270) (ship 3 0 0))
    (check-equal? (right sample-ship 360) (ship 0 0 0))
    (check-equal? (right sample-ship 450) (ship 1 0 0))))

(define/match (left a-ship angle)
  [((ship dir x y) a) (ship (turn dir (- a)) x y)])

(module+ test
  (let ([sample-ship (ship 0 0 0)])
    (check-equal? (left sample-ship 0) (ship 0 0 0))
    (check-equal? (left sample-ship 90) (ship 3 0 0))
    (check-equal? (left sample-ship 180) (ship 2 0 0))
    (check-equal? (left sample-ship 270) (ship 1 0 0))
    (check-equal? (left sample-ship 360) (ship 0 0 0))
    (check-equal? (left sample-ship 450) (ship 3 0 0))
    (check-equal? (left sample-ship 3600) (ship 0 0 0))))

(define/match (manhattan-distance a-ship)
  [((ship _ x y)) (+ (abs x) (abs y))])

;; Reader

(provide read-syntax)
(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define content (sequence->list (filter-map parse-translate src-lines)))
  (datum->syntax #f `(module aoc-2020-day-12 "aoc-day12.rkt"
                       (~> (ship 0 0 0)
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
