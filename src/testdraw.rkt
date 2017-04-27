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

(define (plot-singles p1 p2)
  (define p1-list (vector-list p1))
  (define p2-list (vector-list p2))
  (define (helper list1 list2 count c1 c2)
    (cond ((or (null? list1) (null? list2))
           (print 'done))
          (else
           (begin (plot-single-stat (car list1) (car list2) count)
                  (+ count 1)
                  (helper (cdr list1) (cdr list2) count c1 c2)))))
  (helper p1-list p2-list 0 45 76))



  (define plot-single-stat
    (λ (v1 v2 num)
      (plot (list
             (discrete-histogram
              (list v1)
              #:skip 2.5
              #:x-min 0
              #:color 'SlateGray
              #:label "player1")
             (discrete-histogram
              (list v2)
              #:skip 2.5
              #:x-min 1
              #:color 'LawnGreen
              #:label "player2"))
            #:out-file (string-join (list (symbol->string (gensym)) ".png"))
            #:x-label "symbol-string stat-label"
            #:y-label "Value")))

;; (plot (list (discrete-histogram )))
(provide draw-main-plot)
(provide plot-single-stat)
