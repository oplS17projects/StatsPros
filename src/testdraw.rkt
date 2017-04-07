#lang racket


(require plot)
(require "DataService.rkt")

(define name "Rondo, Rajon")

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

 

(define (make-vector lst1 lst2)
  (cond ((null? lst1) lst2)
        ((null? lst2) lst1)
        (else
         (map vector lst1 lst2))))

 
;; (plot (list (discrete-histogram (make-vector stats Harden)
;;                                #:label "Harden stats"
;;                                #:color 'red
;;                                #:line-color 5)
;;            (discrete-histogram (make-vector stats Isaiah)
;;                                #:x-min 6
;;                                #:label "Isaiah stats"
;;                                #:color 2
;;#:line-color 2)))



;; Uncomment last two to plot to file
;; Format can't also be changed to 'pdf, 'svg, 'jpeg...
      ;#:out-file "Harden-Isaiah.png"
      ;#:out-kind 'png)



;; (plot (discrete-histogram (make-vector (retrieveTeamAbrv) wins)))
;; Uncomment next 2 lines to plot to file
      ;#:out-file "team-wins.png"
      ;#:out-kind 'png)


;(retrievePlayerStats (findPlayerId (findPlayerEntry "Bradley, Avery")) #t)

;(plot (list (discrete-histogram (make-vector list1 list2))))



(define stats-names (cddr
                     (retrievePlayerStats
                      (findPlayerId
                       (findPlayerEntry "Bradley, Avery")) #t)))

(define stats-name (remove (car stats-names) stats-names))

(define Isaiah (remove "2015-16" (cddr (car (retrievePlayerStats (findPlayerId (findPlayerEntry "Thomas, Isaiah")) #f)))) )

 
;(define Isaiah '(2.6 5.9 0.9 0.2 29.1))

(define Harden (remove "2015-16" (cddr (car (retrievePlayerStats (findPlayerId (findPlayerEntry "Harden, James")) #f)))))
; (remove* '2015-16 Isaiah)

(plot (list (discrete-histogram
             (make-vector stats-name Isaiah)
             #:skip 1.5
             ;#:x-min 1'
             #:x-max 30
             #:color 6
             #:label "Isaiah")
            (discrete-histogram
             (make-vector stats-name Harden)
             #:skip 1.5
             ;#:x-min 1
             #:x-max 30
             #:color 2
             #:label "harden"))
      #:x-label "Statistics"
      #:y-label "Values"
      #:title "Harden vs Isaiah"
      #:out-file "new.png")