{ This file contains the rules and routines for runnning life. It is called inside 'main.f' }

{ -----------initialising arrays----------- }
{ two arrays, one for no. neighbours and one for living/dead }

variable gridx
variable gridy
variable gridlength
variable wrapping { if want coords to wrap around screen }
variable neighbour_array_loc
variable living_array_loc
variable randomseed 
variable stepcounter { to count how many generations have passed }
variable lives
variable maxneighbours
variable S { for synchronicity }

100 gridx !
gridx @ 4 / 1 max 4 * gridx ! { must be a multiple of four for BMP later }
100 gridy !

gridx @ gridy @ * gridlength !

-1 wrapping !
2 randomseed !
1 lives !
8 lives @ * 1+ maxneighbours ! 
100 S ! 
100 constant maxs
{ initialise to examine all cells, write fraction as S = 1,2,3,4,...,10 for a tenth etc. of cells checked - avoids floats }


: RESET_GRIDSIZE gridx @ 4 / 1 max 4 * gridx ! 
				 gridx @ gridy @ * gridlength ! ;

{ a, b } : SET_AXES gridy ! gridx ! RESET_GRIDSIZE ;
{ resets the axes - run the initialise commands again to rebuild arrays }

: MAKE_ARRAY gridlength @ ALLOCATE DROP DUP 
	gridlength @ 0 FILL ;
{ makes correct length array and puts address on stack (have to then save as a constant) }

