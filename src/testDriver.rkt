#lang racket

(require net/url)
(require json)

(require "DataService.rkt")

;;(define nbaStats (string->url "http://stats.nba.com/stats/draftcombineplayeranthro/?SeasonYear=2016-17&LeagueID=00"))
;;(retrieveData nbaStats)

;;Retrieve all players from current season. We'll start with arranging the application around contrasting two players.
;;This request should be made to give us some basic 'options' or 'criteria' for the user.
;; IE we can now populate a 'search' by Team, narrowed to individual players. Once two are selected, we can begin
;; Requesting further data about these players, as we now possess their PERSON_ID as well, making future requests much simpler.

(define allPlayers (string->url "http://stats.nba.com/stats/commonAllPlayers/?Season=2016-17&IsOnlyCurrentSeason=1&LeagueID=00"))
(retrieveData allPlayers)

(define allTeams (string->url "http://stats.nba.com/stats/commonTeamYears/?LeagueID=00"))
(retrieveData allTeams)

;;TO-DO: Parse the resulting hash tables into desired format.
;;       Then, develop a few test cases to demo data format for PK.
;;       As we develop statistical features, we can agree on the format/pertinent information.
;;       Each additional 'feature' will require collaboration on both ends to push to release quickly. 