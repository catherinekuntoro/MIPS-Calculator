.include "./cs47_proj_macro.asm"

.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	#Store
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	#prep for division and multiplication: check if either negative
	li $t0, 31
	extract_nth_bit($t1, $a0, $t0) # a0[31]
	extract_nth_bit($t2, $a1, $t0) # a1[31]
	
	# Going to the correct operation
	beq $a2, '+', logical_addition
	beq $a2, '-', logical_subtraction
	beq $a2, '*', logical_mul
			
logical_division:
	or $t1, $t1, $t2
	bne $t1, $zero, logical_div_signed # if t1 = 0, signed
	
	move $t1, $zero
	move $t0, $zero
	move $t2, $zero
	jal div_unsigned # else, if t1 = 1, unsigned
	
	j au_logical_end
	
logical_div_signed:
	move $t1, $zero
	move $t0, $zero
	move $t2, $zero
	
	jal div_signed
	j au_logical_end
	
			
logical_mul:
	or $t1, $t1, $t2
	bne $t1, $zero, logical_mul_signed # if t1 = 0, signed
	
	move $t1, $zero
	move $t0, $zero
	move $t2, $zero
	#otherwise, unsigned
	
	jal mul_unsigned
	j au_logical_end
	
logical_mul_signed:
	move $t1, $zero
	move $t0, $zero
	move $t2, $zero
	
	jal mul_signed
	j au_logical_end
			
logical_addition:
	move $t1, $zero
	move $t0, $zero
	move $t2, $zero
	
	move $a2, $zero
	jal add_sub_logical
	j au_logical_end

logical_subtraction:
	move $t1, $zero
	move $t0, $zero
	move $t2, $zero
	
	move $a2, $zero
	li $a2, 1
	jal add_sub_logical
	j au_logical_end	

au_logical_end:
	# Restore frame
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	
	
add_sub_logical:
	#ARGS:
	#$a0 = first number, $a1 = second number
	#a2 = 0x0 if addition, 0xFFF.... if subtract
	
	#$s0 , I = INDEX FROM 0
	#s1 = sum
	#s2 = "C" for carry out, and at first whether subtract/addi
	
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	

	move $v0, $zero
	move $v0, $zero
	
	move $s0, $zero # index i =0
	move $s1, $zero  # sum = 0
	extract_nth_bit($s2, $a2, $s0)
	bne $s2, $zero, subtraction #if s2 != 0, means subtraction
	
	move $t0, $zero # make sure temp var purely = 0
	move $t1, $zero
	
get_Y:	extract_nth_bit($t0, $a0, $s0) #take bit at index i, store #@t1
	extract_nth_bit($t1, $a1, $s0) #take bit from a1 at index i, store t1
	
	xor $s3, $t0, $t1  #S3 = A XOR B
	xor $s4, $s3, $s2 # Carry_in XOR (A XOR B)
				#sum; the y value
	
	#get carry bit below:
	and $t3, $t0, $t1 # t3 = A AND B
	and $t4, $s3, $s2 # S2 (carry in) AND s3 (A XOR B)
	or $s2, $t4, $t3 # carry bit = t4 OR t3 (A AND B)
	
	
	#move value Y (s4) to sum register (s1) at index I
	li $t5, 0x1 #for mask register
	insert_to_nth_bit($s1, $s0, $s4, $t5)
	
	addi $s0, $s0, 1
	
	#checking if index == 31, since start from 0->31
	li $t6, 32 #32? instruction said so
	beq $s0, $t6, add_sub_end
	j get_Y
subtraction:
	not $a1, $a1
	j get_Y
	
add_sub_end:
	move $v0, $s1 #sum
	move $v1, $s2 #carry out
	#frame restore	
	#FRAME RESTORE
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	

#########################################################

twos_complement:
	#args: a0 = to be 2's complemented, reutnr @v0
	##frame creation
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	#PASSING ARGUMENTS FOR ADD_SUB_LOGICAL
	not $a0, $a0 	#a0 = first number to be added
	li $a1, 1  	#a1 = second number to be add
	move $a2, $zero #a2 = indicate addition
	jal add_sub_logical
	
	#frame end
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	
	
 #########################################################
