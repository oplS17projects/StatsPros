#lang racket


(require plot)
(require "RenderService.rkt")

(define vs "vs")

;; this plots all the available stat values for a two players
(define draw-main-plot
  (λ (player1 player2)
    (parameterize ([plot-width    3000]
                   [plot-height   600])
      (plot-new-window? #t)
      (plot (list (discrete-histogram
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
            #:x-label "Statistics"
            #:y-label "Values"
            #:title (string-join (list player1 vs player2))
            #:out-file (string-join (list player1 vs player2 ".png"))
            #:out-kind 'png))))



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




