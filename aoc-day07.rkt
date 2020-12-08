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


(define (build-container-rule rule)
  (let ([parent (first rule)]
        [children (map first (second rule))])
    (for/multidict ([child children])
      (entry child parent))))

(module+ test
  (check-equal? (build-container-rule '("bright white" (("shiny gold" 1))))
                (multidict "shiny gold" "bright white"))
  (check-equal? (build-container-rule '("shiny gold" (("dark olive" 1) ("vibrant plum" 2))))
                (multidict "dark olive" "shiny gold"
                           "vibrant plum" "shiny gold")))

(define (build-contains-rule rule)
  (let ([parent (first rule)]
        [children (second rule)])
    (for/multidict ([child children])
      (entry parent child))))

(module+ test
  (check-equal? (build-contains-rule '("bright white" (("shiny gold" 1))))
                (multidict "bright white" '("shiny gold" 1)))
  (check-equal? (build-contains-rule '("shiny gold" (("dark olive" 1) ("vibrant plum" 2))))
                (multidict "shiny gold" '("dark olive" 1)
                           "shiny gold" '("vibrant plum" 2))))


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


(define build-container-graph
  (λ~>> (map parse-line)
        (map build-container-rule)
        merge-multidicts*))

(module+ test
  (check-equal? (build-container-graph '("bright white bags contain 1 shiny gold bag."
                                         "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags."))
                (multidict "shiny gold" "bright white"
                           "shiny gold" "muted yellow"
                           "faded blue" "muted yellow")))


(define build-contains-graph
  (λ~>> (map parse-line)
        (map build-contains-rule)
        merge-multidicts*))

(module+ test
  (check-equal? (build-contains-graph '("bright white bags contain 1 shiny gold bag."
                                         "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags."))
                (multidict "bright white" '("shiny gold" 1)
                           "muted yellow" '("shiny gold" 2)
                           "muted yellow" '("faded blue" 9))))


(define (which-bag-holds graph mine)
  (let loop ([visited (set)]
             [pending (set mine)])
    (if (set-empty? pending) visited
        (let* ([visiting (set-first pending)]
               [remaining (set-rest pending)]
               [to-visit (multidict-ref graph visiting)]
               [pending (set-union to-visit remaining)]
               [visited (set-add visited visiting)])
          (loop visited pending)))))

(module+ test
  (define simple-conteiner-graph (multidict "shiny gold" "bright white"))
  (check-equal? (which-bag-holds simple-conteiner-graph "shiny gold")
                (set "shiny gold" "bright white"))
  (define simple-indirect-conteiner-graph (multidict "shiny gold" "bright white"
                                           "bright white" "faded blue"
                                           "bright white" "dotted black"
                                           "faded blue" "vibrant plum"
                                           "faded black" "shiny white"))
  (check-equal? (which-bag-holds simple-indirect-conteiner-graph "shiny gold")
                (set "shiny gold" "bright white" "faded blue" "dotted black" "vibrant plum")))


(define (mine-contains graph mine)
  (let loop ([visited (set)]
             [pending (set `(,mine 1))])
    (for/sum ([visiting (in-set pending)])
      (let ([name (first visiting)]
            [value (second visiting)])
        (if (set-member? visited name) 0
            (+ value (* value (loop (set-add visited name)
                                    (multidict-ref graph name)))))))))


(module+ test
  (define simple-contains-graph (multidict "shiny gold" '("bright white" 1)))
  (check-equal? (mine-contains simple-contains-graph "shiny gold") 2)
  (define simple-contains-graph-2 (multidict "shiny gold" '("bright white" 2)
                                             "bright white" '("faded black" 3)))
  (check-equal? (mine-contains simple-contains-graph-2 "shiny gold") 9)
  (define simple-indirect-contains-graph
    (multidict "bright white" '("shiny gold" 1)
               "faded blue" '("bright white" 2)
               "dotted black" '("bright white" 3)
               "vibrant plum" '("faded blue" 4)
               "shiny white" '("faded black" 5)))
  (check-equal? (mine-contains simple-indirect-contains-graph "vibrant plum") 21))


(define (answer-1-star text-rules mine)
  (~> text-rules
      build-container-graph
      (which-bag-holds mine)
      set-count
      sub1))

(define (answer-2-star text-rules mine)
  (~> text-rules
      build-contains-graph
      (mine-contains mine)
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
  (check-equal? (answer-1-star text-rules "shiny gold") 4)
  (check-equal? (answer-2-star text-rules "shiny gold") 32)
  (define more-text-rules
    (list
     "shiny gold bags contain 2 dark red bags."
     "dark red bags contain 2 dark orange bags."
     "dark orange bags contain 2 dark yellow bags."
     "dark yellow bags contain 2 dark green bags."
     "dark green bags contain 2 dark blue bags."
     "dark blue bags contain 2 dark violet bags."
     "dark violet bags contain no other bags."))
  (check-equal? (answer-2-star more-text-rules "shiny gold") 126))


(define (answer strategy)
    (~> "./aoc-day07.input"
        file->lines
        (strategy "shiny gold")))

(printf "Day 07 - star 1: ~a\n" (answer answer-1-star))
(printf "Day 07 - star 2: ~a\n" (answer answer-2-star))