twos_complement_if_negative:
	
	#frame store
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	#args: $a0, return $v0
	 
	li $t1, 31 #extract 31th bit from 0 index
	move $v0, $zero #clear out any previous results
 	extract_nth_bit($t0, $a0, $t1)
 	
 	
 	beq $t0, $zero, twos_complement_positive
 	
 	#if NEGATIVE, as in t0 = 1, call two's comp
 	jal twos_complement
 	j twos_complement_if_negative_end
 	
 twos_complement_positive:
 	move $v0, $a0	
 	
 twos_complement_if_negative_end:
 	
 	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	
	
#########################################################

twos_complement_64_bits:
#a0, lo, a1 hi
#return v0 lo, v1 high
	#frame creation
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	
	#Save a1 to s0 first, because a1 is going to be used as argument
	#for add_sub_logical
	move $s0, $a1
	
	#CREATING ARGUMENTS TO BE PASSED TO ADD_SUB_LOGICAL
	not $a0, $a0 # First number to be added
	li $a1, 1    # Second number to be added
	move $a2, $zero # Indicator addition
	
	jal add_sub_logical
	move $s7, $v0 # s7 is the lo
	move $s1, $v1 # saving carry out 
	
	# CREATING NEXT ARGUMENTS TO BE PASSED TO ADD_SUB_LOGICAL
	
	#Now, make the original $a1 (saved in s0) as the $a0 
	#for add_sub_logical. Then, invert it
	not $s0, $s0
	move $a0, $s0
	
	#The v1 (final carry out bit) from previous add_sub_logical
	#will be inserted as a1
	
	move $a1, $s1 #pass the v1 from the prev add_sub_logical to a2
	
	move $a2, $zero # Indicator addition
	
	jal add_sub_logical
	
	move $v1, $v0
	move $v0, $s7
	
	#frame restore
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	
#########################################################

bit_replicator: #args: a0 either 0x0 or 0x1
#frame creation
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	li $s0, 0
	li $t1, 32
	move $s1, $zero
replicate: 
	li $t0, 1
	insert_to_nth_bit($v0, $s0, $a0, $t0)
	addi $s0, $s0, 1	
	bne $s0, $t1, replicate	
#frame restore 
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	
#########################################################
					
mul_unsigned: #a0 multiplicand, a1 multiplier
	#frame creation
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	move $s0, $zero #INDEX
	move $s1, $zero #H = HIGH
	move $s2, $a1 	#L = LOW <= MULTIPLIER
	move $s3, $a0 	#M = MULTIPLICAND

mul_unsigned_replicate:
	
	extract_nth_bit($a0, $s2, $zero) #a0 = L[0]
	jal bit_replicator
	move $s4, $v0
	
after_replicate:	
	#PASSING ARGUMENT TO ADD SUB LOGICAL
	and $a1, $s3, $s4 # X = M AND R
	move $a0, $s1 # Pass s1 (H) to argument
	move $a2, $zero # Addition
	
	jal add_sub_logical # H = H + X				
	
	#Move result to s1
	move $s1, $v0 #S1 = H
	#########################################################
	
	#add $s1, $a1, $a0 # IN THE MEANTIME 
	
	srl $s2, $s2, 1 #L >> 1
	
	extract_nth_bit($t0, $s1, $zero) # t0 = H[0]
	li $t1, 31 
	li $t2, 1 #mask
	insert_to_nth_bit($s2, $t1, $t0, $t2) #L[31] = H[0]
	
	srl $s1, $s1, 1 #H >> 1
	
	addi $s0, $s0, 1 # index i ++
	li $t1, 32
	bne $s0, $t1, mul_unsigned_replicate
	
	move $v0, $s2
	move $v1, $s1
	
	#Frame restore
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra																			
																																																										
#########################################################
						
mul_signed: # a0 multiplicand, a1 multiplier

