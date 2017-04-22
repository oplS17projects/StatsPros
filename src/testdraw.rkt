#lang racket


(require plot)
(require "RenderService.rkt")

; (parameterize ([plot-width    150]
;                  [plot-height   150]
;                  [plot-x-label  #f]
;                  [plot-y-label  #f])
;     (define xs (build-list 20 (λ _ (random))))
;     (define ys (build-list 20 (λ _ (random))))
;     (list (plot (points (map vector xs ys)))
;           (plot (points (map vector xs ys)
;                         #:x-min 0 #:x-max 1
;                         #:y-min 0 #:y-max 1))))

;(define Isaiah (remove "2015-16" (cddr (car (retrievePlayerStats (findPlayerId (findPlayerEntry "Thomas, Isaiah")) #f)))) )

 
;(plot (list (discrete-histogram (make-vector stats player))))
(define plottable-stats '(to pf fgm fga fg3m fg3a ftm fta oreb dreb ast blk plus_minus pts))


(parameterize ([plot-width    3000]
                 [plot-height   600])
    (plot (list (discrete-histogram
                 (make-vector (accumulate-stat "Isaiah Thomas"))
                 #:skip 2.5
                 #:x-min 0
                 #:color 6
                 #:label "Isaiah")
                (discrete-histogram
                 (make-vector (accumulate-stat "James Harden"))
                 #:skip 2.5
                 #:x-min 1
                 #:color 2
                 #:label "harden"))
          #:x-label "Statistics"
          #:y-label "Values"
          #:title "Harden vs Isaiah"
          #:out-file "Harden-Isaiah.png"))

;(define plotter )
