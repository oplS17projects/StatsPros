#lang web-server/insta

(require net/url)
(require json)

(require "DataService.rkt")

(struct dropdownEntry (entry))

(define selectTeam
  (map (lambda(x) (dropdownEntry x)) (retrieveTeamAbrv)))
(define selectPlayer
  (list (dropdownEntry "XXXXXXXXX")))
#|
(define (start request)
  (response/xexpr
   '(html
     (head (title "My Application"))
     (body (select (option "XXX")
                   (option "YYz"))))))
|#
;(static-files-path "htdocs")
(define (start request)
  (render-blog-page selectTeam request))

(define (render-blog-page blog request)
  (local [(define (response-generator make-url)
            (response/xexpr
             `(html (head (title "StatsPros"))
                    (body (h1 "Please Select Team: ")
                          (form ((action
                                  ,(make-url insert-dropdown-handler)))
                                ,(render-dropdownEntrys blog)
                                (input ((type "submit"))))
                          ))))
          (define (insert-dropdown-handler request)
            (render-blog-page
             (map (lambda (x) (dropdownEntry x))(findPlayersOnTeam (extract-binding/single 'teamdropdown (request-bindings request))))
             request))]
    (send/suspend/dispatch response-generator)))

(define (render-dropdownEntrys blog)
  `(select ((name "teamdropdown"))
           ,@(map render-dropdownEntry blog)))

(define (render-dropdownEntry a-dropdownEntry)
  `(option ((value ,(dropdownEntry-entry a-dropdownEntry)))
           ,(dropdownEntry-entry a-dropdownEntry)))

(define (parse-dropdownEntry bindings)
  (dropdownEntry (extract-binding/single 'entry bindings)))

;;(define listofTeams (retrieveTeamsList))
;;(define listofPlayers (retrievePlayersList))
;(retrievePlayerStats "2544")


;;Search for a players entry in listofPlayers. IE "Rose, Derrick"
(define (findPlayerEntry2 name listofPlayers)
  (filter (lambda (x) (equal? (list-ref x 1) name)) listofPlayers))


(define (getWinPercentage playerStats)
  (list-ref (car playerStats) 5))
                         
;;TO-DO 
;;      Current state of code reflects nice base for configuring select boxes in a webserver instance of racket.
;;      Finished basic info retrieval and data caching. Talk to PK about how to utilize DataService.
;;      Begin setting up UI to select teams and players. For now, we will default to one hard-code statistical run,
;;      adding further choice comparisons for second milestone. 

