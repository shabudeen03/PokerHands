#Inconsistent comments (enough for some lines code, barely any for some) - rushed at times
#Afraid I messed up conventions - did not bother touching s registers or functions or _p registers

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
addr_arg4: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Output messages
straight_str: .asciiz "STRAIGHT_HAND"
four_str: .asciiz "FOUR_OF_A_KIND_HAND"
pair_str: .asciiz "TWO_PAIR_HAND"
unknown_hand_str: .asciiz "UNKNOWN_HAND"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION"
invalid_args_error: .asciiz "INVALID_ARGS"

# Put your additional .data declarations here, if any.
argD: .asciiz "D"
argE: .asciiz "E"
argP: .asciiz "P"
hand: .space 5 #The poker hand to sort

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory  
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
    li $t0, 2
    beq $a0, $t0, two_args
    li $t0, 3
    beq $a0, $t0, three_args
    li $t0, 4
    beq $a0, $t0, four_args
five_args:
    lw $t0, 16($a1)
    sw $t0, addr_arg4
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here

zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here    
    	#This tries to count how many characters there are in addr_arg0
    	lw $t0, addr_arg0 #Load first argument into t0
    	li $t1, 0 #Number of characters in addr_arg0 
    	li $t2, 1 #One character to represent D, E, P
    	
    	#Now loop to see if t1 is greater than 
    	opChecker:
    		lb $t3, 0($t0) #Load character
    		beqz $t3, checkOp #When null terminator received, then check the length of argument 
    		addi $t1, $t1, 1 #Increment count
    		addi $t0, $t0, 1 #increment index
    		#bgt $t1, $t2, invalidOp #If count greater than 1, invalid operation - it can't be D, E, or P at all
    		j opChecker
  	
  	checkOp:
  		bne $t1, $t2, invalidOp #if not equal, then invalid operation 
  
	#Reset t0 to be addr_arg0 again
	lw $t0, addr_arg0
	lb $t2, 0($t0) #t2 will access characters from addr_arg0
	
	#Check if first letter is D
	la $t1, argD #Get address of .asciiz into t1
    	lb $t3, 0($t1) #t3 will access characters from argD    	
    	beq $t2, $t3, checkDargs #If equal, then check arguments
    	
    	la $t1, argE
    	lb $t3, 0($t1)
    	beq $t2, $t3, checkEargs
    	
    	la $t1, argP
    	lb $t3, 0($t1)
    	beq $t2, $t3, checkPargs
    	j invalidOp #If none of the 3, print invalid operation error
    	
