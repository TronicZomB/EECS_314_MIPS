#Steve Paley
#EECS 314
#HW 3 Problem 4
#
#Read integer N in and print the contents of 
#the next N registers starting at 0x00400000
#to the console.
#
#Register Use:
#	$t0: N
#	$t1: Loop index counter
#	$t2: Base address of 0x00400000
#	$t3: General Purpose
#	$t4: Stored contents of register

	.data					#Data Declarations
numN:	.asciiz "Enter an integer N: "
outLn:	.asciiz "The contents of the next N registers starting at 0x00400000 are:\n"
newLn:	.asciiz "\n"
output: .space 11			#11 bytes; 2 for 0x, 8 for output, 1 for null termination

	.text
	.globl main
main:
	#Get the input integer N
	la $a0, numN			#Load address of string to print to $a0
	li $v0, 4				#Load code to print string (4) to $v0
	syscall					#Print string to console
	li $v0, 5				#Load code to read integer (5) to $v0
	syscall					#Read integer N in
	add $t0, $v0, $zero		#Store N to $t0

	#Print the output to the console
	la $a0, outLn 			#Load address of string to print to $a0
	li $v0, 4				#Load code to print string (4) to $v0
	syscall					#Print the string to console

	add $t1, $zero, $zero	#Start the loop index count at 0 in $t1
	li $t2, 0x00400000		#Load the starting address to $t2

loop:
	li $t3, 4				#Load the offset value of 4 to $t4
	multu $t1, $t3			#Get the address offset by four
	mflo $t3				#Move the multiply results to $t4
	add $t3, $t3, $t2 		#Add the address offset to the base address of 0x00400000
	lw $t4, ($t3)			#Load the contents of the register address in $t4

	jal IntToHex			#Convert Integer to Hex

	la $a0, output			#Load the contents of the register at the address located in $t4
	li $v0, 4				#Load code to print a character to console
	syscall					#Display value of register contents at address 0x00400000 + (index * 4)

	la $a0, newLn			#Load address of string to print to $a0
	li $v0, 4				#Load code to print string (4) to $v0
	syscall					#Print a new line to the console
	addi $t1, $t1, 1		#Increment the index by one
	bne $t0, $t1, loop		#If the index is not equal to N, goto loop

finish:						#Otherwise finish
	li $v0, 10
	syscall


#Convert the integer contents of the register to hex to display on the console
#
#Registers:
#	$t5: Mask of 0b1111
#	$t6: output value
#	$t7: General Purpose
#	$t8: General Purpose
#	$t9: Loop index counter

IntToHex:
	li $t5, 15				#Load the mask into $t5
	la $t6, output			#Load output to $t6
	li $t9, 8				#Load loop index

#Establish known portions of output (0x????????[null terminated])
	li $t7, 48				#Load char '0'
	sb $t7, 0($t6)			#Store '0' into output
	li $t7, 120				#Load char 'x'
	sb $t7, 1($t6)			#Store 'x' into output
	li $t7, 0 				#Load NULL
	sb $t7, 10($t6)			#Store the NULL at the end of the output
	addi $t6, $t6, 9			#Point to last hex digit in output

#Convert the register contents to hex values
hex_loop:
	and $t7, $t4, $t5		#AND the contents with the mask
	li $t8, 9				#Load $t8 with 9
	ble $t7, $t8, zero_nine #If $t4 & $t5 is <= 9, branch to convert it to a digit char

	addi $t7, $t7, 55		#Add 55 to $t7 to get char 'A'-'F'
	j cont_hex_loop			#Jump to continue the hex loop

zero_nine:
	addi $t7, $t7, 48		#Add 48 to $t7 to get char '0'-'9'

cont_hex_loop:
	sb $t7, ($t6)			#Store byte to output
	srl $t4, $t4, 4 		#Shift right logical contents
	addi $t6, $t6, -1 		#Decrement the output pointer
	addi $t9, $t9, -1 		#Decrement loop index
	bne $t9, $zero, hex_loop #If loop index count != 0 continue the hex loop

	jr $ra 					#Return to the loop


