{ ======================READING CODE=======================}
{ code to load an array from a .txt document }
{ This method takes the block of text and saves it as an array (of ascii values)
in memory. The code then iterates through the array and decodes each value into 
the 'living' array.}

variable input-file-id
variable input-size
variable holding-loc

: open-input-file                               
  s" inputfile.txt" r/w open-file drop dup  
  input-file-id ! file-size drop drop input-size !                         
;
{ opens data file, saves its id and its length (in characters ) }

: close-input-file                                
  input-file-id @                                 
  close-file drop
; 

: make-unpacking-array input-size @ allocate drop dup input-size @ 0 fill holding-loc ! ;
{ creates block of memory large enough to unpack file and fills with zeroes, saves location }

: read-input-file holding-loc @ input-size @ input-file-id @ read-line drop drop drop ;

: show-holding-array input-size @ 0 do holding-loc @ I + c@ loop ;
{ for debugging }

: loadinput
open-input-file
make-unpacking-array
read-input-file
close-input-file
;

variable inputx
variable inputy

: finddims 1 inputy ! input-size @ 0 do 
holding-loc @ I + c@
case
			13 of inputy @ 1+ inputy ! endof
endcase
loop
input-size @ 2 + inputy @ 2 * - inputy @ / inputx !
inputx @ inputy @ { puts dimensions onto stack }
;
{ finds number of rows and columns of input file }
{ the sequence '10 13' indicates a carriage return - the number of '13's is therefore 
related to the number of rows. Number of columns can be determined from this and the file size }

variable xindex
variable yindex 

{ a b } : unpack-input yindex ! xindex !
	input-size @ 0 do 
	holding-loc @ I + c@ { find value in unpacking array }
		case
			48 of 0 xindex @ yindex @ L_ARRAY_! xindex @ 1+ xindex ! endof
			49 of 1 xindex @ yindex @ L_ARRAY_! xindex @ 1+ xindex ! endof
			13 of 0 xindex ! yindex @ 1 - yindex ! endof
		endcase
	loop ." input unpacked " ;
{ unpack the file from its holding location into the living array }

: nextfour dup 4 mod 4 swap - + ;
{ finds next multiple of four (even if already multiple of four ) }

: full-load-from-file loadinput finddims gridy ! nextfour gridx ! reset_gridsize create_arrays 0 gridy @ unpack-input ;
: load-from-file loadinput 0 finddims swap drop unpack-input ;
{ two ways to set up the system with an input file - the first creates an array the exact size of the input, 
the second uses the preset array dimensions}

: initialise_fromfile full-load-from-file find_neighbours 1 stepcounter ! ;
: initialise_withfile create_arrays load-from-file find_neighbours 1 stepcounter ! ;
{ full initialisation codes to be run at the start of any routine }