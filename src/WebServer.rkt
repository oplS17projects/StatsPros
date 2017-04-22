#lang racket

(require net/url)
(require json)
(require web-server/servlet
         web-server/servlet-env)

(require "DataService.rkt")

(struct dropdownEntry (entry))

(define selectTeam
  (map (lambda(x) (dropdownEntry x)) (sort (retrieveTeamAbrv) string<?)))

(define (makeDropdownEntries list)
  (map (lambda(x) (dropdownEntry (symbol->string x))) list))

(define selectPlayer
  (list (dropdownEntry "")))

(define (start request)
  (render-StatsPros-page selectTeam request))

(define (render-StatsPros-page teamDropdown request)
  (define (response-generator make-url)
    (response/xexpr
     `(html (head (title "StatsPros"))
            (body (h1 "Please select Teams: ")
                  (form ((action
                          ,(make-url teamDropDownHandler)))
                        ,(render-dropdownEntrys teamDropdown "team1dropdown")
                        ,(render-dropdownEntrys teamDropdown "team2dropdown")
                        (input ((type "submit"))))))))
  (define (teamDropDownHandler request)
    (render-playerSelect-page request))
  (send/suspend/dispatch response-generator))

(define (render-playerSelect-page request)
  (define (response-generator make-url)
    (response/xexpr
     `(html (head (title "StatsPros"))
            (body (h1 "Please select Players: ")
                  (form ((action
                          ,(make-url playerDropDownHandler)))
                        (div ,(extract-binding/single 'team1dropdown (request-bindings request)))
                        ,(render-dropdownEntrys (map (lambda (x) (dropdownEntry x))(findPlayersOnTeam (extract-binding/single 'team1dropdown (request-bindings request)))) "player1dropdown")
                        (div ,(extract-binding/single 'team2dropdown (request-bindings request)))
                        ,(render-dropdownEntrys (map (lambda (x) (dropdownEntry x))(findPlayersOnTeam (extract-binding/single 'team2dropdown (request-bindings request)))) "player2dropdown")
                        (div (input ((type "submit")))))
                  ))))
  (define (playerDropDownHandler request)
    (render-statsSelect-page request))
  (send/suspend/dispatch response-generator))

(define (render-statsSelect-page request)
  (define player1 (extract-binding/single 'player1dropdown (request-bindings request)))
  (define player2 (extract-binding/single 'player2dropdown (request-bindings request)))
  (define player1stats (retrievePlayerStats (findPlayerId player1)))
  (define player2stats (retrievePlayerStats (findPlayerId player2)))

  (define (response-generator make-url)
    (response/xexpr
     `(html (head (title "StatsPros"))
            (body (h1 "Please select Statistic: ")
                  (form ((action
                          ,(make-url statsDropDownHandler)))
                        ,(render-dropdownEntrys (makeDropdownEntries (hash-keys (car player1stats))) "statsdropdown")
                        (input ((type "submit"))))
                  ))))
  (define (statsDropDownHandler request)
    (render-statsFinal-page player1stats player2stats player1 player2 request))
  (send/suspend/dispatch response-generator))

(define (render-statsFinal-page player1stats player2stats player1name player2name request)
  (define statistic (extract-binding/single 'statsdropdown (request-bindings request)))
  (define stat1 (hash-ref (car player1stats) (string->symbol statistic)))
  (define stat2 (hash-ref (car player2stats) (string->symbol statistic)))
  
  (define (response-generator make-url)
    (response/xexpr
     `(html (head (title "StatsPros"))
            (body (h1 "Results: ")
                  (img ((src "/team-wins.png")))
                  (p ,(string-append (string-append (string-append (string-append player1name " - ") statistic) " - ") (number->string stat1)))
                  (p ,(string-append (string-append (string-append (string-append player2name " - ") statistic) " - ") (number->string stat2)))
                  (form 
                   ((action
                    ,(make-url returnHomeHandler)))
                   (input ((value "Reset")
                           (type "submit")))))
            )))
  (define (returnHomeHandler request)
    (render-StatsPros-page selectTeam request))
  (send/suspend/dispatch response-generator))

(define (render-dropdownEntrys dropdown id)
  `(select ((name ,id))
           ,@(map render-dropdownEntry dropdown)))

(define (render-dropdownEntry a-dropdownEntry)
  `(option ((value ,(dropdownEntry-entry a-dropdownEntry)))
           ,(dropdownEntry-entry a-dropdownEntry)))

(define (parse-dropdownEntry bindings)
  (dropdownEntry (extract-binding/single 'entry bindings)))

(serve/servlet start
               #:servlet-regexp #rx".*\\.rkt"
               #:server-root-path (current-directory)
               #:extra-files-paths (list (current-directory)))
                         
;;TO-DO 
;; Caching for all requests now in place!
;; Cache now writes itself to file in the src directory any-time it is updated, and self primes on server start. Cool Beans!
;; Also, figured out the img issue. should be smoof sailing from here PK!
;; Next-up - Need to collaborate on a way to dynamically build the graph imgs based on what the user has input. Nearly ready for first release!!!