checkDargs:
	#t2-t3 I can use to check if num args is 2 or not
	li $t2, 2
	lw $t3, num_args
	bne $t2, $t3, invalidArgs
	
	#Check if second argument is a proper 8 digit hexadecimal with 0x prefix
	lw $t9, addr_arg1
	lb $t8, 0($t9)
	li $t7, 48
	bne $t8, $t7, invalidArgs
	
	#check for x in second index
	lb $t8, 1($t9)
	li $t7, 120
	bne $t8, $t7, invalidArgs
	
	addi $t9, $t9, 2 #Skip 0x to the first byte of hexadecimal
	
	#Process each byte for format
	li $t7, 0
	darg2Looper:	
		lb $t8, 0($t9)
		beqz $t8, continue #Null terminator
		addi $t7, $t7, 1 #increment count of digits
		addi $t9, $t9, 1 #Increment index
		
		#If character < 48 (0), invalid
		li $t6, 48
		blt $t8, $t6, invalidArgs
				
		li $t6, 57
		bgt $t8, $t6, hexChecker #This means its either a-f or invalid 
		
		#At this point, it is >= 48 and <= 57 so it is 0-9 or if hexChecker works, it is a-f		
		j darg2Looper		
		
	hexChecker: #check if a-f																		
		li $t6, 97
		blt $t8, $t6, invalidArgs
			
		li $t6, 102
		bgt $t8, $t6, invalidArgs
		j darg2Looper
	
	#In continue, check if it is 8 digits exactly
	continue:
		li $t8, 8		
		bne $t7, $t8, invalidArgs #Incorrect number of digits
	
	#Reload argument into t9, now process the argument
	lw $t9, addr_arg1
	addi $t9, $t9, 2 #Skip to the 8 bytes
	
	#At this point all registers besides t9 are fair game again
	li $t7, 0 #Set it to 0, on each byte load, convert to proper int value, shift to the left 4 bits
	li $t6, 8 #Digits left to read
	
	convertToHex:
		beqz $t6, processHex #If already did 8 iterations getting 4 bits each time, start processing 
		lb $t8, 0($t9)
		addi $t9, $t9, 1 #Increment to get next 4 bits
		addi $t6, $t6, -1 #Adjust counter for reading 4 bits
		sll $t7, $t7, 4
		
		li $t5, 58
		blt $t8, $t5, decimal #0-9  otherwise a-f below
		addi $t8, $t8, -87
		or $t7, $t7, $t8
		#sll $t7, $t7, 4
	
		j convertToHex
		
	decimal:
		addi $t8, $t8, -48
		or $t7, $t7, $t8
		#sll $t7, $t7, 4
		j convertToHex
	
	processHex:	
		srl $t0, $t7, 26
		
		sll $t1, $t7, 6
		srl $t1, $t1, 27
		
		sll $t2, $t7, 11
		srl $t2, $t2, 27
		
		andi $t3, $t7, 0xffff
		
	#First Argument
	li $t4, 10
	move $t5, $t0
	blt $t5, $t4, printZero
	j addValue
	
	printZero:
		li $v0, 11
		li $a0, '0'
		syscall
		j addValue
		
	addValue:
		li $v0, 1
		move $a0, $t5
		syscall
	
		li $v0, 11
		li $a0, ' '
		syscall
	
	#2nd argument
	move $t5, $t1
	blt $t5, $t4, printZero2
	j addValue2
	 
	printZero2:
		li $v0, 11
		li $a0, '0'
		syscall
		j addValue2

	addValue2:
		li $v0, 1
		move $a0, $t5
		syscall	
	
		li $v0, 11
		li $a0, ' '
		syscall
	
	#Third Argument
	move $t5, $t2
	blt $t5, $t4, printZero3
	j addValue3
	 
	printZero3:
		li $v0, 11
		li $a0, '0'
		syscall
		j addValue3

	addValue3:
		li $v0, 1
		move $a0, $t5
		syscall	
	
		li $v0, 11
		li $a0, ' '
		syscall
	
	#Fourth Argument
	move $t5, $t3
	li $t4, 10000
	bge $t5, $t4, printValue
	
	li $t4, 1000
	li $t6, 1 #COunter for how many 0s to pad
	bge $t5, $t4, zeroLoop
	
	li $t4, 100
	li $t6, 2
	bge $t5, $t4, zeroLoop
	
	li $t4, 10
	li $t6, 3
	bge $t5, $t4, zeroLoop
	
	li $t6, 4
	j zeroLoop
	
	zeroLoop:
		beqz $t6, printValue
		li $v0, 11
		li $a0, '0'
		syscall
		addi $t6, $t6, -1
		j zeroLoop
	
	printValue:
		li $v0, 1
		move $a0, $t5
		syscall	
			
	j exit
	
checkEargs:
	#t2-t3 I can use to check if num args is 2 or not
	li $t2, 5
	lw $t3, num_args
	bne $t2, $t3, invalidArgs
	
	#Now Process E command arguments
	#Fourth Argument stored in t4
	lw $t9, addr_arg4
	li $t8, 10
	li $t7, 65535
	
	lb $t0, 0($t9)
	lb $t1, 1($t9)
	lb $t2, 2($t9)
	lb $t3, 3($t9)
	lb $t4, 4($t9)
	
	addi $t0, $t0, -48
	addi $t1, $t1, -48
	addi $t2, $t2, -48
	addi $t3, $t3, -48
	addi $t4, $t4, -48
	
	mul $t0, $t0, $t8 
	mul $t0, $t0, $t8 
	mul $t0, $t0, $t8 
	mul $t0, $t0, $t8 
	
	mul $t1, $t1, $t8 
	mul $t1, $t1, $t8 
	mul $t1, $t1, $t8 
	
	mul $t2, $t2, $t8 
	mul $t2, $t2, $t8 
	
	mul $t3, $t3, $t8 
	
	add $t4, $t4, $t0
	add $t4, $t4, $t1
	add $t4, $t4, $t2
	add $t4, $t4, $t3
	
	bgt $t4, $t7, invalidArgs
	
	#For the 2nd and 3rd arguments
	li $t7, 31	
	
	#Third Argument, stored in t3
	lw $t9, addr_arg3
	
	lb $t0, 0($t9)
	lb $t1, 1($t9)
	
	addi $t0, $t0, -48
	addi $t1, $t1, -48
	
	mul $t0, $t0, $t8  
	add $t3, $t1, $t0
	bgt $t3, $t7, invalidArgs
	
	#Second Argument, stored in t2
	lw $t9, addr_arg2
	
	lb $t0, 0($t9)
	lb $t1, 1($t9)
	
	addi $t0, $t0, -48
	addi $t1, $t1, -48
	
	mul $t0, $t0, $t8  
	add $t2, $t1, $t0
	bgt $t2, $t7, invalidArgs
	
	#First Argument, stored in t1
	li $t7, 63
	lw $t9, addr_arg1
	lb $t0, 0($t9)
	lb $t1, 1($t9)
	
	addi $t0, $t0, -48
	addi $t1, $t1, -48
	
	mul $t0, $t0, $t8  
	add $t1, $t1, $t0
	bgt $t1, $t7, invalidArgs
	
	#At this point, it means all arguments were valid
	sll $t1, $t1, 26
	
	sll $t2, $t2, 27
	srl $t2, $t2, 6
	
	sll $t3, $t3, 27
	srl $t3, $t3, 11
	
	#t5 contains final value
	or $t5, $t1, $t2
	or $t5, $t5, $t3
	or $t5, $t5, $t4
	
	li $v0, 34
	move $a0, $t5
	syscall
	
	j exit	
	
