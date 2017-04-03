#lang racket

(require net/url)
(require json)

(define nbaStats (string->url "http://stats.nba.com/stats/draftcombineplayeranthro/?SeasonYear=2016-17&LeagueID=00"))
(define in (get-pure-port nbaStats))
(define response-string (port->string in))
(close-input-port in)
(jsexpr? response-string)
(string->jsexpr response-string)
