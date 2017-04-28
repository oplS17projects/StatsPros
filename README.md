
# StatsPros
Analyzing and visualizing sports statistics

### To build:
```
raco exe --gui src/WebServer.rkt
```
Once complete, you should find a WebServer.app(MacOS)/WebServer.exe(Windows)/WebServer(Linux) inside the src directory.
Double click to run. Must be force killed from Activity Monitor I've noticed.
### Statement
<!--- Describe your project. Why is it interesting? Why is it interesting to you personally? What do you hope to learn? --->

We were both interested in this project because we thought it'd be a perfect fit for our interests in sports and mathematics. As a result we came up with this idea to visualize sports statistics in a visual and interactive way. 

This project required data retrieval from the National Basketball Association's official database using an api and extracting useful data that we then used to draw graphs/charts to visualize statistical comparisons between individual pairs of players.


### Analysis
Explain what approaches from class you will bring to bear on the project.

We used several approaches from class to accomplish the task at hand:
1. Data Abstraction: When the call to draw graphs from the browser is made, the calling procedure need only know the names of the players whose statistics are to be compared. The multitude of procedures that process the player data, filter out the plottable numbers, statistic names and values, averaging out the numbers over the course of the entire season, and mapping statistic names over the values so we can  is not visible outside of the file plotting procedure which is called to plot charts. An example is the procedure that returns the list of hashmaps of a single player's stats overthe course of 82 games in a season:

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

2. Recursion: For every player, we use recursion to traverse their list of hashmaps, extract a single stat from each list of hash maps, and to accumulate a stat over 82 games in a regular season.

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

3. Map/Filter/Reduce: We used map, after getting the list of average values of each statistic throughout the length of the NBA season for each player, to make a list of vectors with the stat we're plotting and each value. This is the vector that's passed to `(plot-singles)` to in turn return a bar chart. Map filter and reduce were all critical for transforming the data to use in the webserver where appropriate.

```scheme
,(render-dropdownEntrys
(map (lambda (x) (dropdownEntry x))
(filter (lambda (x) (playerEntryExists? x))
(findPlayersOnTeam (extract-binding/single 'team1dropdown (request-bindings request)))))
```
- Will you use functional approaches to processing your data? How?
 All of our data is processed through functional approaches. We wrote a handful of procedures to manipulate the data in a way particularly suited to the usage. There are numerous examples throughout the code of multiple-series transformations we do to filter and reduce the data and break it into data structures we can use throughout the application. 

```scheme
(define (parseResponse responseString)
(hash-ref (car (hash-ref (string->jsexpr responseString) 'resultSets)) 'rowSet))

(define (findPlayersOnTeam teamAbv)
(map (lambda (x) (hash-ref x 'display_name)) (hash-ref (newAPIRoster teamAbv) 'players)))
```

<!---

- Will you use state-modification approaches? How? (If so, this should be encapsulated within objects. `set!` pretty much should only exist inside an object.)
- Will you build an expression evaluator, like we did in the symbolic differentatior and the metacircular evaluator?
- Will you use lazy evaluation approaches?
--->
Since the data we're be using is retrieved from a JSON object, we created different presentations of this data for whichever style chart the user requests or is available. 

Some data maps different statistical functions, like the mean shooting percentage, over a list of players and their respective lists of shots data. This required creating objects to represent different players and teams, thus the need for object orientation.
We recursively call functions to 'cdr' through while processing data in different lists.

<!---
The idea here is to identify what ideas from the class you will use in carrying out your project. 

**Your project will be graded, in part, by the extent to which you adopt approaches from the course into your implementation, _and_ your discussion about this.**
--->

### External Technologies

- Retrieve information or publish data to the web 
- Interact with databases
- JSON to jsexpr

We use CSS and Javascript to help format the final representation of the charts in a browser window in a visually appealing manner.

### Data Sets or other Source Materials
We used an api to retrieve data from the National Basketball Association's database (http://stats.nba.com). This data is then processed and presented in forms of bargraphs. 

<!--- How will you convert your data into a form usable for your project?   --->

The data we're using is received in JSON format. (snippet in testcode.rkt) We used racket's list processing to make use present data belonging to one player (list of hashmaps). 


