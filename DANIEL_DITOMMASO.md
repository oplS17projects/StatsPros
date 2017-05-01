# StatsPros

## Daniel DiTommaso
### April 30, 2017

# Overview
This application pulls data from various statistics apis and allows users to view them
in a graphically pleasing way. The data is presented in a web application that can run
in the browser. Users can select two players and compare their statistics against each other through the use
of bar graphs/histograms. 
**Authorship note:** All of the code described here was written by myself.

# Libraries Used
The code uses four libraries:

```
(require racket/runtime-path)
(require net/url)
(require net/uri-codec)
(require net/http-client)
(require json)
(require web-server/servlet)
```

* The ```net/url``` library provides the ability to make REST-style https queries.
* ```racket/runtime-path``` is used to point the webserver at a particular directory where we can server our images from.
* The ```json``` library is used to parse the replies from the data apis.
* The ```net/uri-codec``` library is used to format parameters provided in API calls into an ASCII encoding
* ```net/http-client``` allows for easy interfacing with REST parameters such as api keys and player ids
* ```web-server/servlet``` is the library responsible for the core of the web application. it provides handling for browser requests and serving content.

# Key Code Excerpts
##1. Recursion: For every player, we use recursion to traverse their list of hashmaps, extract a single stat from each list of hash maps, and to accumulate a stat over 82 games in a regular season.

Recursion is also used to generate the inital css styles found on the page.
```scheme
(define (generateStyles listOfGraphInfo)
  (define individualStyles (map (lambda (x)
                                  (string-append (string-append "IMG." (symbol->string (graphInfo-statName x)))" { display: none;\n}\n"))
                                  listOfGraphInfo))
  (define (combiner strList finalStr)
    (if (null? strList) finalStr
        (combiner (cdr strList) (string-append finalStr (car strList)))))
  (combiner individualStyles ""))
```

##2. Map/Filter/Reduce: We used map, after getting the list of average values of each statistic throughout the length of the NBA season for each player, to make a list of vectors with the stat we're plotting and each value. This is the vector that's passed to `(plot-singles)` to in turn return a bar chart. Map filter and reduce were all critical for transforming the data to use in the webserver where appropriate.

```scheme
,(render-dropdownEntrys
 (map (lambda (x) (dropdownEntry x))
  (filter (lambda (x) (playerEntryExists? x))
   (findPlayersOnTeam (extract-binding/single 'team1dropdown (request-bindings request)))))
```

##3. Functional Approaches
 All of our data is processed through functional approaches. We wrote a handful of procedures to manipulate the data in a way particularly suited to the usage. There are numerous examples throughout the code of multiple-series transformations we do to filter and reduce the data and break it into data structures we can use throughout the application. 

```scheme
(define (parseResponse responseString)
(hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'rowSet))

(define (findPlayersOnTeam teamAbv)
(map (lambda (x) (hash-ref x 'display_name)) (hash-ref (newAPIRoster teamAbv) 'players)))
```

Here is another snippet
```scheme
(define (retrievePlayersList)
  (define-values (status headers in) (http-conn-sendrecv!
                                      (http-conn-open "probasketballapi.com" #:ssl? #t) "/players"
                                      #:method 'POST
                                      #:data 
                                      (alist->form-urlencoded 
                                       '((api_key . "s60VetaRkDZSlynNHE1MLCxA3vQY8Oz7")
                                         ))
                                         #:headers 
                                      '("Content-Type: application/x-www-form-urlencoded")))
  (string->jsexpr (port->string in)))
 ```
 Here you can see that status headers and in are all set by the result of the http call. None of them are set explicitly.
 