
#lang racket

(require net/url)
(require json)
(require racket/list)

#|
For dev purposes leave this set to #t.
Otherwise DataService will request all fresh data from NBA API, which takes some time.
Caching of generated requests is now active! Inital loads are still slow, however. Smh.
|#
(define offlineMode #t)
(define cacheIn (open-input-file "fakeStats"))
(define statsCache (make-hash '()))
;;This inital hash is a capture response for default values all the way through the application.
;; IE w/o changing dropdowns, just clicking submit, submit, submit, etc. Makes devs happy to have a primed cache on boot :)
(hash-set! statsCache (string-append
       (string-append "http://stats.nba.com/stats/playerdashboardbylastngames/?MeasureType=Base&PerMode=Per100Possessions&PlusMinus=Y&PaceAdjust=N&Rank=N&Season=2015-16&SeasonType=Regular Season&PlayerID=" (number->string 203145))
       "&Outcome=&Location=&Month=0&SeasonSegment=&DateFrom=&DateTo=&OpponentTeamID=0&VsConference=&VsDivision=&GameSegment=&Period=0&LastNGames=5") (read-line cacheIn))
(close-input-port cacheIn)

(define (retrieveData url)
  (define in (get-pure-port url))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string) (string->jsexpr response-string) (error (string-append "Invalid query: " response-string))))

(define (retrieveTeamsList)
  (if offlineMode (offlineTeams) (onlineTeams)))

(define (offlineTeams)
  (define in (open-input-file "teamsListData"))
  (define response-string (read-line in))
  (close-input-port in)
  (if (jsexpr? response-string) (parseResponse response-string) (error (string-append "Invalid query: " response-string))))

(define (onlineTeams)
  (define in (get-pure-port (string->url "http://stats.nba.com/stats/commonTeamYears/?LeagueID=00")))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string) (parseResponse response-string) (error (string-append "Invalid query: " response-string))))

(define (retrieveTeamAbrv)
  (filter (lambda(x) (not (eq? x `null))) (map (lambda(x) (list-ref x 4)) (retrieveTeamsList))))

(define (retrievePlayersList)
  (if offlineMode (retrieveOfflinePlayers) (retrieveOnlinePlayers)))

(define (retrieveOfflinePlayers)
  (define in (open-input-file "playerListData"))
  (define response-string (read-line in))
  (close-input-port in)
  (if (jsexpr? response-string) (parseResponse response-string) (error (string-append "Invalid query: " response-string))))

(define (retrieveOnlinePlayers)
  (define in (get-pure-port (string->url "http://stats.nba.com/stats/commonAllPlayers/?Season=2016-17&IsOnlyCurrentSeason=1&LeagueID=00")))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string) (parseResponse response-string) (error (string-append "Invalid query: " response-string))))

;;Retreive list of player entries by team Abrv. IE "Cleveland" = "CLE"
(define (findPlayersOnTeam teamAbv)
  (map (lambda(x) (list-ref x 1)) (filter (lambda (x) (equal? (list-ref x 10) teamAbv)) (retrievePlayersList))))
;;Retrieve full player entry by name. IE "Rose, Derrick"
(define (findPlayerEntry name)
  (filter (lambda (x) (equal? (list-ref x 1) name)) (retrievePlayersList)))
(define (findPlayerId playerEntry)
  (number->string (car (car playerEntry))))


(define (retrievePlayerStats id headers?)
  ;Build URL as string. Place id in correct queryParam 'PlayerID'.
  (define url (string-append
       (string-append "http://stats.nba.com/stats/playerdashboardbylastngames/?MeasureType=Base&PerMode=Per100Possessions&PlusMinus=Y&PaceAdjust=N&Rank=N&Season=2015-16&SeasonType=Regular Season&PlayerID=" id)
       "&Outcome=&Location=&Month=0&SeasonSegment=&DateFrom=&DateTo=&OpponentTeamID=0&VsConference=&VsDivision=&GameSegment=&Period=0&LastNGames=5"))
  ;;Have we seen this request before? if we have, return the cached response, else fetch data over the wire, then cache.
  (define response (hash-ref statsCache url (lambda ()                             
                                              (define in
                                                (get-pure-port
                                                 (string->url url)))
                                              (define response-string (port->string in))
                                              (close-input-port in)
                                              (hash-set! statsCache url response-string)
                                              response-string)))
  (if (jsexpr? response)
      (if headers? (parseHeaders response) (parseResponse response))
      (error (string-append "Invalid Query: " response))))

(define (parseResponse responseString)
  (hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'rowSet))
(define (parseHeaders responseString)
  (hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'headers))

;(retrievePlayerStats (findPlayerId (findPlayerEntry "Rose, Derrick")) #f)

(provide retrieveData)
(provide retrievePlayerStats)
(provide retrieveTeamsList)
(provide retrieveTeamAbrv)
(provide retrievePlayersList)
(provide findPlayersOnTeam)
(provide findPlayerEntry)
(provide findPlayerId)