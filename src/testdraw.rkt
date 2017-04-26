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
                   (make-vector (accumulate-stats player1))
                   #:skip 2.5
                   #:x-min 0
                   #:color 67
                   #:label player1)
                  (discrete-histogram
                   (make-vector (accumulate-stats player2))
                   #:skip 2.5
                   #:x-min 1
                   #:color 45
                   #:label player2))
                 imgPath
            #:x-label "Statistics"
            #:y-label "Values"
            #:title (string-join (list player1 "vs" player2))))
    (string-append "/" filePath)))



;; should use player ids to pass around images to the web server


(define plot-single-stat
  (λ (player1 player2  stat-label)
    (plot-new-window? #t)
    (plot (list (discrete-histogram
                 (sym-vector stat-label
                              (accumulate-single-stat player1 stat-label))
                 #:skip 2.5
                 #:x-min 0
                 #:color 43
                 #:label player1)
                (discrete-histogram
                 (sym-vector stat-label
                             (accumulate-single-stat player2 stat-label))
                 #:skip 2.5
                 #:x-min 1
                 #:color 89
                 #:label player2))
                #:x-label (symbol->string stat-label)
                #:y-label "Value")))
  
;; (plot (list (discrete-histogram )))
(provide draw-main-plot)
