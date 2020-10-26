# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

#ASSUMPTION: INDEX FROM 0 UNTIL 31

.macro insert_to_nth_bit($regBitSource, $regPosition, $regValue, $maskReg)
	
	#regPosition must be from 0 until 31
	
	# $maskReg passed in must be 0x1
	sllv $maskReg, $maskReg, $regPosition 
	
	#Invert the maskReg
	not $maskReg, $maskReg
	
	#AND operation maskReg and $regBitSource
	and $regBitSource, $regBitSource, $maskReg
	
	#Making the 'b' pattern for the final OR operation
	move $t0, $regValue #Depending on regValue b can start with 0x0 or 0x1
	sllv $t0, $t0, $regPosition #shift left by reg Position
	
	#OR operation
	or $regBitSource, $regBitSource, $t0
	
.end_macro

.macro extract_nth_bit ($regDestination, $regSource, $regPosition)
	
	#push right (
	srlv $regDestination, $regSource, $regPosition #impurities in front
	
	sll $regDestination, $regDestination, 31 #slam to the MSB 
	srl $regDestination, $regDestination, 31 #slam back to LSB
.end_macro	



