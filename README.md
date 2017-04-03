# StatsPros
Analyzing and visualizing sports statistics

### Statement
<!--- Describe your project. Why is it interesting? Why is it interesting to you personally? What do you hope to learn? --->

We're both interestd in this project because we thought it'd be a perfect fit for our interests in sports and also mathematics. As a result we 

This project will require us to retrieve data from a database using an api and extract useful bits of information that we can use to draw graphs and/or charts to visualize statistical comparisons and also make predictions(\*).
This 

### Analysis
Explain what approaches from class you will bring to bear on the project.

Be explicit about the techiques from the class that you will use. For example:

- Will you use data abstraction? How?
- Will you use recursion? How?
- Will you use map/filter/reduce? How? 
- Will you use object-orientation? How?
<!---
- Will you use functional approaches to processing your data? How?
- Will you use state-modification approaches? How? (If so, this should be encapsulated within objects. `set!` pretty much should only exist inside an object.)
- Will you build an expression evaluator, like we did in the symbolic differentatior and the metacircular evaluator?
- Will you use lazy evaluation approaches?
--->
Since the data we'll be using for will be retrieved from a JSON obuject, we shall need to create different presentations of this data for whichever style chart the user requests or is available. 

some data will need to map different statistical functions over, like the mean shooting percentage over a list of players anbd their respective lists of shots data. This will require ccreating objects to represent different players and teams, thus the need for object orientation.
We'll need to recursively call functions to 'cdr' through while process =ing data in different lists and/or ring buffers.
<!---
The idea here is to identify what ideas from the class you will use in carrying out your project. 

**Your project will be graded, in part, by the extent to which you adopt approaches from the course into your implementation, _and_ your discussion about this.**
--->

### External Technologies

- Retrieve information or publish data to the web 
- Interact with databases 

### Data Sets or other Source Materials
We shall use the National Basketball Associaiton's api to retrieve data from its database http://stats.nba.com. This data will be presented as json object which will be parsed, sorted and presented in forms of graphs. 


<!--- How will you convert your data into a form usable for your project?   --->

The data we're using is received in JSON format. (snippet in testcode.rkt) We plan on using racket's list processing to make use present data belonging to one entity. 



### Deliverable and Demonstration

We hope to have a fully funtional program that can take input retrieved from a database, and present it in a format that a user chooses. If a user want s to compare different statistics between two different players or teams, theyy can fire up the repl, and choose from the options listed in a menu. Comparisons are to be presented as graphs/plots and charts if manageable. 

The program will therefore rely entirely on data provided from the stats.nba.coim website. Although if we manage to 
 implement the portion for the NBA, we may try to attempt to do the same for data from other sports like soccer or baseball. 

The only form of interactivity that has been envisioned will be theability to have a user choose between different players or different teams and compare certain aspects that we can provide. 
This will involve some sort of menu that a user can check out for the supported teams and/or players.

<!---
Explain exactly what you'll have at the end. What will it be able to do at the live demo?

What exactly will you produce at the end of the project? A piece of software, yes, but what will it do? Here are some questions to think about (and answer depending on your application).

Will it run on some data, like batch mode? Will you present some analytical results of the processing? How can it be re-run on different source data?

Will it be interactive? Can you show it working? This project involves a live demo, so interactivity is good.
--->
### Evaluation of Results
How will you know if you are successful? 
<!-- If you include some kind of _quantitative analysis,_ that would be good.--->

If we can successfully process each user's request from the given options and visualize the requested comparisons and/or make future predictions(this willbe implmented if there's enough time left when the main project is complete), while always processing the latest available data from the league's games, we shall have successfully completed out project.

## Architecture Diagram
Upload the architecture diagram you made for your slide presentation to your repository, and include it in-line here.

Create several paragraphs of narrative to explain the pieces and how they interoperate.

## Schedule
<!---Explain how you will go from proposal to finished product. 

There are three deliverable milestones to explicitly define, below.

The nature of deliverables depend on your project, but may include things like processed data ready for import, core algorithms implemented, interface design prototyped, etc. 

You will be expected to turn in code, documentation, and data (as appropriate) at each of these stages.

Write concrete steps for your schedule to move from concept to working system. 
--->
### First Milestone (Sun Apr 9)
The backed of the program should be done by this date. We should be able to process information retrieved from the database and pass it to drawing functions in processed-lists. This should also involve statistical evaluations if needed.

### Second Milestone (Sun Apr 16)
By this date, we hope to have the visual part of the program completed. 
We should have the user interface complete with all the available options that our program can handle. 

### Public Presentation (Mon Apr 24, Wed Apr 26, or Fri Apr 28 [your date to be determined later])
We hope that by this date we shall have a fuill functional program with both the visual and data processing parts of the program full implemented.

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
I will implment the visual part of the program, handle drawing charts and plots. I will also handle the statistical analysis of the data that we shall be processing.


### Leonard Lambda @lennylambda
will work on...
   
