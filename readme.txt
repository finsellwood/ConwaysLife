Conway's Life Code by Finlay Osman Sellwood
This code consists of four files; 'main.f', 'inputcode.f', 'liferules.f' and 'rnd.f'. 
Along with this, an 'inputfile.txt' file is included to demonstrate reading from a file.
Note that this code is for a normal (synchronous) Life implementation, and the modified, asynchronous, code is found on the 'Asynchronous-Life' branch.

RUNNING THE CODE
To run the code, only main.f needs to be opened in SwiftForth (SF), the others are called internally. 
From here, the available commands are;
"showlife_rnd" - creates an instance of 'life' of preset size with random initial conditions, displaying continuously as a bitmap.
"showlife_fromfile" - as above, but the life instance is based (almost) exactly on 'inputfile.txt', with a few added spaces to ensure no data is cropped by the bitmap code.
"showlife_withfile" - uses 'inputcode.txt', but places the data in the bottom left of the preset (blank) life grid rather than making the grid the same size as the data.
"{a} run_random_no_display" - runs without bitmap display for 'a' generations (a must be on the stack)
Each of these will run until a key is pressed, and will save all relevant data to 'lifefile.csv', which is created by the program.

Various parameters can also be adjusted;
" {a b } set_axes " updates the life grid to have dimensions (a,b), where a b are on the stack. Defaults to 100 x 100.
" {a} randomseed ! " changes the fraction of cells initialised to be alive (a must be an integer greater or equal to two).
" 0 wrapping ! " or " -1 wrapping ! " changes the array to have absorbing or wrapping walls respectively (defaults to wrapping, i.e. -1 ).
After using any of these, re-run the desired instance command (e.g. showlife_rnd)

The life array (containing 1s and 0s) and the array of neighbours (containing the number of neighbours each cell possesses) 
can be printed to the SF console with " show_living_array " and " show_neighbour_array ".

CREATING AN INPUT FILE
These must only contain 0s and 1s (no spaces), and each line should be delimited by pressing 'enter' on the keyboard. (see inputfile.txt for an example). 
The input file should then be renamed 'inputfile.txt'.

INTERPRETING OUTPUT DATA
The output file (lifefile.csv) has 14 columns per line (generation), which from left to right indicate;

number of cells which died that generation
no. born
no. survived
no. cells with 8 neighbours
- 7 neighbours
- 6 neighbours
...
- 0 neighbours
the generation number
the number of living cells


REFERENCES
"main.f" is heavily adapted from the supplied 'Helper Code' file "Graphics_V6_Single_Scaled_BMP_Window.f" , and "rnd.f" is copied exactly from it.
