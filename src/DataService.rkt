#lang racket

(require net/url)

(require net/uri-codec)
(require net/url-connect)
(require net/http-client)
(require json)
(require racket/list)

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
                                       '((api_key . "5u40nyFIVdNcYBRLqGAiWkXbvCo6SEf9")
                                         ))
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
                                       '((api_key . "5u40nyFIVdNcYBRLqGAiWkXbvCo6SEf9")
                                         ))
                                         #:headers 
                                      '("Content-Type: application/x-www-form-urlencoded")))
  (string->jsexpr (port->string in)))

(define (findPlayerId name)
  (hash-ref (car (findPlayerEntry name)) 'player_id))
  
;;Retreive list of player entries by team Abrv. IE "Cleveland" = "CLE"
(define (findPlayersOnTeam teamAbv)
  (map (lambda (x) (hash-ref x 'display_name)) (hash-ref (newAPIRoster teamAbv) 'players)))

;;Retrieve full player entry by name. IE "Derrick Rose"
(define (findPlayerEntry name)
  (filter (lambda (x) (equal? (hash-ref x 'player_name) name)) (retrievePlayersList)))

(define (retrievePlayerStats id)
  (define data (list (cons 'api_key "5u40nyFIVdNcYBRLqGAiWkXbvCo6SEf9")
                      (cons 'player_id (number->string id))
                      (cons 'season "2015")))
  (define-values (status headers in) (http-conn-sendrecv!
                                      (http-conn-open "api.probasketballapi.com" #:ssl? #f) "/boxscore/player"
                                      #:method 'POST
                                      #:data (alist->form-urlencoded data)
                                      #:headers '("Content-Type: application/x-www-form-urlencoded")))
  (string->jsexpr (port->string in)))

(define (parseResponse responseString)
  (hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'rowSet))
(define (parseHeaders responseString)
  (hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'headers))

;(provide retrieveData)
(provide retrievePlayerStats)
(provide retrieveTeamsList)
(provide retrieveTeamAbrv)
(provide retrievePlayersList)
(provide findPlayersOnTeam)
(provide findPlayerEntry)
(provide findPlayerId)
