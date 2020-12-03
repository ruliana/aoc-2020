;; --- Day 3: Toboggan Trajectory ---

;; With the toboggan login problems resolved, you set off toward the airport. While
;; travel by toboggan might be easy, it's certainly not safe: there's very minimal
;; steering and the area is covered in trees. You'll need to see which angles will
;; take you near the fewest trees.

;; Due to the local geology, trees in this area only grow on exact integer
;; coordinates in a grid. You make a map (your puzzle input) of the open squares
;; (.) and trees (#) you can see. For example:

;; ..##.......
;; #...#...#..
;; .#....#..#.
;; ..#.#...#.#
;; .#...##..#.
;; ..#.##.....
;; .#.#.#....#
;; .#........#
;; #.##...#...
;; #...##....#
;; .#..#...#.#

;; These aren't the only trees, though; due to something you read about once
;; involving arboreal genetics and biome stability, the same pattern repeats to the
;; right many times:

;; ..##.........##.........##.........##.........##.........##.......  --->
;; #...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
;; .#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
;; ..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
;; .#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
;; ..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
;; .#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
;; .#........#.#........#.#........#.#........#.#........#.#........#
;; #.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
;; #...##....##...##....##...##....##...##....##...##....##...##....#
;; .#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

;; You start on the open square (.) in the top-left corner and need to reach the
;; bottom (below the bottom-most row on your map).

;; The toboggan can only follow a few specific slopes (you opted for a cheaper
;; model that prefers rational numbers); start by counting all the trees you would
;; encounter for the slope right 3, down 1:

;; From your starting position at the top-left, check the position that is right 3
;; and down 1. Then, check the position that is right 3 and down 1 from there, and
;; so on until you go past the bottom of the map.

;; The locations you'd check in the above example are marked here with O where
;; there was an open square and X where there was a tree:

;; ..##.........##.........##.........##.........##.........##.......  --->
;; #..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
;; .#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
;; ..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
;; .#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
;; ..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
;; .#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
;; .#........#.#........X.#........#.#........#.#........#.#........#
;; #.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
;; #...##....##...##....##...#X....##...##....##...##....##...##....#
;; .#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

;; In this example, traversing the map using this slope would cause you to
;; encounter 7 trees.

;; Starting at the top-left corner of your map and following a slope of right 3 and
;; down 1, how many trees would you encounter?

;; Your puzzle answer was [spoiler].

;; --- Part Two ---

;; Time to check the rest of the slopes - you need to minimize the probability of a
;; sudden arboreal stop, after all.

;; Determine the number of trees you would encounter if, for each of the following
;; slopes, you start at the top-left corner and traverse the map all the way to the
;; bottom:

;; Right 1, down 1.
;; Right 3, down 1. (This is the slope you already checked.)
;; Right 5, down 1.
;; Right 7, down 1.
;; Right 1, down 2.

;; In the above example, these slopes would find 2, 7, 3, 4, and 2 tree(s)
;; respectively; multiplied together, these produce the answer 336.

;; What do you get if you multiply together the number of trees encountered on each
;; of the listed slopes?

;; Your puzzle answer was [spoiler].

#lang racket
(require threading
         racket/file
         math/base
         math/matrix)

(module+ test
  (require rackunit)
  (define test-field
    (matrix [[0 0 1 1 0 0 0 0 0 0 0]
             [1 0 0 0 1 0 0 0 1 0 0]
             [0 1 0 0 0 0 1 0 0 1 0]
             [0 0 1 0 1 0 0 0 1 0 1]
             [0 1 0 0 0 1 1 0 0 1 0]
             [0 0 1 0 1 1 0 0 0 0 0]
             [0 1 0 1 0 1 0 0 0 0 1]
             [0 1 0 0 0 0 0 0 0 0 1]
             [1 0 1 1 0 0 0 1 0 0 0]
             [1 0 0 0 1 1 0 0 0 0 1]
             [0 1 0 0 1 0 0 0 1 0 1]])))

;; The main logic
(define (tree-hits by-row by-col test-field)
  (define num-rows (matrix-num-rows test-field))
  (define num-cols (matrix-num-cols test-field))
  (define (at-pos r c) (matrix-ref test-field r (remainder c num-cols)))
  (for/fold ([acc 0])
            ([r (in-range 0 num-rows by-row)]
             [c (in-range 0 +inf.0 by-col)])
    (+ acc (at-pos r c))))

(module+ test
  (check-equal? (tree-hits 1 3 test-field) 7))

;; Just massaging parameters :(
(define ((field-trier field) coord)
  (tree-hits (car coord) (cadr coord) field))

(module+ test
  (check-equal? ((field-trier test-field) '(1 3)) 7))

;; Answers the second star (multiplication not here)
(define (multi-field-tries field tries)
  (map (field-trier field) tries))

(module+ test
  (check-equal? (multi-field-tries test-field '((1 1) (1 3) (1 5) (1 7) (2 1)))
                '(2 7 3 4 2)))


;; Deal with the input
(define (.#->01 char)
  (if (equal? char #\.) 0 1))

(define (string->01-list str)
  (~>> str
       string->list
       (map .#->01)))

;; Create inputs used in the problems
(define field
  (~>> "./aoc-day03.input"
       file->lines
       (map string->01-list)
       list*->matrix))

(define tries '((1 1) (1 3) (1 5) (1 7) (2 1)))

;; The answers
(printf "Day 03 - star 1: ~a\n" (tree-hits 1 3 field))
(printf "Day 03 - star 2: ~a\n" (apply * (multi-field-tries field tries)))