### Deliverable and Demonstration

We currently have a fully funtional program that retrieves data from the NBA's official database, and presents it as bar graphs of different statistics that a user chooses. If a user wants to compare different statistics between two different players or teams, they can fire up the browser, and choose from the options listed in a menu. Comparisons are all presented as graphs. 

Given the problems we encountered dealing with different apis, we did not continue with some of the features we had listed as addons. Features like predicting future game results depending on past game data were cut out because with the change of apis, came a change of what kind of data we had access to and it's format.

The only form of interactivity that has been implemented is the ability to choose between different players from different teams teams and compare certain aspects of their games. 

<!---
Explain exactly what you'll have at the end. What will it be able to do at the live demo?

What exactly will you produce at the end of the project? A piece of software, yes, but what will it do? Here are some questions to think about (and answer depending on your application).

Will it run on some data, like batch mode? Will you present some analytical results of the processing? How can it be re-run on different source data?

Will it be interactive? Can you show it working? This project involves a live demo, so interactivity is good.
--->
### Evaluation of Results
How will you know if you are successful? 
<!-- If you include some kind of _quantitative analysis,_ that would be good.--->

We can successfully provide statistics for the 2016/16 season of the NBA. This was our primary goal at the beginning of this project and we are confident that we accomplished it.
We can successfully process a user's request from the given options and visualize the requested comparisons. Some of the stretch goals we had were not implemented but despite that, we still accomplished the primary goals of this project.

## Architecture Diagram
![Alt text](/resources/ArchDiag.jpg?raw=true)

### Process
When a user fires up the browser, they are met with precompiled lists of teams and players. When two players are chosen, their season statistics are retrieved as a list of hashmaps where each hash represents a single game the player participated in during the aforementioned season. When this list is received, individual stat values are filtered out, placed ina list and that list is averaged out over the number of games the player participated in. 
This happens for all the available stats in the player's hash. A new list of average values is created and mapped with the names of the statistics to create a list of vectors that are passed to ` (draw-main-plot) ` which returns all the stats in one chart. 
The `(plot-singles)` procedure is recursvely called with each vetor in that list to plot individual charts and each is formatted with CSS and displayed in  the browser. 


### First Milestone (Sun Apr 9)
We hoped to have the back-end of the program done by this date and we managed to accomplish that goal. We were able to process teh data we retrieved from the database and add the functionality to draw pass processed lists to the drawing procedures. Not many statistical evaluations were needed in this step, so none were done.

### Second Milestone (Sun Apr 16)
By this date, we'd hoped to have the visual part of the program completed. However, we ran into a few problems that stagnated our progress. The initial apis we used stopped resopnding and we had to take down major parts of the program we'd already built. Considering the fact that we couldn't proceed efficiently without any data, we weren't able to meet this goal by the aforementioned fate. 

### Public Presentation (Fri Apr 28)
We now have a fully implmented and functional program. Both the visual and data processing parts of the program are fully implemented. We ran into some problems but at the moment we are pretty jhappy and overall impressed with what we've been able to accomplish.

## Group Responsibilities
<!--- Here each group member gets a section where they, as an individual, detail what they are responsible for in this project. Each group member writes their own Responsibility section. Include the milestones and final deliverable. --->

<!--- Please use Github properly: each individual must make the edits to this file representing their own section of work--->
<!---
**Additional instructions for teams of three:** 
* Remember that you must have prior written permission to work in groups of three (specifically, an approved `FP3` team declaration submission).
* The team must nominate a lead. This person is primarily responsible for code integration. This work may be shared, but the team lead has default responsibility.
* The team lead has full partner implementation responsibilities also.
* Identify who is team lead.

In the headings below, replace the silly names and GitHub handles with your actual ones.
--->
### Patrick Kyoyetera: @legend855
I was able to implment the data processing and plotting parts of the program. I took care of the statistical analysis on the data we pulled even though there wasn't much to be done.


### Daniel DiTommaso @DanielDiTommaso
Successfully implemented DataService API which can communicate with two different statistics APIs. WebServer which dynamically builds HTML to build a user interface that is accessible from the web. 
