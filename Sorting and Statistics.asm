# Ihfaz Tajwar
# Sorts an array of integers and calculates mean, median and standard deviation

	.data
buffer:	.space 80	#Stores input from file
fName:	.asciiz "input.txt"	#Filename
err:	.asciiz "Error while accessing file!"
space:	.byte ' '
meanVal:.float 0.0	#Stores mean
stDev:	.float 0.0	#Stores standard deviation
array:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	#Arrays stores file input as int array
m1:	.asciiz "The array before:  "
m2:	.asciiz "\nThe array after:   "
m3:	.asciiz "\nThe mean is: "
m4:	.asciiz "\nThe median is: "
m5:	.asciiz "\nThe standard deviation is: "

	.text
main:	li $v0,13
	la $a0,fName	#Load filename
	li $a1,0	#Read mode
	li $a2,0
	syscall		#Open file
	
	move $a0,$v0
	la $a1,buffer
	li $a2,80
	jal fileRead	#Call fileRead procedure
	
	li $v0,16	#Close file
	syscall
	
	bgtz $v0,ok	#Checks for file error
	la $a0,err
	li $v0,4
	syscall
	j exit		#End program if error occurs
	
ok:	la $a0,array
	li $a1,20
	la $a2,buffer
	jal extractInt		#Call extractInt procedure
	
	la $a0,m1
	li $v0,4
	syscall
	jal printArray		#Call printArray procedure
	
	la $a0,array
	li $a1,20
	jal selectionSort	#Call selectionSort procedure
	
	la $a0,m2
	li $v0,4
	syscall
	jal printArray		#Call printArray procedure
	
	la $a0,array
	li $a1,20
	jal mean		#Call mean procedure
	
	la $a0,m3
	li $v0,4
	syscall
	l.s $f12,meanVal	#Display mean
	li $v0,2
	syscall
	
	la $a0,m4
	li $v0,4
	syscall
	
	la $a0,array
	li $a1,20
	jal median		#Call median procedure
	bnez $v1,flt		#If $v1 = 0 then int, else float
	move $a0,$v0
	li $v0,1		#Display median as int
	syscall
	j sdev
flt:	li $v0,2		#Display median as float
	syscall
	
sdev:	la $a0,array
	li $a1,20
	jal standardDeviation	#Call standardDeviation procedure
	s.s $f12,stDev
	
	la $a0,m5
	li $v0,4
	syscall
	li $v0,2		#Display standard deviation
	syscall
	
exit:	li $v0,10		#End of program
	syscall
	
	
#########################################################	
#######             PROCEDURES                     ######
#########################################################

#Procedure for reading the contents of the file
fileRead:
	li $v0,14		#Read file onto buffer
	syscall
	jr $ra

#Procedure for converting string read from file to an int array
extractInt:
	li $t6,48
	li $t7,57
	li $t5,10			
	li $s0,13			#CR
	li $t2,0			# $t2 = Accumulator
e1:	lb $t0,($a2)			# $t0 = Current char
	addi $a2,$a2,1
	lb $t1,($a2)			# $t1 = Next char
	blt $t0,$t6,extractInt
	bgt $t0,$t7,extractInt
	addi $t0,$t0,-48
	add $t2,$t2,$t0	
	beq $t1,$s0,insert		#Checks if next char is CR
	beqz $t1,insert			#Checks if next char is EOF		
	mul $t2,$t2,$t5
	j e1
insert:	sw $t2,($a0)
	addi $a0,$a0,4
	addi $a1,$a1,-1
	bnez $a1,extractInt
	jr $ra	
	
#Procedure for sorting the array using selection sort
selectionSort:
	li $t0,0			# ($t0)i = 0
	addi $t7,$a1,-1			# $t7 = 19
lp1:	bgt $t0,$t7,ret1		# Loop until i > n-1
	sll $t1,$t0,2			# i*4
	add $t1,$a0,$t1			# $t1 = base address + i*4 (indexI)
	
	move $t6,$t1			# $t6 = Min index
	
	addi $t2,$t0,1			# ($t2)j = i+1
