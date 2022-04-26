# Bid Controller using SystemVerilog
### ECE 593 Fundamentals of Pre-Silicon Validation - Group 16 :)
#### Supreet Gulavani, Sreeja Boyina
-----------------------------------------------------

### How to run
- Assuming you have Mentor QuestaSim and Make installed, `cd` to the project directory and run
       
    `make setup` : Sets up the work directory

    `make compile` : Compiles all .sv files
    
    `make opt`   : Optimizes the top module
    
    `make clean`   : rm -rf the builds
 
    `make release` : Runs the design and generates coverage with dynamically constrained stimulus
    
    `make report`   : Creates a functional and code coverage report
    
     `make html`   : Creates a HTML version of the coverage generated for better readability
