#lang racket

(require "DataService.rkt")

;; **** Abstraction idea ****
;; write a function to retrieve data from one hasheq.
;; another procedure to recursively get the data for one player and
;; place it ina a list. Or try to ma striaght to a vector

;; Map player's stats into a list corresponding to the vector
;; Procedure that takes veectors and draws histograms
;; Procedure to draw histograms for stats


;; Plotable statistics:  to, pf, fgm, fga, fg3m, fg3a, ftm,
;;                       fta, oreb, dreb, ast, blk, stl, pts,
;; Omitted steals bc they're presented as a string and I didn't bother to
;; implement switching them 


;; All the numerical stats in a player's hash
(define list-of-plottable-stats '(to pf fgm fga fg3m fg3a ftm fta oreb dreb ast blk plus_minus pts))

(define (map-vector lst1 lst2)
  (cond ((or (null? lst1) (null? lst2))
            error "Unequal list sizes")
        (else (map vector lst1 lst2))))


(define (sym-vector sym1 sym2)
  (map vector sym1 sym2))

(define (make-vector player-list)
  (map-vector list-of-plottable-stats player-list))

;; retrieves a player's stats in a list of hashmaps
(define (make-stats player)
  (retrievePlayerStats (findPlayerId player)))

(define KDHash-list (make-stats "Kevin Durant"))
(define KDHash (car KDHash-list))

;; accumulate sum of stats list
(define (sum-list lst)
  (define (sum-helper lst result)
    (if (null? lst) result
        (sum-helper (cdr lst) (+ result (car lst)))))
  (sum-helper lst 0))

;; average of a stat from a player's hash-list
(define (list-avg lst)
  (/ (sum-list lst) (length lst)))

;; Find  player's id
(define (lookup-id exp)
  (findPlayerId (findPlayerEntry exp)))

;; gets stat-value from a hash map
(define (get-stat hash stat)
  (if (hash-has-key? hash stat) (hash-ref hash stat) 0))

;; get the hash map at the front of the listn of hashmaps
(define (get-hash hash-list)
  (car hash-list))

;; return list of individual game stats from players' season stat list 
(define (extract-stat-value hash-list key)
  (define (extract-helper hash-list numbers-list)
    (cond ((null? hash-list) numbers-list)
          (else
           (extract-helper (cdr hash-list)
                               (cons  (get-stat (get-hash hash-list) key) numbers-list)))))
  (extract-helper hash-list '()))


;; turn a hash map into a list, probably easier to deal with 
(define (stats-to-list player-hash)
  (cond ((hash-empty? player-hash) '())
        (else
         (hash->list player-hash))))

;; generate a player's stat list 
(define (accumulate-stats player-name)
  (define player-hash (make-stats player-name))
   (define (accumulate-helper plott accumulated-stats)
     (cond ((null? plott) accumulated-stats)
           (else
            (accumulate-helper
             (cdr plott)
             (cons  (list-avg (extract-stat-value
                               player-hash
                               (car plott)))
                    accumulated-stats)))))
   (accumulate-helper list-of-plottable-stats '()))

;; generate a list of one single stat
(define accumulate-single-stat
  (λ (player-name stat-label)
    (define player-hash (make-stats player-name))
    (list-avg (extract-stat-value player-hash stat-label))))

;(define (accumulate-single-stat player-name)
;  (define player-hash (make-stats player-name))
;  (define ()))

;; after getting the player's hash, map it over plottable stats and return 
;; season avg of these stats then pass to plot to make you a sweet chart
(provide accumulate-single-stat)
(provide accumulate-stats)
(provide make-vector)
(provide sym-vector)


(provide make-stats-string)
(provide stats-names)


;;To pass around file names create mapping of statistic to filename.
;(define filename (number->string (gensym)))
;(saveOutputFile oiwfdj filename)
;(list-append statName filename)