
#lang racket

(require net/url)

(require net/uri-codec)
(require net/url-connect)
(require net/http-client)
(require json)
(require racket/list)

;;Prime the cache with the previous state. Useful for development speed and testing purposes, when data accuracy isn't imperative.
;(define hashStream (open-input-file "hashStore"))
;(define statsCache (read hashStream))
;(close-input-port hashStream)

(define statsCache (make-hash '()))
(define tempCache (make-hash '()))

(define (newAPI)
  (define in (get-pure-port (string->url "https://erikberg.com/nba/teams.json")
                            (list "Authorization: Bearer 97bf8315-06f2-487b-940e-7e5e0f3cac92")))
  (define response (port->string in))
  (close-input-port in)
  (string->jsexpr response))

(define (newAPIRoster teamAbv)
  (define in
    (get-pure-port
     (string->url
      (string-append (string-append "https://erikberg.com/nba/roster/" (hash-ref (car (filter (lambda (x) (equal? (hash-ref x 'abbreviation) teamAbv)) (newAPI))) 'team_id)) ".json"))
      (list "Authorization: Bearer 97bf8315-06f2-487b-940e-7e5e0f3cac92")))
  (define response (port->string in))
  (close-input-port in)
  (string->jsexpr response))

;(define (newAPI2)
  ;(define in (post-pure-port (string->url (string-append "https://probasketballapi.com/teams" (alist->form-urlencoded '((api_key . "IRaeWkrM1Sf8hHQDOoK7dFNTpBlzyXux") (team_abbrv . "BOS"))))))
;                             (string->bytes/utf-8 "Content-Type: application/x-www-form-urlencoded"))
 ; (define response (port->string in))
;  (close-input-port in)
;  (define f (open-output-file "resp.html" #:exists 'replace))
;  (display response f)
;  (close-output-port f))

;(current-https-protocol "https")


(define (retrieveData url)
  ;;Have we seen this request before? if we have, return the cached response, else fetch data over the wire, then cache.
  ;;Also writes the cache to disk whenever updated, so we have a rolling 'bank' of requests that don't need repeating!
  (define response (hash-ref statsCache url (lambda ()                             
                                              (define in
                                                (get-pure-port
                                                 (string->url url)))
                                              (define response-string (port->string in))
                                              (close-input-port in)
                                              (hash-set! statsCache url response-string)
                                              (write-to-file statsCache "hashStore2" #:mode 'binary #:exists 'replace)
                                              response-string)))
  (if (jsexpr? response) response (error (string-append "Invalid query: " response))))

  
(define (retrieveTeamsList)
  (define-values (status headers in) (http-conn-sendrecv!
                                      (http-conn-open "probasketballapi.com" #:ssl? #t) "/teams"
                                      #:method 'POST
                                      #:data 
                                      (alist->form-urlencoded 
                                       '((api_key . "IRaeWkrM1Sf8hHQDOoK7dFNTpBlzyXux")
                                         (team_abbrv . "BOS")))
                                      #:headers 
                                      '("Content-Type: application/x-www-form-urlencoded")))
  (string->jsexpr (port->string in)))
  
(define (retrieveTeamAbrv)
  (map (lambda (x) (hash-ref x 'abbreviation)) (retrieveTeamsList)))

(define (retrievePlayersList)
  (define-values (status headers in) (http-conn-sendrecv!
                                      (http-conn-open "probasketballapi.com" #:ssl? #t) "/players"
                                      #:method 'POST
                                      #:data 
                                      (alist->form-urlencoded 
                                       '((api_key . "IRaeWkrM1Sf8hHQDOoK7dFNTpBlzyXux")
                                         ))
                                         #:headers 
                                      '("Content-Type: application/x-www-form-urlencoded")))
  (string->jsexpr (port->string in)))
  
;;Retreive list of player entries by team Abrv. IE "Cleveland" = "CLE"
(define (findPlayersOnTeam teamAbv)
  (map (lambda (x) (hash-ref x 'display_name)) (hash-ref (newAPIRoster teamAbv) 'players)))

;;Retrieve full player entry by name. IE "Derrick Rose"
(define (findPlayerEntry name)
  (filter (lambda (x) (equal? (list-ref x 1) name)) (retrievePlayersList)))
(define (findPlayerId playerEntry)
  (number->string (car (car playerEntry))))

(define (retrievePlayerStats id)
  (define-values (status headers in) (http-conn-sendrecv!
                                      (http-conn-open "api.probasketballapi.com" #:ssl? #f) "/boxscore/player"
                                      #:method 'POST
                                      #:data 
                                      (alist->form-urlencoded 
                                       '((api_key . "IRaeWkrM1Sf8hHQDOoK7dFNTpBlzyXux")
                                         (player_id . "708")))
                                         #:headers 
                                      '("Content-Type: application/x-www-form-urlencoded")))
  (string->jsexpr (port->string in)))

(define (parseResponse responseString)
  (hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'rowSet))
(define (parseHeaders responseString)
  (hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'headers))

;(retrievePlayerStats (findPlayerId (findPlayerEntry "Rose, Derrick")) #f)

;(provide retrieveData)
;(provide retrievePlayerStats)
(provide retrieveTeamsList)
(provide retrieveTeamAbrv)
;(provide retrievePlayersList)
(provide findPlayersOnTeam)
;(provide findPlayerEntry)
;(provide findPlayerId)

#|
Only saving this temporarily because it has the hard coded URL's we use to ping the API. Took somework developing these,
so until we test the new caching mechanism to be dependable, i'd rather keep these somewhere to avoid repeating previous work, should things come to that.
Just ignore for now. Nothing relevant/useful below this point.

(define cacheIn (open-input-file "fakeStats"))
(define statsCache (make-hash '()))
;;This inital hash is a capture response for default values all the way through the application.
;; IE w/o changing dropdowns, just clicking submit, submit, submit, etc. Makes devs happy to have a primed cache on boot :)
(hash-set! statsCache (string-append
                       (string-append "http://stats.nba.com/stats/playerdashboardbylastngames/?MeasureType=Base&PerMode=Per100Possessions&PlusMinus=Y&PaceAdjust=N&Rank=N&Season=2015-16&SeasonType=Regular Season&PlayerID=" (number->string 203145))
                       "&Outcome=&Location=&Month=0&SeasonSegment=&DateFrom=&DateTo=&OpponentTeamID=0&VsConference=&VsDivision=&GameSegment=&Period=0&LastNGames=5") (read-line cacheIn))
(close-input-port cacheIn)
(define cacheInn (open-input-file "teamsListData"))
(hash-set! statsCache "http://stats.nba.com/stats/commonTeamYears/?LeagueID=00" (read-line cacheInn))
(close-input-port cacheInn)
(define cacheInnn (open-input-file "playerListData"))
(hash-set! statsCache "http://stats.nba.com/stats/commonAllPlayers/?Season=2016-17&IsOnlyCurrentSeason=1&LeagueID=00" (read-line cacheInnn))
(close-input-port cacheInnn)
|#