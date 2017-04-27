#lang racket

(require racket/runtime-path)
(require net/url)
(require json)
(require web-server/servlet)
(provide/contract (start (request? . -> . response?)))


(require "DataService.rkt")
(require "testdraw.rkt")

(define-runtime-path htdocs "htdocs")
(struct dropdownEntry (entry))
(struct graphInfo (statName fileName))

(define selectTeam
  (map (lambda(x) (dropdownEntry x)) (sort (retrieveTeamAbrv) string<?)))

(define (makeDropdownEntries list)
  (map (lambda(x) (dropdownEntry (symbol->string x))) list))

(define selectPlayer
  (list (dropdownEntry "")))

(define availablePlayers (map (lambda (x) (hash-ref x 'player_name)) (retrievePlayersList)))

(define (playerEntryExists? name)
 (if (not (equal? (filter (lambda (x) (equal? x name)) availablePlayers) '()))
     #t
     #f))

(define (start request)
  (render-StatsPros-page selectTeam request))

(define (render-StatsPros-page teamDropdown request)
  (define (response-generator make-url)
    (response/xexpr
     `(html
       (head ((title "StatsPros")))
       (body
        (h1 "Please select Teams: ")
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
                        ,(render-dropdownEntrys (map (lambda (x) (dropdownEntry x)) (filter (lambda (x) (playerEntryExists? x)) (findPlayersOnTeam (extract-binding/single 'team1dropdown (request-bindings request))))) "player1dropdown")
                        (div ,(extract-binding/single 'team2dropdown (request-bindings request)))
                        ,(render-dropdownEntrys (map (lambda (x) (dropdownEntry x)) (filter (lambda (x) (playerEntryExists? x)) (findPlayersOnTeam (extract-binding/single 'team2dropdown (request-bindings request))))) "player2dropdown")
                        (div (input ((type "submit"))))
                        (input ((type "hidden")
                           (name "browserWidth")
                           (id "widthInput")
			   (value "")))
                        (input ((type "hidden")
                           (name "browserHeight")
                           (id "heightInput")
                           (value ""))))
                  (script ((type "text/javascript") (src "/browserUtilities.js")))))))
  (define (playerDropDownHandler request)
    (render-statsSelect-page request))
  (send/suspend/dispatch response-generator))

(define (render-statsSelect-page request)
  (define player1 (extract-binding/single 'player1dropdown (request-bindings request)))
  (define player2 (extract-binding/single 'player2dropdown (request-bindings request)))
  (define player1stats (retrievePlayerStats (findPlayerId player1)))
  (define player2stats (retrievePlayerStats (findPlayerId player2)))
  (define browserWidth (- (string->number (extract-binding/single 'browserwidth (request-bindings request))) 117))
  (define browserHeight (- (string->number (extract-binding/single 'browserheight (request-bindings request))) 250))
  
  (define imgPath (draw-main-plot (current-directory) player1 player2 browserWidth browserHeight))
  (define graphs (plot-singles player1 player2 (current-directory) graphInfo)) ;browserWidth browserHeight))
  
  (define (response-generator make-url)
    (response/xexpr
     `(html (head (title "StatsPros")
                  (link ((rel "stylesheet")
                         (href "/statspros.css")))
                  (style ,(generateStyles graphs)))
            (body (h1 "Please select Statistic: ")
                  (form ((action "")
                         (id "statSelect"))
                        ,(render-dropdownEntrys (makeDropdownEntries (hash-keys (car player1stats))) "statsdropdown")
                        (input ((type "submit"))))
                  ,@(render-Graph-Images graphs)
                  (form ((action ,(make-url returnHomeHandler)))
                        (input ((value "Reset")
                                (type "submit"))))
                  (script ((type "text/javascript") (src "/listener.js")))))))
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

(define (render-Graph-Images listOfGraphInfo)
  (map (lambda (x)
           `(img ((class ,(symbol->string (graphInfo-statName x)))
                   (src ,(string-append "/" (graphInfo-fileName x))))))
           listOfGraphInfo))

(define (generateStyles listOfGraphInfo)
  (define individualStyles (map (lambda (x)
                                  (string-append (string-append "IMG." (symbol->string (graphInfo-statName x)))" {\n\tdisplay: none;\n}\n"))
                                  listOfGraphInfo))
  (define (combiner strList finalStr)
    (if (null? strList) finalStr
        (combiner (cdr strList) (string-append finalStr (car strList)))))
  (combiner individualStyles ""))

(require web-server/servlet-env)
(serve/servlet start
               #:servlet-regexp #rx".*\\.rkt"
	       #:server-root-path (current-directory)
               #:extra-files-paths (list (build-path (current-directory) "htdocs")))
