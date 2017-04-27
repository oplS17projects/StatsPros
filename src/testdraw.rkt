#lang racket

(require plot)
(require "RenderService.rkt")

;; this plots all the available stat values for a two players
(define draw-main-plot
  (λ (currentDirectory player1 player2 browserWidth browserHeight)
    (define filePath (string-append (symbol->string (gensym)) ".png"))
    (define imgPath (string-append (path->string currentDirectory) filePath))

    (parameterize ([plot-width    browserWidth]
                   [plot-height   browserHeight]) 
      (plot-file (list (discrete-histogram
                        (vector-list player1)
                   #:skip 2.5
                   #:x-min 0
                   #:color 67
                   #:label player1)

                       (discrete-histogram
                        (vector-list player2)
                        #:skip 2.5
                        #:x-min 1
                        #:color 'SlateGray
                        #:label player2))
                 imgPath
                 #:x-label "Statistics"
                 #:y-label "Values"
                 #:title (string-join (list player1 "vs" player2))))
    (string-append "/" filePath)))



;; should use player ids to pass around images to the web server

(struct graphInfo (statName fileName))

(define (plot-singles p1 p2 currentDirectory)
  (define p1-list (vector-list p1))
  (define p2-list (vector-list p2))
;  (define list-of-graphs '())
  (define (helper list1 list2 currentDirectory list-of-graphs)
    (cond ((or (null? list1) (null? list2))
           list-of-graphs)
          (else
           (helper (cdr list1)
                   (cdr list2)
                   currentDirectory
                   (cons (plot-single-stat (car list1) (car list2) currentDirectory) list-of-graphs)))))
  (helper p1-list p2-list currentDirectory '()))



  (define plot-single-stat
    (λ (v1 v2 currentDirectory)
      (define fileName (string-append (symbol->string (gensym)) ".png"))
      (define imgPath (string-append (path->string currentDirectory) fileName))
      (plot-file (list
                  (discrete-histogram
                   (list v1)
                   #:skip 2.5
                   #:x-min 0
                   #:color 92
                   #:label "player1")
                  (discrete-histogram
                   (list v2)
                   #:skip 2.5
                   #:x-min 1
                   #:color 65
                   #:label "player2"))
                 imgPath
                 #:x-label "symbol-string stat-label"
                 #:y-label "Value")
      (graphInfo (vector-ref v1 0) fileName)))

;; (plot (list (discrete-histogram )))
(provide draw-main-plot)
(provide plot-single-stat)
