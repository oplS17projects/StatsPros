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
                         
;;(define nbaStats (string->url "http://stats.nba.com/stats/draftcombineplayeranthro/?SeasonYear=2016-17&LeagueID=00"))
;;(retrieveData nbaStats)

;;TO-DO Test and Build one more Call to API service that we will be begin using for 'analysis'.
;;      This should be all we need to set up a basic 'hand-off' between PK and I to begin work on our individual pieces.
;;         --Update: someStats is a working call w/ relevant data based on a playerID. We should start here.
;;                   there are quite a few flags to set, so this call will require tweaking.

;;      Current state of code reflects nice base for configuring select boxes in a webserver instance of racket.
;;      IF THERE IS TIME. We should configure a way to dump the initial testing response of the API to avoid having re-fetch data we haven't changed upon re-running.

