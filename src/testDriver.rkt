#lang racket
;web-server/insta

(require net/url)
(require json)

(require "DataService.rkt")

#|
(struct post (title body))

(define (start request)
  (response/xexpr
   '(html
     (head (title "My Application"))
     (body (select (option "XXX")
                   (option "YYz"))))))
|#


(define listofTeams (retrieveTeamsList))
(define listofPlayers (retrievePlayersList))
;(retrievePlayerStats "2544")


;;Search for a players entry in listofPlayers. IE "Rose, Derrick"
(define (findPlayerEntry2 name listofPlayers)
  (filter (lambda (x) (equal? (list-ref x 1) name)) listofPlayers))
;;Retreive list of player entries by team Abrv. IE "Cleveland" = "CLE"
(define (findPlayersOnTeam teamAbv listofPlayers)
  (filter (lambda (x) (equal? (list-ref x 10) teamAbv)) listofPlayers))

(define (getWinPercentage playerStats)
  (list-ref (car playerStats) 5))
                         
;;TO-DO 
;;      Current state of code reflects nice base for configuring select boxes in a webserver instance of racket.
;;      Finished basic info retrieval and data caching. Talk to PK about how to utilize DataService.
;;      Begin setting up UI to select teams and players. For now, we will default to one hard-code statistical run,
;;      adding further choice comparisons for second milestone. 

