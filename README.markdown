# Advent of Code 2020
(Racket Edition)

https://adventofcode.com/2020

- One file per day.
- Commits are my progress through code.

I try to keep commits clean and clear so they reveals the progress. The structure for them is: star1, then star2, then refactoring.

This is not vanilla Racket (if such thing exists), I use a bunch of great libraries. You can install then using `raco pkg install <lib name>`.

Here's the list:
- `threading` - Better then Clojure macro threading. Don't leave home without it.
- `collections-lib` - Sane interfaces for collections. Warning: lazyness ahead.
- `gregor` - Serious date and time library. My first choice whenever I need to deal with date, time, date intervals, time zones, and other crazynesses.
- `rebellion` - Cool utilities for Racket. Very opinionated!

Disclaimer: I don't use all them all the time. But I always have them installed along Racket.
