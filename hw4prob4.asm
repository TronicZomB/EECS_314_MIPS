#Steve Paley
#sjp78
#EECS 314
#HW 4 Problem 4
#
#Binary Search
#
#Register Use:
#	$t0: array size N
#	$t1: value to search
#	$t2: left
#	$t3: right
#	$t4: mid
#	$t5: array[mid]
#	$t6: boolean, valueIsFound
#	$t7: not used
#	$t8: general purpose
#	$t9: general purpose

	.data					#Data Declarations
pointer:		.word 0		#pointer to array start location
numInts:		.asciiz "Enter the number of integers to be in the array: \n"
valInt1:		.asciiz "Value for n["
valInt2:		.asciiz "]: \n"
findVal:		.asciiz "Enter value to search for: \n"
valueNotFound1:	.asciiz "The value "
valueNotFound2: .asciiz " was not found in the array.\n"
valueFound1:	.asciiz "The value "
valueFound2:	.asciiz " was found at array index "

	.text
	.globl main
main:
	#Get the input array size N
	la $a0, numInts			#Load address of string to print to $a0
	li $v0, 4				#Load code to print string (4) to $v0
	syscall					#Print string to console
	li $v0, 5				#Load code to read integer (5) to $v0
	syscall					#Read integer N in
	add $t0, $v0, $zero		#Store N to $t0

	#Allocate array space
	li $t9, 4				#Load 4 into $t9
	multu $t9, $t0			#Multiply the number of items in the array by 4 bytes/item
	mflo $a0				#Move the multiply results to $a0
	li $v0, 9
	syscall					#Allocates the memory for array
	sw $v0, pointer			#Uses the pointer to point to the array in memory

	add $t9, $v0, $zero		#Use $t9 as array pointer
	add $t8, $zero, $zero	#Use $t8 as array index value

initArray:
	#Print array input prompt
	la $a0, valInt1			#Load address of string to print
	li $v0, 4				#Load code to print string (4) to $v0
	syscall					#Print string to console

	add $a0, $t8, $zero		#Load integer to print to console
	li $v0, 1				#Load code to print integer to console
	syscall					#Print integer

	la $a0, valInt2			#Load address of string to print
	li $v0, 4				#Load code to print string (4) to $v0
	syscall					#Print string to console

	li $v0, 5				#Load code to read integer (5) to $v0
	syscall					#Read integer in
	#Store integer inputs
	sw $v0, 0($t9)			#Store the input integer into the allocated array space
	addi $t8, $t8, 1 		#Increment the loop/array index by one
	addi $t9, $t9, 4		#Increment the address by 4
	bne $t0, $t8, initArray	#If the loop index does not equal the array size continue to add integers to the array

	#Otherwise get the upper/right and lower/left index values
	subi $t8, $t8, 1 		
	add $t3, $t8, $zero		#Store the last integer index value in $t3
	add $t2, $zero, $zero	#Store the first integer index value in $t2

#Get value to search for and store it in $t1
	la $a0, findVal
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	add $t1, $v0, $zero

	#Begin the binary search function
	jal binarySearch
	beq $t6, $zero, NotFound

Found:
	#First string of output printed to console
	la $a0, valueFound1
	li $v0, 4
	syscall
	#Integer value found printed to console
	add $a0, $t1, $zero
	li $v0, 1
	syscall
	#Second string of output printed to console
	la $a0, valueFound2
	li $v0, 4
	syscall
	#Integer of index location printed to console
	add $a0, $t4, $zero
	li $v0, 1
	syscall
	j finish

NotFound:
	#First string of output printed to console
	la $a0, valueNotFound1
	li $v0, 4
	syscall
	#Integer value not found printed to console
	add $a0, $t1, $zero
	li $v0, 1
	syscall
	#Second string of output printed to console
	la $a0, valueNotFound2
	li $v0, 4
	syscall				
	j finish

#############################################################
#Binary Search Function Begin                               #
#############################################################
binarySearch:
	#right < left
	slt $t8, $t3, $t2		#Set $t8 if the last integer index value is less than the first index
	beq $t8, $zero, continue	#If the last int index is not less than the first index, continue searching
	add $t6, $zero, $zero		#Value Found == false
	j endFunction

continue:
	add $t4, $t2, $t3		#Find midpoint index
	srl $t4, $t4, 1 		#Divide by 2

	li $t8, 4				#Load 4 into $t8
	lw $t9, pointer			#Load array base address to $t9
	multu $t4, $t8			#Multiply midpoint index by 4
	mflo $t8				#Move mult result to $t8
	add $t9, $t9, $t8		#Store address of midpoint, base + midpoint*4
	lw $t5, 0($t9)			#Load array midpoint value

	bne $t1, $t5, continue2 #If the midpoint value and value to be found are not equal, continue
	addi $t6, $zero, 1 		#Value found == true
	j endFunction

continue2:
	#Adjust left or right index
	slt $t8, $t1, $t5		#If the value is less than the midpoint value
	bne $t8, $zero, ValLTMid 
#Value greater than midpoint
ValGTMid:
	addi $t2, $t4, 1 		#Adjust the lower bound to the midpoint index +1
	j binarySearch			#Call binary search function recursively
#Value less than midpoint
ValLTMid:
	addi $t3, $t4, -1 		#Adjust the upper bound to the midpoint index -1
	j binarySearch			#Call binary search function recursively

endFunction:
	jr $ra 					#Jump back to main program

####################################
#Finish program                    #
####################################
finish:						#Otherwise finish
	li $v0, 10
	syscall