#frame creation
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	move $s6, $a0 # original a0 = LO
	move $s7, $a1 # original a1 = HI
	
	jal twos_complement_if_negative # Calculate 2's comp of a0 if needed
	move $s0, $v0 	# s0 = N1
	
	move $a0, $a1
	jal twos_complement_if_negative
	move $s1, $v0 # s1 = N2
	
	move $a0, $s0
	move $a1, $s1
	jal mul_unsigned 
	
	move $s2, $v0 # Rlo = LO
	move $s3, $v1 # Rhi = HIGH
	
	################## FINDING S FOR SIGN ############
	move $t0, $zero
	li $t0, 31
	move $t1, $zero
	extract_nth_bit($t1, $s6, $t0) # t1 = a0[31] ORIGINAL A0
	
	li $t0, 31
	move $t2, $zero # ensure t2 clean
	extract_nth_bit($t2, $s7, $t0) # t2 = a1[31]
	
	
	xor $s5, $t1, $t2 # S = SIGN = s5
	
	########### Now see if answers ned 2's comp ################
	beq $s5, $zero, mul_signed_positive
	
	move $a0, $s2
	move $a1, $s3
	jal twos_complement_64_bits
	
	j mul_signed_end

mul_signed_positive:
	move $v0, $s2
	move $v1, $s3	
	
mul_signed_end:	
	
	#FRAME RESTORE
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	

																																																																																																																																																																																																																												
#########################################################
div_unsigned:
	#a0 dividend a1 divisor

	#frame creation
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52

	
	move $s0, $zero # INDEX
	move $s1, $a0	# Q = DIVIDEND
	move $s2, $a1	# D = DIVISOR
	move $s3, $zero # R = REMAINDER
	
div_unsigned_loop:
	sll $s3, $s3, 1 # Left shift R (remainder) by 1
	
	li $t0, 31
	extract_nth_bit($t1, $s1, $t0) # s1[31]	
	li $t2, 1
	insert_to_nth_bit($s3, $zero, $t1, $t2) # R[0] = s1[31]
	
	sll $s1, $s1, 1 # Shift left Q (Quotient)
	
	li $a2, 1
	move $a0, $s3
	move $a1, $s2
	jal add_sub_logical 
	move $t1, $v0 # S = t1
	
	blt $t1, $zero, increment_div_unsigned #If t1 (S) < 0, increment
	
	move $s3, $t1 # R = S = t1
	li $t0, 1
	li $t1, 1
	insert_to_nth_bit($s1, $zero, $t0, $t1) # Q[0] = 1
	
increment_div_unsigned:	
	addi $s0, $s0, 1
	li $t0, 32
	blt $s0, $t0, div_unsigned_loop
	
			
div_unsigned_frame_restore:
	move $v0, $s1 # Quotient
	move $v1, $s3 # Remainder
	
	#FRAME RESTORE
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	
		
#########################################################

div_signed:
	#frame creation
	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 52
	
	move $s6, $a0 # original a0
	move $s7, $a1 # original a1
	
	jal twos_complement_if_negative # Calculate 2's comp of a0 if needed
	move $s0, $v0 	# s0 = N1
	
	move $a0, $a1
	jal twos_complement_if_negative
	move $s1, $v0 # s1 = N2
	
	move $a0, $s0
	move $a1, $s1
	jal div_unsigned 
	
	move $s2, $v0 # Q = QUOTIENT
	move $s3, $v1 # R = REMAINDER

	
	################## FINDING S FOR SIGN ############
	li $t0, 31
	extract_nth_bit($s4, $s6, $t0) # s4 = a0[31] ORIGINAL A0
	
	li $t0, 31
	move $t2, $zero # ensure t2 clean
	extract_nth_bit($t2, $s7, $t0) # t2 = a1[31]
	
	
	xor $s5, $s4, $t2 # S = SIGN = s5
	
	########### Now finding sign quotient ################
	beq $s5, $zero, S_of_remainder
	
	#If S = 1
	move $a0, $s2
	
	
	jal twos_complement
	
	
	move $s2, $v0 # final quotient
	
S_of_remainder:
	li $t0, 31
	extract_nth_bit($s4, $s6, $t0) # s4 = a0[31] ORIGINAL A0
	
	move $s5, $s4 #s5 is variable for S. s4 is a0[31]
	beq $s5, $zero, assign_output_if_S_zero
	
	
	move $a0, $s3 # Calculate two's complement of s3 (remainder)
	jal twos_complement
	
	move $v1, $v0 # The result of above 2's comp is remainder
	move $v0, $s2 # quotient calculated before
	
	j div_signed_end

assign_output_if_S_zero:
	
	move $v0, $s2
	move $v1, $s3
	
div_signed_end:	
	
	#FRAME RESTORE
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	jr $ra	
									
#########################################################

