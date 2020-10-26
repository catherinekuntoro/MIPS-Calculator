.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
	#Store
	addi $sp, $sp, -24
	sw $fp, 24($sp)
	sw $ra, 20($sp)
	sw $a0, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	addi $fp, $sp, 24
	
	#if a2 is addition
	beq $a2, '+', normal_addition
	beq $a2, '-', normal_subtraction
	beq $a2, '*', normal_mul
	
	#Otherwise, division
	div $v0, $a0, $a1
	mfhi $v1	
	j normal_end
	
normal_addition:
	addu $v0, $a0, $a1 # using add doesnt add +1 to the inverted bits?
	j normal_end
	
normal_subtraction:
	subu $v0, $a0, $a1
	j normal_end
	
normal_mul:
	mul $v0, $a0, $a1
	mfhi $v1
	j normal_end			
normal_end:	
# Restore frame
	lw $fp, 24($sp)
	lw $ra, 20($sp)
	lw $a0, 16($sp)
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	addi $sp, $sp, 24
	jr	$ra
