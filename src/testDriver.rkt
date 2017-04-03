#lang racket

(require net/url)

(require "DataService.rkt")

(define nbaStats (string->url "http://stats.nba.com/stats/draftcombineplayeranthro/?SeasonYear=2016-17&LeagueID=00"))
(retrieveData nbaStats)
