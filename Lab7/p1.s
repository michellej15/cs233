.text

# // part 1 p1.s
# unsigned char find_payment(TreeNode* trav) {
# 	// Base case
# 	if (trav == NULL) {
# 		return 0;
# 	}
# 	// Recurse once for each child
# 	unsigned char payment_left = find_payment(trav->left);
# 	unsigned char payment_center = find_payment(trav->center);
# 	unsigned char payment_right = find_payment(trav->right);
# 	unsigned char value = payment_left + payment_center + payment_right + trav->value;
# 	return value / 2;
# }

.globl find_payment
find_payment:
	bne $a0, $zero, recurse
	move $v0, $zero
	jr $ra
recurse:
	sub $sp, $sp, 36
	sw $ra, 0($sp) #return address
	sw $s0, 4($sp) #pointer trav->left
	sw $s1, 8($sp) #pointer trav->center
	sw $s2, 12($sp) #pointer trav->right
	sw $s3, 16($sp) #trav->value
	sw $s4, 20($sp) #find_payment(trav->left)
	sw $s5, 24($sp) #find_payment(trav->center)
	sw $s6, 28($sp) #find_payment(trav->right)
	sw $s7, 32($sp) #register to load

	move $s7, $a0
	lw $s0, 0($a0) #load pointer
	move $a0, $s0 #store address trav->left
	jal find_payment #find_payment(trav->left)
	move $s4, $v0 #save find_payment(trav->left)
	lw $s1, 4($s7) #load pointer
	move $s0, $s1 #store address trav->center
	jal find_payment #find_payment(trav->center)
	move $s5, $v0 #save find_payment(trav->center)
	lw $s2, 8($s7) #load pointer
	move $s0, $s2 #store address trav->value
	jal find_payment #find_payment(trav->center)
	move $s6, $v0 #save find_payment(trav->center)
	lbu $s3, 12($s7) #get address for value
	add $s3, $s3, $s4 #add value + find_payment(trav->left)
	add $s3, $s3, $s5 #add value + find_payment(trav->left) + find_payment(trav->center)
	add $s3, $s3, $s6 #add value +find_payment(trav->left) + find_payment(trav->center) + find_payment(trav->right)
	srl $v0, $s3, 1 #load

	lw $s0, 4($sp) #pointer trav->left
	lw $s1, 8($sp) #pointer trav->center
	lw $s2, 12($sp) #pointer trav->right
	lw $s3, 16($sp) #trav->value
	lw $s4, 20($sp) #find_payment(trav->left)
	lw $s5, 24($sp) #find_payment(trav->center)
	lw $s6, 28($sp) #find_payment(trav->right)
	lw $s7, 32($sp)
	lw $ra, 8($sp)
	add $sp, $sp, 36
	jr $ra
