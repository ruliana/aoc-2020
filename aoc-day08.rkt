#lang racket
(require threading
         racket/file
         syntax/parse
         data/pvector
         data/collection
         (for-syntax racket/syntax))

(module+ test
  (require rackunit))


;; A bit of macro magic to create a function with
;; and early return point (called "break" here)
(define-syntax (define/break stx)
  (syntax-case stx ()
    [(_ (name args ...) body ...)
     (with-syntax ([break-id (format-id #'name "break")])
        #'(define (name args ...)
            (let/cc break-id body ...)))]))


(struct normal (rslt) #:transparent)
(struct early (rslt) #:transparent)


(define/break (run-program program-vector)
    (let loop ([cursor 0]
               [acc 0]
               [tracer empty])
        (when (>= cursor (length program-vector)) (break (normal acc)))
        (when (member cursor tracer) (break (early acc)))
        (define instruction (nth program-vector cursor))
        (define new-tracer (cons cursor tracer))
        (match instruction
            [(cons 'nop _) (loop (add1 cursor) acc new-tracer)]
            [(cons 'acc n) (loop (add1 cursor) (+ n acc) new-tracer)]
            [(cons 'jmp n) (loop (+ n cursor) acc new-tracer)])))


(define/break (mutate-program-until-normal program-vector)
  (define (instruction pos) (nth program-vector pos))
  (define (switch-instruction pos)
    (set-nth program-vector pos (switch pos)))
  (define (switch pos)
    (match (instruction pos)
        [(cons 'jmp v) (cons 'nop v)]
        [(cons 'nop v) (cons 'jmp v)]
        [_ #f]))
  (for/fold ([rslt #f])
            ([i (length program-vector)]
             #:when (switch i))
    (match (run-program (switch-instruction i))
      [(and rslt (normal _)) (break rslt)]
      [_ #f])))


(module+ test
  (define test-program
    #((nop . +0)
      (acc . +1)
      (jmp . +4)
      (acc . +3)
      (jmp . -3)
      (acc . -99)
      (acc . +1)
      (jmp . -4)
      (acc . +6)))
  (define test-terminating-program
    #((nop . +0)
      (acc . +1)
      (jmp . +4)
      (acc . +3)
      (jmp . -3)
      (acc . -99)
      (acc . +1)
      (nop . -4) ;; Changed jmp to nop
      (acc . +6)))
  (check-equal? (run-program test-program) (early 5))
  (check-equal? (run-program test-terminating-program) (normal 8))
  (check-equal? (mutate-program-until-normal test-program) (normal 8)))


(define (line->instruction str)
  (let ([parts (string-split str " ")])
    (cons (~> parts first string->symbol)
          (~> parts second string->number))))


(~>> "./aoc-day08.input"
     file->lines
     (map line->instruction)
     (extend (pvector))
     run-program)

(~>> "./aoc-day08.input"
     file->lines
     (map line->instruction)
     (extend (pvector))
     mutate-program-until-normal)
