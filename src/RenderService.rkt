#lang racket

(require "DataService.rkt")


(define (make-vector lst1 lst2)
  (cond ((or (null? lst1) (null? lst2))
            error "Unequal list sizes")
        (else (map vector lst1 lst2))))

(define stats-names (cddr
                     (retrievePlayerStats
                      (findPlayerId
                       (findPlayerEntry "Durant, Kevin")) #f)))

(define stats-name (remove (car stats-names) stats-names))



;; Find  player's id
(define (lookup-id exp)
  (findPlayerId (findPlayerEntry exp)))

;; Returns player general stats in a string
(define (getStats exp)
  (retrievePlayerStats (lookup-id exp) #f))

;; formats a stat string into 27 elements
(define (make-stats-string name)
  (remove "2015-16" (cddr (car (getStats name)))))

(provide make-stats-string)
(provide stats-names)