: CREATE_ARRAYS make_array neighbour_array_loc ! make_array living_array_loc ! ;
{ two arrays for living/dead and #neighbours }


: clean begin drop depth 1 < until ; 
{ command to clean stack }

: SHOW_NEIGHBOUR_ARRAY cr
	 0 gridlength @ gridx @ - do 
		gridx @ 0 do 
			neighbour_array_loc @ I J + + c@ . 
		LOOP cr
	gridx @ -1 * +loop ;

: SHOW_LIVING_ARRAY cr
	 0 gridlength @ gridx @ - do 
		gridx @ 0 do 
			living_array_loc @ I J + + c@ . 
		LOOP cr
	gridx @ -1 * +loop ;
{ show the neighbour and living arrays }


: N_ARRAY_! gridx @ * + neighbour_array_loc @ + C! ;
{ a b c N_ARRAY_! will put 'a' at array location (b,c) where 0,0 is top left and the top row is (0,0) to (199,0)}

: N_ARRAY_INC gridx @ * + neighbour_array_loc @ + dup C@ rot + swap C! ; 
{ a b c will add a to value at b,c in neighbour array }

: N_ARRAY_@ gridx @ * + neighbour_array_loc @ + C@ ;
{ a b N_ARRAY_@ will put value at (a,b) on top of stack}

: L_ARRAY_! gridx @ * + living_array_loc @ + C! ;
{ a b c L_ARRAY_! will put 'a' at array location (b,c) where 0,0 is top left and the top row is (0,0) to (199,0)}

: L_ARRAY_@ gridx @ * + living_array_loc @ + C@ ;
{ a b L_ARRAY_@ will put value at (a,b) on top of stack}

{ -------------Populating grids----------------- }

: RANDOM_FILL_N_ARRAY 
	gridy @ 0 do 
		gridx @ 0 do 
			9 rnd I J N_ARRAY_! 
		loop  
	loop ;
{ puts random val from 0 to 8 into every element }

: RANDOM_FILL_L_ARRAY 
	gridy @ 0 do 
		gridx @ 0 do 
			lives @ 1+ rnd I J L_ARRAY_! 
		loop  
	loop ;
{ fills with cells of random values from 0 to lives (constant) }

: RANDOM2_FILL_L_ARRAY
	gridy @ 0 do
		gridx @ 0 do
			randomseed @ rnd 1 = if lives @ I J L_ARRAY_!
			else 0 I J L_ARRAY_! then
		loop
	loop ;
{ an improved random function - the value of randomseed determines the fraction of cells occupied - 2 gives 1/2, 3 gives 1/3 etc }
{ ## updated to set intial value to 'lives' rather than 1 }

{ a b } : ADD_GLIDER Locals| y_coord x_coord |
	1 x_coord 1 + y_coord L_ARRAY_!
	1 x_coord 2 + y_coord 1 + L_ARRAY_!
	1 x_coord y_coord 2 + L_ARRAY_!
	1 x_coord 1 + y_coord 2 + L_ARRAY_!
	1 x_coord 2 + y_coord 2 + L_ARRAY_!
	;
{ adds glider at grid coords a,b }

: reset_neighbours
	gridy @ 0 do
		gridx @ 0 do
			0 I J N_ARRAY_!
			loop
		loop ;

: reset_array
	gridy @ 0 do
		gridx @ 0 do
			0 I J L_ARRAY_!
			loop
		loop ;
{ reset the two arrays }
{ ----------counting values ----------- }

: n_countertable maxneighbours @ 4 * ALLOCATE DROP DUP maxneighbours @ 4 * 0 FILL ;
n_countertable
constant n_counter_loc
{ builds an array for neighbour vals 0 to max no. neighbouring lives }

: l_countertable 8 ALLOCATE DROP DUP 8 0 FILL ;
l_countertable
constant l_counter_loc

: gen_countertable 20 ALLOCATE DROP DUP 20 0 FILL ;
gen_countertable {  0: no survived | 1: no. born | 2: no. died }
constant gen_counter_loc

: clear_n_counters 9 0 do 0 n_counter_loc I 4 * + ! loop ;
: clear_l_counters 2 0 do 0 l_counter_loc I 4 * + ! loop ;
: clear_gen_counters 5 0 do 0 gen_counter_loc I 4 * + ! loop ;
{ clears counter values }

: n_array_counter 4 * n_counter_loc + dup @ 1+ swap ! ;
: l_array_counter if 4 l_counter_loc + dup @ 1+ swap ! then ;

{ increments counter corresponding to the number on the stack }
{ updated to account for non-binary living values }

: inc_survived gen_counter_loc dup @ 1+ swap ! ;
: inc_born gen_counter_loc 4 + dup @ 1+ swap ! ;
: inc_died gen_counter_loc 8 + dup @ 1+ swap ! ;
: inc_activity gen_counter_loc 12 + dup @ 1+ swap ! ;
: inc_updated gen_counter_loc 16 + dup @ 1+ swap ! ;

{ increment each counter respectively, irregardless of stack }
{ 'died' now implies lost a life, not actually extinct (e.g. went from 3 to 2 lives) }
{ can caluclate actual extinct value by taking living no. from this gen and subtracting previous }
{ activity is for synchronicity experiment, number of cells that 'flip' per generation }


: check_occupancy clear_n_counters clear_l_counters 
	gridlength @ 0 do 
		I neighbour_array_loc @ + C@ n_array_counter 
		I living_array_loc @ + C@ l_array_counter 
	loop ;
{ applies counters to every number in the array }


: display_counters cr ." Neighbours " maxneighbours @ 0 do cr I . ." : " n_counter_loc I 4 * + @ . loop cr 
					 l_counter_loc 4 + @ . ." Living " l_counter_loc @ . ." Dead " ;

{ displays counter values }



{ ------------check if living-------------- }

: will_survive case
2 of inc_survived true endof 
3 of inc_survived true endof 
drop inc_died inc_activity false dup 
endcase ;
{ check if a currently living cell will survive }


: will_form case
3 of inc_born inc_activity true endof { increments 'number born' counter if true }
{ 6 of inc_born true endof }
drop false dup
endcase ;
{ check if currently dead cell will become alive }

{ a b } : update_value inc_updated over over L_ARRAY_@ if N_ARRAY_@ will_survive else N_ARRAY_@ will_form then ;
{ a, b on stack, will return true (-1) if the cell at that location will be alive next cycle (i.e. survives or is formed), and false if not }
{ 'over over' takes a b on stack and makes it a b a b, so can read twice }

: refresh_cells 
	gridy @ 0 do
		gridx @ 0 do
			I J update_value -1 * I J L_ARRAY_!
		loop
	loop ;

: refresh_cells_2
	gridy @ 0 do
		gridx @ 0 do 
			maxs rnd S @ < if I J update_value 
				if 
					lives @ I J L_ARRAY_!
				else
					I J L_ARRAY_@ dup
					if 
						1- I J L_ARRAY_!
					else
						drop
					then
				then
			then
		loop
	loop ;
{ if a cell 'will survive' it is reset to 3 lives, as are new cells }
{ cells which won't survive are decremented by one (so that they will be dead after three generations) }



{ a b } : in_grid 	
	dup gridy @ < swap 0 >= and swap
	dup gridx @ < swap 0 >= and and ; 
{ returns logical true/false if coords a, b are inside of grid range}

{ a b } : wrap_coord Locals| y_init x_init |
	x_init gridx @ + gridx @ mod
	y_init gridy @ + gridy @ mod ;
{ a b leaves wrapped coords on stack }


: count_neighbours_w Locals| y_coord x_coord |
	0 x_coord y_coord N_ARRAY_! 
		2 -1 do
			2 -1 do
				I J 0= swap 0= and not if
					x_coord I + y_coord J + wrap_coord L_ARRAY_@ x_coord y_coord N_ARRAY_INC
				then
			loop 
		loop ;				
{ counts the no. filled cells around cell a, b, sets that no. as no. neighbours }
{ for when cells should wrap over ( making separate functions saves processing time) }

: count_neighbours_nw Locals| y_coord x_coord |
	0 x_coord y_coord N_ARRAY_! 
		2 -1 do
			2 -1 do
				I J 0= swap 0= and not if
					x_coord I + y_coord J + { x, y are in stack (x deeper) }
					over over in_grid if 
						L_ARRAY_@ x_coord y_coord N_ARRAY_INC
					else 
						drop drop 
					then
				then
			loop 
		loop ;			
{ for not wrapping }

: count_neighbours_vn_w Locals| y_coord x_coord |
	0 x_coord y_coord N_ARRAY_! 
		x_coord 1- y_coord wrap_coord L_ARRAY_@ x_coord y_coord N_ARRAY_INC	
		x_coord 1+ y_coord wrap_coord L_ARRAY_@ x_coord y_coord N_ARRAY_INC	
		x_coord y_coord 1- wrap_coord L_ARRAY_@ x_coord y_coord N_ARRAY_INC	
		x_coord y_coord 1+ wrap_coord L_ARRAY_@ x_coord y_coord N_ARRAY_INC	
;				
{ counts neighbours in von Neumann neighbourhood, easier/quicker w.o. loop structure }
{ this wasn't used in the final report }

: find_neighbours_2
	wrapping @ if
		gridy @ 0 do
			gridx @ 0 do
				I J count_neighbours_w
			loop
		loop 
	else
		gridy @ 0 do
			gridx @ 0 do
				I J count_neighbours_nw
			loop
		loop 
	then ;
{ reduces no. if statements }


{ ---------------saving files ---------------- }

variable file-id
: make-data-file                                  
  s" lifefile.csv" r/w create-file drop 
  file-id !                                  
;

: open-data-file                               
  s" lifefile.csv" r/w open-file drop    
  file-id !                                
;

: close-data-file                                
  file-id @                                 
  close-file drop
; 

: write-delimiter                                        
  s" ," file-id @ write-file drop
;
{ adds delimiter to vals }

: write-number                                     
  (.) file-id @ write-file drop
;

: write-blank-data                                        
  s"  " file-id @ write-line drop
;
{ adds blank line (CR) }

: write-data-line write-number write-delimiter write-number write-delimiter write-number write-delimiter write-number write-blank-data ;
{ writes two numbers from stack into a row in data file }

: write-long-data-line maxneighbours @ 0 do write-number write-delimiter loop 
  write-number  write-delimiter write-number  write-delimiter write-number 
  write-delimiter write-number  write-delimiter write-number write-blank-data ;
{ writes all data from the stack into a row in data file }

{ -----------------full iterating code---------------------}

: initialise_random create_arrays random2_fill_l_array find_neighbours_2 1 stepcounter ! ;

: save_data l_counter_loc 4 + @ stepcounter @ maxneighbours @ 0 do n_counter_loc I 4 * + @ loop 3 0 do gen_counter_loc I 4 * + @ loop write-long-data-line ;
{ saves the step and the number of live cells onto a line }

: save_small_data l_counter_loc 4 + @ S @  gen_counter_loc 12 + @ stepcounter @ write-data-line ;
{ saves 'activity' rather than no. living }


: step check_occupancy save_data clear_gen_counters refresh_cells_2 find_neighbours_2 stepcounter @ 1+ stepcounter ! ;
{ step is for normal experiments }
: step2 check_occupancy save_small_data clear_gen_counters refresh_cells_2 find_neighbours_2 stepcounter @ 1+ stepcounter ! ;
{ step2 is for synchronicity experiments as it only saves necessary data }

{ a } : run_random_no_display cr ." Running random simulation without display for " 
	dup . ." generations "
	cr gridx @ . ." x " gridy @ . ." Array" cr
	make-data-file
	initialise_random 
	0 do step loop 
	close-data-file
  ." Data saved "
  ." Simulation finished " ;

{ -----------------EXPERIMENT CODE-----------------}
{ iterating through values of S and recording population data with time }

{ a b c } : gather_data Locals| gens stp strt | cr ." Gathering data for population vs time vs synchronicity for "
	gens . ." generations per value "
	cr gridx @ . ." x " gridy @ . ." Array" cr
	make-data-file
	stp 1+ strt do I S ! 
		initialise_random 
		gens { maxs * I / } 0 do step2 loop
		." S = " s @ . ." Simulation for " gens { maxs * I / } .  ." generations complete " cr
	loop
	close-data-file
	." Data saved "
	." Simulation finished "
	;

{ Records values while varying synchronicity, a b are start and stop for varying s, c is no. generations }