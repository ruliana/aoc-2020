#lang racket
(require threading
         racket/file
         rebellion/collection/multidict
         rebellion/collection/entry)

(module+ test
  (require rackunit))

(define (parse-line line)
  (define/match (prepare-contains e)
    [((list qty-str txt)) (list txt (string->number qty-str))])

  (match-let* ([(list left right) (string-split line "contain")]
               [(list _ head) (regexp-match
                               #px"(\\w+ \\w+) bags"
                               left)]
               [(list raw_contains ...) (regexp-match*
                                         #px"(\\d+) (\\w+ \\w+) bags?"
                                         right
                                         #:match-select cdr)]
               [contains (map prepare-contains raw_contains)])
    (list head contains)))

(module+ test
  (check-equal? (parse-line "light red bags contain 1 bright white bag, 2 muted yellow bags.")
                '("light red" (("bright white" 1) ("muted yellow" 2))))
  (check-equal? (parse-line "dark orange bags contain 3 bright white bags, 4 muted yellow bags.")
                '("dark orange" (("bright white" 3) ("muted yellow" 4))))
  (check-equal? (parse-line "bright white bags contain 1 shiny gold bag.")
                '("bright white" (("shiny gold" 1))))
  (check-equal? (parse-line "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.")
                '("muted yellow" (("shiny gold" 2) ("faded blue" 9))))
  (check-equal? (parse-line "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.")
                '("shiny gold" (("dark olive" 1) ("vibrant plum" 2))))
  (check-equal? (parse-line "dark olive bags contain 3 faded blue bags, 4 dotted black bags.")
                '("dark olive" (("faded blue" 3) ("dotted black" 4))))
  (check-equal? (parse-line "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.")
                '("vibrant plum" (("faded blue" 5) ("dotted black" 6))))
  (check-equal? (parse-line "faded blue bags contain no other bags.")
                '("faded blue" ()))
  (check-equal? (parse-line "dotted black bags contain no other bags.")
                '("dotted black" ())))


(define (build-rule rule)
  (let ([children (map first (second rule))]
        [parent (first rule)])
    (for/multidict ([c children])
      (entry c parent))))

(module+ test
  (check-equal? (build-rule '("bright white" (("shiny gold" 1))))
                (multidict "shiny gold" "bright white"))
  (check-equal? (build-rule '("shiny gold" (("dark olive" 1) ("vibrant plum" 2))))
                (multidict "dark olive" "shiny gold"
                           "vibrant plum" "shiny gold")))


(define (merge-multidicts* dicts)
  (let ([all-entries (map in-multidict-entries dicts)])
    (for/multidict ([entry (apply in-sequences all-entries)])
        entry)))

(define (merge-multidicts . dicts)
  (merge-multidicts* dicts))

(module+ test
  (check-equal? (merge-multidicts* (list (multidict "a" 1)))
                (multidict "a" 1))
  (check-equal? (merge-multidicts* (list (multidict "a" 1)
                                         (multidict "b" 2)))
                (multidict "a" 1 "b" 2))
  (check-equal? (merge-multidicts* (list (multidict "a" 1)
                                         (multidict "b" 2)
                                         (multidict "a" 3 "b" 4)))
                (multidict "a" 1 "a" 3 "b" 2 "b" 4))
  (check-equal? (merge-multidicts* (list (multidict "a" 1)
                                         (multidict "b" 2)
                                         (multidict "a" 1 "b" 4)))
                (multidict "a" 1 "b" 2 "b" 4))
  (check-equal? (merge-multidicts (multidict "a" 1)
                                  (multidict "b" 2)
                                  (multidict "a" 3 "b" 4))
                (multidict "a" 1 "a" 3 "b" 2 "b" 4)))


(define build-graph-edges
  (λ~>> (map parse-line)
        (map build-rule)
        merge-multidicts*))

(module+ test
  (check-equal? (build-graph-edges '("bright white bags contain 1 shiny gold bag."
                                     "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags."))
                (multidict "shiny gold" "bright white"
                           "shiny gold" "muted yellow"
                           "faded blue" "muted yellow")))


(define (which-bags-hold edges mine)
  (let loop ([visited (set)]
             [pending (set mine)])
    (if (set-empty? pending) visited
        (let* ([visiting (set-first pending)]
               [remaining (set-rest pending)]
               [to-visit (multidict-ref edges visiting)]
               [pending (set-union to-visit remaining)]
               [visited (set-add visited visiting)])
            (loop visited pending)))))

(module+ test
  (define simple-edges (multidict "shiny gold" "bright white"))
  (check-equal? (which-bags-hold simple-edges "shiny gold")
                (set "shiny gold" "bright white"))
  (define simple-indirect-edges (multidict "shiny gold" "bright white"
                                           "bright white" "faded blue"
                                           "bright white" "dotted black"
                                           "faded blue" "vibrant plum"
                                           "faded black" "shiny white"))
  (check-equal? (which-bags-hold simple-indirect-edges "shiny gold")
                (set "shiny gold" "bright white" "faded blue" "dotted black" "vibrant plum")))


(define (answer text-rules mine)
  (~> text-rules
      build-graph-edges
      (which-bags-hold mine)
      set-count
      sub1))

(module+ test
  (define text-rules
    (list
        "light red bags contain 1 bright white bag, 2 muted yellow bags."
        "dark orange bags contain 3 bright white bags, 4 muted yellow bags."
        "bright white bags contain 1 shiny gold bag."
        "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags."
        "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags."
        "dark olive bags contain 3 faded blue bags, 4 dotted black bags."
        "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags."
        "faded blue bags contain no other bags."
        "dotted black bags contain no other bags."))
  (answer text-rules "shiny gold"))


(~> "./aoc-day07.input"
    file->lines
    (answer "shiny gold"))
