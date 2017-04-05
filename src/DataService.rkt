
#lang racket

(require net/url)
(require json)

(define (retrieveData url)
  (define in (get-pure-port url))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string) (string->jsexpr response-string) (error (string-append "Invalid query: " response-string))))

(define (retrieveTeamsList)
  (define in (get-pure-port (string->url "http://stats.nba.com/stats/commonTeamYears/?LeagueID=00")))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string) (parseResponse response-string) (error (string-append "Invalid query: " response-string))))

(define (retrievePlayersList)
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
