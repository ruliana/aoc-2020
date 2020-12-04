#lang racket
(require threading
         racket/file
         math/base)

(module+ test
  (require rackunit)
  (define test-text
    "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in")
  (define test-normalized-text
    (string-append
     "ecl:gry\tpid:860033327\teyr:2020\thcl:#fffffd\tbyr:1937\tiyr:2017\tcid:147\thgt:183cm\n"
     "iyr:2013\tecl:amb\tcid:350\teyr:2023\tpid:028048884\thcl:#cfa07d\tbyr:1929\n"
     "hcl:#ae17e1\tiyr:2013\teyr:2024\tecl:brn\tpid:760753108\tbyr:1931\thgt:179cm\n"
     "hcl:#cfa07d\teyr:2025\tpid:166559648\tiyr:2011\tecl:brn\thgt:59in"))
  (define test-records
    '(("ecl:gry" "pid:860033327" "eyr:2020" "hcl:#fffffd" "byr:1937" "iyr:2017" "cid:147" "hgt:183cm")
      ("iyr:2013" "ecl:amb" "cid:350" "eyr:2023" "pid:028048884" "hcl:#cfa07d" "byr:1929")
      ("hcl:#ae17e1" "iyr:2013" "eyr:2024" "ecl:brn" "pid:760753108" "byr:1931" "hgt:179cm")
      ("hcl:#cfa07d" "eyr:2025" "pid:166559648" "iyr:2011" "ecl:brn" "hgt:59in"))))


(define (normalize-text text)
  (~>> text
       (regexp-replace* #px"(\\s|\r?\n)" _ "\t")
       (regexp-replace* #px"\t\t" _ "\n")))

(module+ test
  (check-equal? (normalize-text test-text)
                test-normalized-text))


(define (line->list line)
  (~> line
      string-trim
      (string-split "\t")))

(define (line*->list text)
  (~> text
      (string-split "\n")
      (map line->list _)))

(module+ test
  (check-equal? (line*->list test-normalized-text)
                test-records))


(define (required-field? field)
  (regexp-match #px"^(byr|iyr|eyr|hgt|hcl|ecl|pid):" field))

(define (valid-passport? record)
  (~>> record
       (filter required-field?)
       (length)
       (equal? 7)))

(module+ test
  (check-true (valid-passport? (list-ref test-records 0)))
  (check-false (valid-passport? (list-ref test-records 1)))
  (check-true (valid-passport? (list-ref test-records 2)))
  (check-false (valid-passport? (list-ref test-records 3))))


(~>> "./aoc-day04.input"
     file->string
     normalize-text
     line*->list
     (map valid-passport?)
     (filter identity)
     length)