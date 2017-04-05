
#lang racket

(require net/url)
(require json)

#|
For dev purposes leave this set to #t.
Otherwise DataService will request all fresh data from NBA API, which takes some time.
|#
(define offlineMode #t)

(define (retrieveData url)
  (define in (get-pure-port url))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string) (string->jsexpr response-string) (error (string-append "Invalid query: " response-string))))

;;TO-DO Now that storing responses is possible, implement some form of caching for 'live' use, rather than strictly offline.
  ;(define out (open-output-file "data"))
  ;(display response-string out)
  ;(close-output-port out)

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

(define (retrievePlayerStats id)
  ;Build URL as string. Place id in correct queryParam 'PlayerID'.
  (define in
    (get-pure-port
     (string->url
      (string-append
       (string-append "http://stats.nba.com/stats/playerdashboardbylastngames/?MeasureType=Base&PerMode=Totals&PlusMinus=Y&PaceAdjust=N&Rank=N&Season=2015-16&SeasonType=Regular Season&PlayerID=" id)
       "&Outcome=&Location=&Month=1&SeasonSegment=&DateFrom=&DateTo=&OpponentTeamID=0&VsConference=&VsDivision=&GameSegment=&Period=0&LastNGames=0"))))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string)
      (parseResponse response-string)
      (error (string-append "Invalid Query: " response-string))))

(define (parseResponse responseString)
  (hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'rowSet))

(provide retrieveData)
(provide retrievePlayerStats)
(provide retrieveTeamsList)
(provide retrievePlayersList)
