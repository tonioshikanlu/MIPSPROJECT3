.data 
   userInput:   .space 1000
   empty_string_error:   .asciiz "Input is empty."
   too_long:   .asciiz  "Input is too long."
   invalidSpaces:   .asciiz   "Invalid base-35 number."
.text 
main:  # This is the beginning of my main program.
   li $v0, 8  
   la $a0, userInput # This reads the user's string input.
   li $a1, 1000	# This assigns a space of 1000 bytes for the user.
   syscall 
   # Added code for Project 3
	addi $sp, $sp, -8
	sw $a0, 4($sp) # This will save the user input onto the stack
	sw $ra, 0($sp) # This will store the return address on stack
	jal InputProcessor
	lw $t8, 0($sp) # This will load the return value from the stack 
	addi $sp, $sp, 4 # This line restores the stack pointer
        addi $sp, $sp, -8 # This validates space on stack from function parameter and return address 
	sw $t8, 4($sp) # This will save the number to display on stack
	sw $ra, 0($sp) # This will save the return address onto stack
	jal ShowSum
	j exit
InputProcessor:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # This will save return address on stack
	jal remove_spaces_before
	jal delete_after_spaces
	jal Length_Counter
	lw $ra, 4($sp) # This sends the return address in $ra
	lw $t8, 0($sp) # This will load the return value from the stack
	addi $sp, $sp, 8 
	addi $sp, $sp, -4
	sw $t8, 0($sp)  # This will save the return value onto the stack 
	jr $ra 

# This portion of code fixes the bug from my project 2
	space_deletion_before:
	li $t8, 32                     
	lw $a0, 8($sp)                  # load user address position from the stack
	
	space_deletion_loop:
	lb $t7, 0($a0)                  # load first input char into t7
	beq $t8, $t7, initial_char_deletion # This will remove the initial character if it is a space
	move $t7, $a0                   # if not a space save new input begining address into t7
	jr $ra

initial_char_deletion:

   addi $a0, $a0, 1 #This increments the counter.

   j initial_space_deletion #Jumps to conditional.
delete_after_spaces:

   la $t3, userInput  # Loads the user input.

   sub $t3, $t7, $t3 # This keeps the offset.
   li $t2, 0  #This will initialize the index of the last character in the string.

   li $t8, 0  #This loads the current index.
# This deals with the spaces condition.
space_loop_removal:

   add $t4, $t3, $t8

   addi $t4, $t4, -100

   beqz $t4, terminate_space_loop        # This will terminate if the string buffer exit has been seen.

   add $t4, $t8, $a0        # Obtains current index address.
   
   lb $t4, 0($t4)           # Loads current index.

   beq $t4, $zero, terminate_space_loop  # This will exit the loop to length of the string check, if string has been terminated.

   addi $t4, $t4, -10		# Continues the code.
   beqz $t4, terminate_space_loop        # This will exit the loop if an exitline character has been reached.

   addi $t4, $t4, -22

   bnez $t4, last_index_change # This will update last charcter not a space.
space_loop_removal_increment:

   addi $t8, $t8, 1              #This will Increment the character's current index .

   j space_loop_removal		# Jumps to space_loop_removal after code is run.

last_index_change:

   move $t2, $t8 # Moves current index into last index on basis of some considerations.

   j space_loop_removal_increment
terminate_space_loop:

   add $t4, $zero, $a0 

   add $t4, $t4, $t2 

   addi $t4, $t4, 1  
   sb $zero, 0($t4)     
   jr $ra
   
   # This section of code regained the address of the registers.

   j Length_Counter
   # This will check the Length of the user's Input.
Length_Counter:
        li $t5, 0             
        add $a0, $t7, $zero
	lb $t3, 0($a0)
        addi $t3, $t3, -10    
        beq $t3, $zero, Empty_string_error  

   Loop:
   lb $t3, 0($a0)
   or $t2, $t3, $t5
   beq $t2, $zero, Empty_string_error
   beq $t3, $zero, stringDone
   addi $a0, $a0, 1

   addi $t5, $t5, 1

   j Loop
   #Execute if exit of string has been reached.

stringDone:

   slti $t1, $t5, 5

   beq $t1, $zero, lengthError

   bne $t1, $zero, string_checker
     #Return error message showing an empty string.

