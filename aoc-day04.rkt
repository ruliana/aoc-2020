;; --- Day 4: Passport Processing ---

;; You arrive at the airport only to realize that you grabbed your North Pole
;; Credentials instead of your passport. While these documents are extremely
;; similar, North Pole Credentials aren't issued by a country and therefore aren't
;; actually valid documentation for travel in most of the world.

;; It seems like you're not the only one having problems, though; a very long line
;; has formed for the automatic passport scanners, and the delay could upset your
;; travel itinerary.

;; Due to some questionable network security, you realize you might be able to
;; solve both of these problems at the same time.

;; The automatic passport scanners are slow because they're having trouble
;; detecting which passports have all required fields. The expected fields are as
;; follows:

;; byr (Birth Year)
;; iyr (Issue Year)
;; eyr (Expiration Year)
;; hgt (Height)
;; hcl (Hair Color)
;; ecl (Eye Color)
;; pid (Passport ID)
;; cid (Country ID)

;; Passport data is validated in batch files (your puzzle input). Each passport is represented as a sequence of key:value pairs separated by spaces or newlines. Passports are separated by blank lines.


;; Here is an example batch file containing four passports:

;; ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
;; byr:1937 iyr:2017 cid:147 hgt:183cm

;; iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
;; hcl:#cfa07d byr:1929

;; hcl:#ae17e1 iyr:2013
;; eyr:2024
;; ecl:brn pid:760753108 byr:1931
;; hgt:179cm

;; hcl:#cfa07d eyr:2025 pid:166559648
;; iyr:2011 ecl:brn hgt:59in

;; The first passport is valid - all eight fields are present. The second passport
;; is invalid - it is missing hgt (the Height field).

;; The third passport is interesting; the only missing field is cid, so it looks
;; like data from North Pole Credentials, not a passport at all! Surely, nobody
;; would mind if you made the system temporarily ignore missing cid fields. Treat
;; this "passport" as valid.

;; The fourth passport is missing two fields, cid and byr. Missing cid is fine, but
;; missing any other field is not, so this passport is invalid.

;; According to the above rules, your improved system would report 2 valid
;; passports.

;; Count the number of valid passports - those that have all required fields. Treat
;; cid as optional. In your batch file, how many passports are valid?

;; Your puzzle answer was [spoiler].

;; --- Part Two ---

;; The line is moving more quickly now, but you overhear airport security talking
;; about how passports with invalid data are getting through. Better add some data
;; validation, quick!

;; You can continue to ignore the cid field, but each other field has strict rules
;; about what values are valid for automatic validation:

;; byr (Birth Year) - four digits; at least 1920 and at most 2002.
;; iyr (Issue Year) - four digits; at least 2010 and at most 2020.
;; eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
;; hgt (Height) - a number followed by either cm or in:
;; If cm, the number must be at least 150 and at most 193.
;; If in, the number must be at least 59 and at most 76.
;; hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
;; ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
;; pid (Passport ID) - a nine-digit number, including leading zeroes.
;; cid (Country ID) - ignored, missing or not.

;; Your job is to count the passports where all required fields are both present
;; and valid according to the above rules. Here are some example values:

;; byr valid:   2002
;; byr invalid: 2003

;; hgt valid:   60in
;; hgt valid:   190cm
;; hgt invalid: 190in
;; hgt invalid: 190

;; hcl valid:   #123abc
;; hcl invalid: #123abz
;; hcl invalid: 123abc

;; ecl valid:   brn
;; ecl invalid: wat

;; pid valid:   000000001
;; pid invalid: 0123456789

;; Here are some invalid passports:

;; eyr:1972 cid:100
;; hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

;; iyr:2019
;; hcl:#602927 eyr:1967 hgt:170cm
;; ecl:grn pid:012533040 byr:1946

;; hcl:dab227 iyr:2012
;; ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

;; hgt:59cm ecl:zzz
;; eyr:2038 hcl:74454a iyr:2023
;; pid:3556412378 byr:2007
;; Here are some valid passports:

;; pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
;; hcl:#623a2f

;; eyr:2029 ecl:blu cid:129 byr:1989
;; iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

;; hcl:#888785
;; hgt:164cm byr:2001 iyr:2015 cid:88
;; pid:545766238 ecl:hzl
;; eyr:2022

;; iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719

;; Count the number of valid passports - those that have all required fields and
;; valid values. Continue to treat cid as optional. In your batch file, how many
;; passports are valid?

;; Your puzzle answer was [spoiler].

#lang racket
(require threading
         racket/file
         racket/struct
         math/base
         srfi/1) ;; list utilities

(module+ test
  (require expect/rackunit
           expect))

(define (struct->values stc)
  (apply values (struct->list stc)))
               
;; Get a string or false instead of a list
;; I should extract this one into a library
(define ((regexper-first pattern) input)
  (let ([rslt (regexp-match pattern input)])
    (and rslt
         (first rslt))))

