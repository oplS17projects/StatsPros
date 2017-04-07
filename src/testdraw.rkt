#lang racket


(require plot)
(require "DataService.rkt")

(define name "Rondo, Rajon")

;(findPlayerEntry2 name listofPlayers)


;(define teams '("Atlanta Hawks" "Boston Celtics" "Brooklyn Nets" "Charlotte Hornets"
;                "Chichago Bulls" "Cleveland cavaliers" "Dallas Mavericks" "Denver Nuggets"
;                "Detroit Pistons" "Golden State Warriors" "Houston Rockets" "Indiana Pacers"
;                "LA Clippers" "Los Angeles Lakers" "Memphis Grizzlies" "Miami Heat"
;                "Milwaukee Bucks" "Minnesota Timberwolves" "New Orleans Pelicans"
;                "New York Knicks" "Oklahoma City Thunder" "Orlando Magic" "Philadelphia 76ers"
;                "Phoenix Suns" "Portland Trailblazers" "Sacramento Kings" "San Antonio Spurs"
;                "Toronto Raptors" "Utah Jazz"))


(define wins '(39 50 18 36 38 49 32 36 35 63 52 37 47 22 42 37 15 40 30 33 29 43 27 28 22 38 30 59
                  47 47))

; (plot (list (lines(map vector ages eating)
;                  #:color 'red
;                  #:label "Top")))

(define stats '("REB" "AST" "STL" "BLK" "PTS"))


; (parameterize ([plot-width    150]
;                  [plot-height   150]
;                  [plot-x-label  #f]
;                  [plot-y-label  #f])
;     (define xs (build-list 20 (λ _ (random))))
;     (define ys (build-list 20 (λ _ (random))))
;     (list (plot (points (map vector xs ys)))
;           (plot (points (map vector xs ys)
;                         #:x-min 0 #:x-max 1
;                         #:y-min 0 #:y-max 1))))

 

(define (make-vector lst1 lst2)
  (cond ((null? lst1) lst2)
        ((null? lst2) lst1)
        (else
         (map vector lst1 lst2))))

 
;; (plot (list (discrete-histogram (make-vector stats Harden)
;;                                #:label "Harden stats"
;;                                #:color 'red
;;                                #:line-color 5)
;;            (discrete-histogram (make-vector stats Isaiah)
;;                                #:x-min 6
;;                                #:label "Isaiah stats"
;;                                #:color 2
;;#:line-color 2)))



;; Uncomment last two to plot to file
;; Format can't also be changed to 'pdf, 'svg, 'jpeg...
      ;#:out-file "Harden-Isaiah.png"
      ;#:out-kind 'png)



;; (plot (discrete-histogram (make-vector (retrieveTeamAbrv) wins)))
;; Uncomment next 2 lines to plot to file
      ;#:out-file "team-wins.png"
      ;#:out-kind 'png)


;(retrievePlayerStats (findPlayerId (findPlayerEntry "Bradley, Avery")) #t)

;(plot (list (discrete-histogram (make-vector list1 list2))))



(define stats-names (cddr
                     (retrievePlayerStats
                      (findPlayerId
                       (findPlayerEntry "Bradley, Avery")) #t)))

(define stats-name (remove (car stats-names) stats-names))

(define Isaiah (remove "2015-16" (cddr (car (retrievePlayerStats (findPlayerId (findPlayerEntry "Thomas, Isaiah")) #f)))) )

 
;(define Isaiah '(2.6 5.9 0.9 0.2 29.1))

(define Harden (remove "2015-16" (cddr (car (retrievePlayerStats (findPlayerId (findPlayerEntry "Harden, James")) #f)))))
; (remove* '2015-16 Isaiah)

(plot (list (discrete-histogram
             (make-vector stats-name Isaiah)
             #:skip 0.5
             ;#:x-min 1
             #:label "Isaiah")
            (discrete-histogram
             (make-vector stats-name Harden)
             #:skip 0.5
             ;#:x-min 1
             #:color 2
             #:label "harden"))
      #:x-label "Statistics"
      #:y-label "Values"
      #:title "Harden vs Isaiah")