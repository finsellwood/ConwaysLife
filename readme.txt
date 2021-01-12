Conway's Life Code modified for asynchronous testing by Finlay Osman Sellwood
Compared to the main branch, which constitiutes a plain implementation, this readme will only include new functions.


RUNNING THE CODE
" {a b c} gather_data " runs simulations on the current grid dimensions for s values spanning from 'a' to 'b', each for 'c' generations. 
s is the synchronicity as a percentage, and by default spans 0 to 100. E.g. "50 100 3000 gather_data" will run simulations for 3000 generations 
each from an S value of 50% to an S of 100%, and the data for all the simulations is saved to the same text file.


Various parameters can also be adjusted;
{a} S ! will adjust synchronicity for individual runs, which can still be performed with any of the original commands.

CREATING AN INPUT FILE
Unchanged

INTERPRETING OUTPUT DATA
The output file for "gather_data" is different to the file if any other run command is executed. It has 4 colums which are, from left to right;
Generation number
Activity that generation (number of cells that changed state)
S value (percentage synchronicity)
Number of living cells