(module+ test
  (check-equal? "183" ((regexper-first #px"^\\d+") "183cm"))
  (check-equal? "cm" ((regexper-first #px"[a-z]+$") "183cm"))
  (check-equal? #f ((regexper-first #px"[a-z]+$") "183")))


(module+ test
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
      ("hcl:#cfa07d" "eyr:2025" "pid:166559648" "iyr:2011" "ecl:brn" "hgt:59in")))
  (define test-invalid-passport-text
    "eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007")
  (define test-valid-passport-text
    "pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719"))


(define (normalize-text text)
  (~>> text
       (regexp-replace* #px"(\\s|\r?\n)" _ "\t")
       (regexp-replace* #px"\t\t" _ "\n")))

(module+ test
  (check-equal? (normalize-text test-text)
                test-normalized-text))


(define (line->record line)
  (~> line
      string-trim
      (string-split "\t")))

(define (line*->records text)
  (~> text
      (string-split "\n")
      (map line->record _)))

(module+ test
  (check-equal? (line*->records test-normalized-text)
                test-records))


;; Keep fields in alphabetical order for predictability
(struct passport (byr cid ecl eyr hcl hgt hgu iyr pid) #:transparent)

(define (record->passport record)
  (define (field name . conversions)
    (let ([match (find (λ~> (string-prefix? _ name)) record)])
      (and match
           (for/fold ([rslt (regexp-replace #px"^[^:]+:" match "")])
                     ([f conversions])
             (and rslt (f rslt))))))
  (passport (field "byr" string->number)
            (field "cid" string->number)
            (field "ecl")
            (field "eyr" string->number)
            (field "hcl")
            (field "hgt" (regexper-first #px"^\\d+") string->number)
            (field "hgt" (regexper-first #px"[a-z]+$"))
            (field "iyr" string->number)
            (field "pid")))

(module+ test
  (check-equal? (record->passport '())
                (passport #f #f #f #f #f #f #f #f #f))
  (check-equal? (record->passport '("something I don't care:123"))
                (passport #f #f #f #f #f #f #f #f #f))
  (check-equal? (record->passport '("ecl:gry" "pid:860033327" "eyr:2020" "hcl:#fffffd" "byr:1937" "iyr:2017" "cid:147" "hgt:183cm"))
                (passport 1937 147 "gry" 2020 "#fffffd" 183 "cm" 2017 "860033327"))
  (check-equal? (record->passport '("hcl:#cfa07d" "eyr:2025" "pid:166559648" "iyr:2011" "ecl:brn" "hgt:59in"))
                (passport #f #f "brn" 2025 "#cfa07d" 59 "in" 2011 "166559648")))

(define (text->passports text)
  (~>> text
       normalize-text
       line*->records
       (map record->passport)))


(define (valid-ish-passport? passport)
  (let-values ([(byr cid ecl eyr hcl hgt hgu iyr pid)
                (struct->values passport)])
    ;; required fields ("cid" and "hgu" are not there)
    (and byr ecl eyr hcl hgt iyr pid)))

(module+ test
  (define (get-test-passport n) (~> (list-ref test-records n) record->passport))
  (expect! (valid-ish-passport? (get-test-passport 0)) expect-not-false)
  (expect! (valid-ish-passport? (get-test-passport 1)) expect-false)
  (expect! (valid-ish-passport? (get-test-passport 2)) expect-not-false)
  (expect! (valid-ish-passport? (get-test-passport 3)) expect-false))


(define (valid-passport? passport)
  (let-values ([(byr cid ecl eyr hcl hgt hgu iyr pid)
                (struct->values passport)])
    (and byr ecl eyr hcl hgt hgu iyr pid ;; required fields ("cid" is not there)
         (<= 1920 byr 2002)
         (<= 2010 iyr 2020)
         (<= 2020 eyr 2030)
         (regexp-match? #px"^#[0-9a-f]{6}$" hcl)
         (regexp-match? #px"^\\d{9}$" pid)
         (member ecl '("amb" "blu" "brn" "gry" "grn" "hzl" "oth"))
         (or (and (equal? hgu "cm")
                  (<= 150 hgt 193))
             (and (equal? hgu "in")
                  (<= 59 hgt 76))))))

(module+ test
  (define valid-passport (passport 1920 147 "gry" 2020 "#fffffd" 183 "cm" 2017 "860033327"))
  (define invalid-passport (passport 1919 147 "gry" 2020 "#fffffd" 183 "cm" 2017 "860033327"))
  (check-true (valid-passport? valid-passport))
  (check-false (valid-passport? invalid-passport))
  (check-equal? '(#t #t #t #t)
                (~>> test-valid-passport-text
                     text->passports
                     (map valid-passport?)))
  (check-equal? '(#f #f #f #f)
                (~>> test-invalid-passport-text
                     text->passports
                     (map valid-passport?))))


(define (answer strategy)  
  (~>> "./aoc-day04.input"
       file->string
       text->passports
       (map strategy)
       (filter identity)
       length))

;; The answers
(printf "Day 04 - star 1: ~a\n" (answer valid-ish-passport?))
(printf "Day 04 - star 2: ~a\n" (answer valid-passport?))