checkPargs:
	#Haram part
	#t2-t3 I can use to check if num args is 2 or not
	li $t2, 2
	lw $t3, num_args
	bne $t2, $t3, invalidArgs
	
	#Can use all t registers at this point
	lw $t0, addr_arg1 #Load argument
	la $t9, hand #Load array
	la $t8, hand #Array Copy (I am not sure so just to be safe I use this in case losing reference = object lost and changes to array aren't preserved or smth like that)
	
	li $t5, 0 #Array Index
	li $t6, 5 #Upper bound on array index, exclusive
	strToArray:
		beq $t6, $t5, sortArray #If index = 5, then sort array 
		lb $t1, 0($t0) #Load Character into t1 at current idx for string
		lb $t7, 0($t8) #Load Character into t7 at current idx for array
		
		#I am thinking of converting right here to just rank values 1-D / 1-14 since the cards are unique 
		# so care only about ranks
		
		li $t2, 0x3d
		ble $t1, $t2, clubs
		
		li $t2, 0x4d
		ble $t1, $t2, spades
		
		li $t2, 0x5d
		ble $t1, $t2, diamonds	
		
		#By default if its not the other 3, then it has to be hearts
		j hearts
		
		store:	
			sb $t1, 0($t8) #Store t1 into t8 where t1 should be 1-14 for the ranks
			addi $t0, $t0, 1 #Update String pointer index to next char
			addi $t8, $t8, 1 #Update Array pointer index to next char
			addi $t5, $t5, 1 #Incremend Array Index
			j strToArray
	
	clubs:
		addi $t1, $t1, -48
		j store
		
	spades:
		addi $t1, $t1, -64
		j store
		
	diamonds:
		addi $t1, $t1, -80
		j store
		
	hearts:
		addi $t1, $t1, -96
		j store
	
	sortArray: 
		#Copied and modified from course materials - Selection Sort		
		la $t9, hand	# t9: base address of array
    		li $t0, 0 		# t0: i = 0
    		li $t2, 4		# t2: array length - 1
    		sort:
		beq $t0, $t2, stopSort  # i >= last index
		add $t7, $t9, $t0  # address of array[minIdx] = address of array[i]
		addi $t1, $t0, 1 # j = i + 1
		li $t2, 5   # array length
		
		minFinder:
			beq $t1, $t2, stopFinder  # j >= array length
			
			lb $t8, 0($t7)     # array[minIdx]
			add $t6, $t9, $t1  # address of array[j]
			lb $t4, 0($t6)     # array[j]
			bge $t4, $t8, noMin  # array[j] >= array[minIdx]
			
			move $t7, $t6   #min Index addresss = addr array[j]
			lb $t8, 0($t7)  # Update min value
			
		noMin:
			addi $t1, $t1, 1  #j++
			j minFinder
			
		stopFinder:
			li $t2, 4  #Adjust back array length - 1
			add $t5, $t9, $t0  # address of array[i]
			beq $t5, $t7, noSwap #Minimum was array[i]
			lb $t3, 0($t5) #array[i]
			sb $t3, 0($t7) #array[minIdx] = array[i]
			sb $t8, 0($t5) #array[i] = array[minIdx]
			
		noSwap:
			addi $t0, $t0, 1 #i++
			j sort
		
	stopSort:
    	#Array is sorted in hands now, can reuse registers again
    	move $t8, $t9
    	#t0 for first register (will act as value of previous registers
    	#t1 current register (to compare with previous register
    	#t2 will be number of comparisons done
    	#t3 will be 4 (max comparisons to do)
    	
    	lb $t0, 0($t8)
    	addi $t8, $t8, 1 #Increment 
    	li $t2, 0
    	li $t3, 4  
    	straightChecker:
    		beq $t2, $t3, isStraight
    		lb $t1, 0($t8)
    		addi $t0, $t0, 1
    		bne $t0, $t1, fourKind
    		addi $t8, $t8, 1
    		addi $t2, $t2, 1
    		j straightChecker
    	
    	 isStraight:
    	 	li $v0, 4
    	 	la $a0, straight_str
    	 	syscall
    	 	j exit
    		
    	fourKind: 
    		#If there is a 4 kind, then at most 2 distinct types of cards
    		#t0 - first distinct (store first card here)
    		#t1 - second distinct
    		#t2 - first distinct counter
    		#t3 - second distinct counter
    		#t4 - array[i] addr
    		#t5 - array[i]
    		#t6 - 4
    		#t7 - 0 (Kind 2 not found, will be 1 when K2 found)
    		#t8 - 4 (probably will not use)
    		#t9 - hand array
    		
    		lb $t0, 0($t9)
    		li $t1, 1
    		# t2 not set, will be set later
    		li $t3, 0
    		move $t4, $t9	#t4 will contain array address
    		addi $t4, $t4, 1	#Increment to point to 2nd element
    		li $t6, 4 		#How many comparisons need to be done
    		li $t8, 4		#4 of a kind counter 
    		li $t7, 0		#0 if kind 2 not found yet, 1 if kind 2 already found
    		
    		fourLooper:
    			beqz $t6, checkFour
    			lb $t5, 0($t4)
    			addi $t4, $t4, 1	#Update array address
    			addi $t6, $t6, -1 	#One less left to compare
    			beq $t5, $t0, kindOne
    			
    			beqz $t7, setK2
    			beq $t5, $t2, kindTwo
    			j notFour
    			
    		kindOne:
    			addi $t1, $t1, 1
    			j fourLooper
    			
    		kindTwo:
    			addi $t3, $t3, 1
    			j fourLooper

		setK2:
			li $t7, 1	#Kind 2 is set
			move $t2, $t5	#Set kind 2
			addi $t3, $t3, 1	#Increment Counter, should be 1
			j fourLooper
			
		checkFour: #If either have count 4, 		
			beq $t8, $t1, isFour
			beq $t8, $t3, isFour 
			j notFour
		
		isFour:
			li $v0, 4
			la $a0, four_str
			syscall
			j exit
		
	notFour:
	#Now check pair kind
	#t0 - kind one
	#t1 - Kind 1 counter
	#t2 - Kind two
	#t3 - Kind 2 counter
	#t4 - Kind three
	#t5 - Kind three counter
	#t6 - 0  (How many of remaining to compare yet)
	#t7 - 4 (How many left to compare to)
	#t8 - Array[i]
	#t9 - Array[i] addr
		
	lb $t0, 0($t9)
	li $t1, 1
	#t2, t4 won't be set yet
	li $t3, 0
	li $t5, 0
	li $t6, 0
	li $t7, 4
	addi $t9, $t9, 1 #Go to next index
	
	pairLooper:
		beq $t6, $t7, checkPair #Have processed the hand
		lb $t8, 0($t9)
		beq $t8, $t0, k1 #First kind
		
		beqz $t3, set2 #Set second kind
		beq $t8, $t2, k2 #Kind 2
		
		beqz $t5, set3 #Set third kind
		beq $t8, $t4, k3 #Kind 3
		j unknownHand
	
	k1:
		addi $t1, $t1, 1
		j increment
	
	k2:
		addi $t3, $t3, 1
		j increment
		
	k3:
		addi $t5, $t5, 1
		j increment
		
	increment:	
		addi $t9, $t9, 1
		addi $t6, $t6, 1
		j pairLooper
	
	set2:
		li $t3, 1
		move $t2, $t8
		j increment
		
	set3:
		li $t5, 1
		move $t4, $t8
		j increment
	
	checkPair: #Check t1, t3, t5 --> t1, t2, t3
		li $t0, 2 #Set t0 = 2, minimum for a pair
		move $t2, $t3
		move $t3, $t5
		
		bge $t1, $t0, check23
		blt $t2, $t0, unknownHand
		blt $t3, $t0, unknownHand
		j print2
		
	check23:
		bge $t2, $t0, print2
		bge $t3, $t0, print2
		j unknownHand
		
	print2:
		li $v0, 4
		la $a0, pair_str
		syscall
		j exit	
		
	
	#NEED TO FIX SELECTION SORT, IT SKIPS ONE ELEMENT
		
	#Need to figure out storing cards on array
	#Sort array (Take from provided materials)
	#Traverse array first time for straight, if not on traversal break branch otherwise after loop - output straight
		#One register for previous value, one for current value (if straight not kept, break out of the loop
	#Traverse array second time for 4 of a kind, (2 registers for distinct, 2 more for count) 
	#Traverse array third time for 2 pairs of 2 of a kind (3 registers for distinct, 3 more for count)
	#Unknown hand (Default)
	
	unknownHand:
		li $v0, 4
		la $a0, unknown_hand_str
		syscall
		j exit
	
invalidArgs:
	li $v0, 4
	la $a0, invalid_args_error
	syscall
	j exit
    		
invalidOp:
	li $v0, 4
	la $a0, invalid_operation_error
	syscall
	j exit
	
exit:
	li $v0, 10
	syscall
