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
                        ,(render-dropdownEntrys (map (lambda (x) (dropdownEntry x))(findPlayersOnTeam (extract-binding/single 'team1dropdown (request-bindings request)))) "player1dropdown")
                        ,(render-dropdownEntrys (map (lambda (x) (dropdownEntry x))(findPlayersOnTeam (extract-binding/single 'team2dropdown (request-bindings request)))) "player2dropdown")
                        (input ((type "submit"))))
                  ))))
  (define (playerDropDownHandler request)
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

;;Search for a players entry in listofPlayers. IE "Rose, Derrick"
(define (findPlayerEntry2 name listofPlayers)
  (filter (lambda (x) (equal? (list-ref x 1) name)) listofPlayers))


(define (getWinPercentage playerStats)
  (list-ref (car playerStats) 5))
                         
;;TO-DO 
;;      Web-server successfully configured to select players based on their teams. Finally figured out how page routing works with web-server/insta.
;;      Only took an all-nighter :P
;;      Moving forward. Further work is needed configuring statistics api calls to acquire more data. After that, all I'll need is to run the queries for
;;      the required data, and display it on the application. Should talk to PK to discuss how to move forward.
;;      Although it took forever, I'm pleased with the results of this progress. That was most of the hard part. 

