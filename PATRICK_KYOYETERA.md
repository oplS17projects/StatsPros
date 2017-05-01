#StatsPros

##Patrick Kyoyetera
###30 April, 2017

#Overview

In this project, the main idea was to make statistical comparisons between two players easier. It was constructed from a passion for sports and Math and a desire to be able to make easy conclulsions to conversations about player contributions.
Te program itself makes use of simple representations of player statistics using bar graphs in a browser. A user chooses players from two teams and selects what stat to view and the program returns a bar graph with two bars, one per player.

 ##Libraries Used
 
 The entire program makes use of the following libraries 
 ```
(require net/url)
(require net/uri-codec)
(require net/url-connect)
(require net/http-client)
(require json)
(require racket/list)
(require racket/runtime-path)
(require web-server/servlet)
(requrie plot)
```
The `(net/url ...)` libraries allowed for parsing and manipulating the api uris. `(require json` library was used to parse the JOSN data received from the apis we used. `(require web-server/servlet)` library facilitated the program's web server and the `(require plot)` enabled us to plot the final bar graphs represeting the information we collected.

###Key Code Excerpts

#1. Procedural Abstraction
If you dived into the source code, the only file you'd need to look at to understand see what happens is the testdraw.rkt. This is where the main draw procedures are. Inside the `(draw-main-plot)` procedure, for example, is a `(plot-file` procedure that draws a histogram using a list of vectors produced by the `(vector-list player)` procedure. This procedure takes a player name and returns a well presented list of vectors of his statistics, well-mapped to the list of plottablbe statistics and ready to plot. However, underneath are the following procedures working in tandem:
```
(define (vector-list player)
  (make-vector (accumulate-stats player)))
```
`(vector-list player)` calls (make-vector with the argument that `(accumulate-stats player)` returns. This is the procedure that does most of the heavy lifting. It calls `(retrievePlayerStats player)` which akes the api call to get back a list of hashmaps, which are in turn processed for information until the final product is reached.
``` 
(define (make-vector player-list)
  (map-vector list-of-plottable-stats player-list))
```

```
;; generate a player's stat list 
(define (accumulate-stats player-name)
  (define player-hash (make-stats player-name))
   (define (accumulate-helper plott accumulated-stats)
     (cond ((null? plott) accumulated-stats)
           (else
            (accumulate-helper
             (cdr plott)
             (cons  (list-avg (extract-stat-value
                               player-hash
                               (car plott)))
                    accumulated-stats)))))
   (accumulate-helper list-of-plottable-stats '()))
```

#2. Recursion and Accumulation
I bundled these two idea because they yalmost always appeared in the same place in my code. The above piece of code mkaes use of of both ideas. `  (define player-hash (make-stats player-name))` returns a player's list of statistics as hashmaps of each game in which that particular player participated during the season. `(accumulate-stats player-name)` generates an averaged out list of each statistic. 
Another example of this  idea is the `(extract-stat-value hash-list key)` takes a stat name as a key, and a hash-list, them filters out that statistic and returns every instance of that statistic in list form. This is the list that is averaged out by the aforementioned procedure, recursively creating the final list of averaged out statistics. 

```
;; return list of individual game stats from players' season stat list 
(define (extract-stat-value hash-list key)
  (define (extract-helper hash-list numbers-list)
    (cond ((null? hash-list) numbers-list)
          (else
           (extract-helper (cdr hash-list)
                               (cons  (get-stat (get-hash hash-list) key) numbers-list)))))
  (extract-helper hash-list '()))
  ```