lp2:	bgt $t2,$a1,swap		# Loop until j > n
	sll $t3,$t2,2			# j*4
	add $t3,$t3,$a0			# $t3 = base address + j*4 (indexJ)
	
	lw $s0,($t3)			# $s0 = arr[j]
	lw $s1,($t6)			# $s1 = arr[min_index]
	
	bge $s0,$s1,nxt			# if arr[j] < arr[min_index] then min_index = j
	move $t6,$t3			
	
nxt:	addi $t2,$t2,1			# j++
	j lp2
swap:	lw $s2,($t1)			# $s2 = arr[i]
	
	move $s3,$t6			# Swapping i with min_index
	move $t6,$t1
	move $t1,$s3
	
	sw $s1,($t6)			#Store the values onto the array
	sw $s2,($t1)
	
	addi $t0,$t0,1			# i++
	j lp1
ret1:	jr $ra	
	
#Procedure for printing the int array with spaces in between
printArray:
	la $t0,array
	li $t1,20
pa1:	lw $a0,($t0)	#Load ints one by one
	li $v0,1
	syscall
	addi $t0,$t0,4	#Next int
	addi $t1,$t1,-1
	beqz $t1,ret2
	
	la $a0,space
	lb $a0,($a0)
	li $v0,11
	syscall
	
	j pa1
ret2:	jr $ra

#Procedure for calculating the mean
mean:
	li $t1,0		#Accumulator
	move $t2,$a1
mn:	beqz $t2,ret3		#Loops until $t2=0
	lw $t0,($a0)		#Load current element
	add $t1,$t1,$t0		#Adds each element and accumulates
	addi $a0,$a0,4
	addi $t2,$t2,-1
	j mn
ret3:	mtc1 $t1,$f0
	cvt.s.w $f0,$f0
	mtc1 $a1,$f1
	cvt.s.w $f1,$f1
	div.s $f2,$f0,$f1	#Calculate mean
	s.s $f2,meanVal
	jr $ra

#Procedure for calculating the median
median:
	li $t0,2
	div $a1,$t0
	mfhi $t7		# $t7 = remainder
	mflo $t1		# $t1 = quotient
	sll $t1,$t1,2
	beqz $t7,even		#If remainder is 0 then even
	add $t1,$t1,$a0		#Base address + offset
	lw $v0,($t1)		#Load median onto $f12
	j ret4
even:	li $v1,1		#Set flag to 1		
	add $t2,$t1,$a0		#Loading the two middle values
	l.s $f0,($t2)
	addi $t2,$t1,-4
	add $t2,$t2,$a0
	l.s $f1,($t2)

	mtc1 $t0,$f2
	
	cvt.s.w $f0,$f0		#Convert values from word to float
	cvt.s.w $f1,$f1
	cvt.s.w $f2,$f2
	add.s $f12,$f0,$f1
	div.s $f12,$f12,$f2	#Calculate average of middle values
ret4:	jr $ra

#Procedure for calculating the standard deviation
standardDeviation:
	li $t0,0		# i = 0
	move $t3,$a1
	addi $t4,$a1,-1		# n - 1		
	mtc1 $zero,$f30		#Accumulator
std:	beqz $t3,ret5
	sll $t2,$t0,2		# i*4
	add $t1,$a0,$t2		# index = base address + i*4
	l.s $f0,($t1)		# Ri
	cvt.s.w $f0,$f0
	l.s $f31,meanVal
	sub.s $f1,$f0,$f31	# $f1 = Ri - Ravg
	mul.s $f1,$f1,$f1	# $f1 = (Ri - Ravg)^2
	add.s $f30,$f30,$f1	# $f30 = Summation (Ri - Ravg)^2
	addi $t3,$t3,-1
	addi $t0,$t0,1		# i++
	j std
ret5:	mtc1 $t4,$f2		# $f2 = n - 1
	cvt.s.w $f2,$f2
	div.s $f3,$f30,$f2	# Summation (Ri - Ravg)^2 / n-1
	sqrt.s $f12,$f3		# Calculating SD
	jr $ra
