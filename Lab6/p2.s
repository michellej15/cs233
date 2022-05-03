.text

# void matrix_mult(int *matr_a, int *matr_b, int *output, unsigned int width) {
#     for (int i = 0; i < width; i++) {
#         for (int j = 0; j < width; j++) {
#             output[i*width + j] = 0;
#             for (int k = 0; k < width; k++) {
#                 output[i*width + j] += matr_a[i*width + k] * matr_b[k*width + j];
#             }
#         }
#     }
# }
#
# // a0: int *matr_a
# // a1: int *matr_b
# // a2: int *output
# // a3: unsigned int width

.globl matrix_mult
matrix_mult:
	li $t0, 0 #i=0
	li $t4, 4
first_for_loop:
	bge $t0, $a3, end #if i < width
	li $t1, 0 #j=0
	j second_for_loop
second_for_loop_end:
	addi $t0, $t0, i #i++
	j first_for_loop
second_for_loop:
	bge $t1, $a3, second_for_loop_end
	mul $t3, $t0, $a3 #i*width
	add $t3, $t3, $t1 #i*width+j
	mul $t3, $t3, $t4
	add $t3, $t3, $a2
	sw $0, 0($t3) #thing inside loop
	li $t2, 0 #k=0
	j third_for_loop
third_for_loop_end:
	addi $t1, $t1, 1
	j second_for_loop
third_for_loop_end:
	bge $t2, $a3, third_for_loop_end
	mul $t5, $t0, $a3 #i*width
	add $t5, $t5, $t2 #i*width+k
	mul $t5, $t5, $t4
	add $t5, $t5, $a0 #k*width+j
	lw $t5, 0($t5) #matr_b[k*width + j]
	mul $t6, $t2, $a3 #k*width

	add $t6, $t6, $t1 #k*width+j
	mul $t6, $t6, $t4
	add $t6, $t6, $a1
	lw $t6, 0($t6) #matr_b[k*width + j]
	mul $t7, $t6, $t5

	lw $v0, 0($t3)
	add $t7, $t7, $v0 #output = all the stuff in that equation
	sw $t7, 0($t3)
	addi $t2, $t2, 1 #k++
	j third_for_loop
end:
	jr $ra
# #define MAX_WIDTH 100
# int working_matrix[MAX_WIDTH*MAX_WIDTH];

# void markov_chain(int *state, int *transitions, unsigned int width, int times) {
#     for (int i = 0; i < times; i++) {
#         matrix_mult(state, transitions, working_matrix, width);
#         copy(state, working_matrix);
#     }
# }
#
# // a0: int *state
# // a1: int *transitions
# // a2: unsigned int width
# // a3: int times

.globl markov_chain
markov_chain:
	# Can access working_matrix from p2_main.s
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	la $s4, working_matrix
	li $s5, 0 #i=0

for_loop:
	bge $s5, $s3, return
	move $a0, $s0
	move $a1, $s1
	move $a2, $s4
	move $a3, $s2
	jal matrix_mult
	move $a0, $s0
	move $a1, $s4
	move $a3, $s2
	jal copy
	addi $s5, $s5, 1
	j for_loop

return:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	add $sp, $sp, 28

jr	$ra
