#lang web-server/insta

(require net/url)
(require json)


(require "DataService.rkt")

(struct dropdownEntry (entry))

(define selectTeam
  (map (lambda(x) (dropdownEntry x)) (retrieveTeamAbrv)))
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
  (define player1stats (retrievePlayerStats (findPlayerId (findPlayerEntry player1)) #f))
  (define player2stats (retrievePlayerStats (findPlayerId (findPlayerEntry player2)) #f))
  (define headers (retrievePlayerStats (findPlayerId (findPlayerEntry player1)) #t))
  
  (define (response-generator make-url)
    (response/xexpr
     `(html (head (title "StatsPros"))
            (body (h1 "Please select Statistic: ")
                  (form ((action
                          ,(make-url statsDropDownHandler)))
                        ,(render-dropdownEntrys (map (lambda (x) (dropdownEntry x)) headers) "statsdropdown")
                        (input ((type "submit"))))
                  ))))
  (define (statsDropDownHandler request)
    (render-statsFinal-page headers player1stats player2stats player1 player2 request))
  (send/suspend/dispatch response-generator))

(define (render-statsFinal-page headers player1stats player2stats player1name player2name request)
  (define header (extract-binding/single 'statsdropdown (request-bindings request)))
  (define (zip lst1 lst2)
    (foldr (lambda (e1 e2 acc) (cons (list e1 e2) acc))
           '()
           lst1
           lst2))
  (define p1 (zip headers (car player1stats)))
  (define p2 (zip headers (car player2stats)))
  (define stat1 (filter (lambda (x) (equal? (car x) header)) p1))
  (define stat2 (filter (lambda (x) (equal? (car x) header)) p2))
  
  (define (response-generator make-url)
    (response/xexpr
     `(html (head (title "StatsPros"))
            (body (h1 "Results: ")
                  (p ,(string-append (string-append (string-append (string-append player1name " - ") (car (car stat1))) " - ") (number->string (car (cdr (car stat1))))))
                  (p ,(string-append (string-append (string-append (string-append player2name " - ") (car (car stat2))) " - ") (number->string (car (cdr (car stat2))))))
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

(define (getWinPercentage playerStats)
  (list-ref (car playerStats) 5))
                         
;;TO-DO 
;;      Web-server successfully configured to select players based on their teams. Finally figured out how page routing works with web-server/insta.
;;      Only took an all-nighter :P
;;      Moving forward. Further work is needed configuring statistics api calls to acquire more data. After that, all I'll need is to run the queries for
;;      the required data, and display it on the application. Should talk to PK to discuss how to move forward.
;;      Although it took forever, I'm pleased with the results of this progress. That was most of the hard part. 

