#lang racket
(require threading
         racket/file
         syntax/parse
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


(define/break (run-program program-vector)
    (let loop ([cursor 0]
               [acc 0]
               [tracer empty])
        (define instruction (vector-ref program-vector cursor))
        (define new-tracer (cons cursor tracer))
        (when (member cursor tracer) (break acc))
        (match instruction
            [(cons 'nop _) (loop (add1 cursor) acc new-tracer)]
            [(cons 'acc n) (loop (add1 cursor) (+ n acc) new-tracer)]
            [(cons 'jmp n) (loop (+ n cursor) acc new-tracer)])))

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
  (check-equal? (run-program test-program) 5))


(define (line->instruction str)
  (let ([parts (string-split str " ")])
    (cons (~> parts first string->symbol)
          (~> parts second string->number))))


(~>> "./aoc-day08.input"
     file->lines
     (map line->instruction)
     list->vector
     run-program)