Empty_string_error:

   li $v0, 4

   la $a0, empty_string_error

   syscall

   j exit
      
  #This will show an error message indicating string with too many characters.

lengthError:

   li $v0, 4

   la $a0, too_long

   syscall

   j exit    
 #This will check if the string is valid for characters exceeding base-35 representation.

string_checker:

   move $a0, $t7 # This will move the user input address from t7 to a0.

string_checkerLoop:

   li $v0, 11

   lb $t0, 0($a0)

   move $t8, $a0

   move $a0, $t0

   move $a0, $t8

   li $t8, 10               #This will check if the character is the newline character.

   beq $t0, $t8, baseConverter
   
   slti $t4, $t0, 48        #Check if the character is less than 0 

   bne $t4, $zero, InvalidBase

   slti $t4, $t0, 58        #Check if the character is less than 58 which is 9 

   bne $t4, $zero, Increment_character
   slti $t4, $t0, 65        #Check if character is less than 65 which is A 

   bne $t4, $zero, InvalidBase  

   slti $t4, $t0, 90        #Check if character is less than 90 which is Y 

   bne $t4, $zero, Increment_character

   slti $t4, $t0, 97       #Check if character is less than 97 which is a 
   bne $t4, $zero, InvalidBase 

   slti $t4, $t0, 121      #Check if character is less than 121 which is y 

   bne $t4, $zero, Increment_character

   bgt $t0, 121, InvalidBase 

   li $t8, 10              #Check is character is the newline character
   beq $t0, $t8, baseConverter     
Increment_character:

   addi $a0, $a0, 1

   j string_checkerLoop
     #Return error message indicating invalid base-35 number

InvalidBase:

   li $v0, 4

   la $a0, invalidSpaces

   syscall

   j exit
baseConverter:

   move $a0, $t7

   li $t3, 10

   li $t8, 0   		

   add $s0, $s0, $t5
   addi $s0, $s0, -1  

   li $s5, 3

   li $s4, 2

   li $s6, 1

   li $s3, 0
     
    #This is the character to number conversion process

changeString:     

   lb $s2, 0($a0)

   beqz $s2, return		

   beq $s2, $t3, return    	

   slti $t4, $s2, 58        #This check if the character is between (0-9)
   bne $t4, $zero, numberLine

   slti $t4, $s2, 90     # This checks if the character is between (A-Y)

   bne $t4, $zero, CapitalLetters

   slti $t4, $s2, 122   #This checks if the character is between (a-y)

   bne $t4, $zero, lowercaseLetters
   numberLine: # Check for digits.

   addi $s2, $s2, -48

   j power_Incrementer
CapitalLetters: #Check for capital letters.

   addi $s2, $s2, -55

   j power_Incrementer
lowercaseLetters: # Check for lowercase letters.

   addi $s2, $s2, -87
power_Incrementer: # Increments the powers of the base.

   beq  $s0, $s5, exp_three

   beq $s0, $s4, exp_two

   beq $s0, $s6, exp_one

   beq $s0, $s3, exp_zero
exp_three:  # Raises the base to power of three.

   li $s1, 42875

   mult $s2, $s1

   mflo $s7

   add $t8, $t8, $s7
   addi $s0, $s0, -1

   addi $a0, $a0, 1

   j changeString
exp_two: # Raises the base to power of two.

   li $s1, 1225

   mult $s2, $s1

   mflo $s7

   add $t8, $t8, $s7
    addi $s0, $s0, -1

   addi $a0, $a0, 1

   j changeString
exp_one: # Raises the base to power of one.

   li $s1, 35

   mult $s2, $s1

   mflo $s7

   add $t8, $t8, $s7
   addi $s0, $s0, -1

   addi $a0, $a0, 1

   j changeString
exp_zero: # Raises the base to power of zero

   li $s1, 1

   mult $s2, $s1

   mflo $s7

   add $t8, $t8, $s7
return:
	addi $sp, $sp, -4
	sw $t8, 0($sp)     # This saves the returned integer on the stack
	jr $ra 
	
ShowSum:
        li $v0, 1
        lw $a0, 4($sp) # This will load the total sum to be shownfrom the stack 
        syscall
        jr $ra

   syscall
exit:

   li $v0,10     

   syscall       
# Ends the program.
