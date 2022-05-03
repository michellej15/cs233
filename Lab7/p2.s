.text

# void toggle_light(int row, int col, LightsOut* puzzle, int action_num){
#     int num_rows = puzzle->num_rows;
#     int num_cols = puzzle->num_cols;
#     int num_colors = puzzle->num_colors;
#     unsigned char* board = (puzzle-> board);
#     board[row*num_cols + col] = (board[row*num_cols + col] + action_num) % num_colors;
#     if (row > 0){
#         board[(row-1)*num_cols + col] = (board[(row-1)*num_cols + col] + action_num) % num_colors;
#     }
#     if (col > 0){
#         board[(row)*num_cols + col-1] = (board[(row)*num_cols + col-1] + action_num) % num_colors;
#     }
#
#     if (row < num_rows - 1){
#         board[(row+1)*num_cols + col] = (board[(row+1)*num_cols + col] + action_num) % num_colors;
#     }
#
#     if (col < num_cols - 1){
#         board[(row)*num_cols + col+1] = (board[(row)*num_cols + col+1] + action_num) % num_colors;
#     }
# }
# $a0 row
# $a1 col
# $a2 puzzle
# $a3 action_num

.globl toggle_light
toggle_light:
	lw $t0, 0($a0)       #int num_rows = puzzle->num_rows;
	lw $t1, 4($a0)       #int num_cols = puzzle->num_cols;
	lw $t2, 8($a0)       #int num_colors = puzzle->num_colors;
	addi $t3, $a2, 12    #Store address of board(puzzle->board)
	mul $t4, $a0, $t1    #rows * num_cols
	add $t4, $t4, $a1    #rows * num_cols + col
	add $t4, $t4, $t3    #get address of board[row*num_cols + col]
	lbu $t5, 0($t4)      #Get board[row*num_cols + col]
	add $t5, $t5, $a3    #board[row*num_cols + col] + action_num
	rem $t5, $t5, $t2    #board[(row-1)*num_cols + col]+ action_num % num_colors
	sb $t5, 0($t4)       #store board[(row-1)*num_cols + col]+ action_num % num_colors in board[row*num_cols + col]

# board[(row-1)*num_cols + col] = (board[(row-1)*num_cols + col] + action_num) % num_colors;
first_if:
	ble $a0, $zero, second_if
	sub $t6, $a0, 1      #row-1
	mul $t6, $t6, $t1    #(row-1)*num_cols
	add $t6, $t6, $a1    #(row-1)*num_cols+col
	add $t6, $t6, $t3    #get address of board[(row-1)*num_cols + col]
	lbu $t7, 0($t6)      #get board[(row-1)*num_cols + col]
	add $t7, $t7, $a3    #board[(row-1)*num_cols + col] + action_num
	rem $t7, $t7, $t2    #(board[(row-1)*num_cols + col] + action_num) % num_colors
	sb  $t7, 0($t6)      #store (board[(row-1)*num_cols + col] + action_num) % num_colors in board[(row-1)*num_cols + col]

# board[(row)*num_cols + col-1] = (board[(row)*num_cols + col-1] + action_num) % num_colors;
second_if:
	ble $a1, $zero, third_if
	mul $t6, $t6, $t1    #(row)*num_cols
	add $t6, $t6, $a1    #(row)*num_cols+col
	sub $t6, $t6, $a1    #row*num_cols + col - 1
	add $t6, $t6, $t3    #get address of board[(row)*num_cols + col - 1]
	lbu $t7, 0($t6)      #get board[(row)*num_cols + col - 1] + action_num
	add $t7, $t7, $a3    #board[(row)*num_cols + col - 1] + action_num
	rem $t7, $t7, $t2    #(board[(row)*num_cols + col - 1] + action_num) % num_colors
	sb  $t7, 0($t6)      #store (board[(row)*num_cols + col - 1] + action_num) % num_colors in board[(row)*num_cols + col - 1]

# board[(row+1)*num_cols + col] = (board[(row+1)*num_cols + col] + action_num) % num_colors;
third_if:
	sub $t8, $t0, 1      #num_rows - 1
	bge $a0, $t8, fourth_if
	add $t6, $a0, 1      #row + 1
	mul $t6, $t6, $t1    #(row + 1)*num_cols
	add $t6, $t6, $a1    #(row+1)*num_cols+col
	add $t6, $t6, $t3    #get address of board[(row + 1)*num_cols + col]
	lbu $t7, 0($t6)      #get board[(row + 1)*num_cols + col] + action_num
	add $t7, $t7, $a3    #board[(row + 1)*num_cols + col] + action_num
	rem $t7, $t7, $t2    #(board[(row + 1)*num_cols + col] + action_num) % num_colors
	sb  $t7, 0($t6)      #store (board[(row+1)*num_cols + col] + action_num) % num_colors in board[(row+1)*num_cols + col]

# board[(row)*num_cols + col+1] = (board[(row)*num_cols + col+1] + action_num) % num_colors;
fourth_if:
	sub $t9, $t1, 1      #num_cols - 1
	bge $a1, $t9, return
	mul $t6, $a0, $t1    #row * num_cols
	add $t6, $t6, $a1    #row * num_cols + col
	add $t7, $t6, 1      #row * num_cols + col + 1
	add $t6, $t6, $t3    #get address of board[(row)*num_cols + col + 1]
	lbu $t7, 0($t6)      #get board[(row)*num_cols + col + 1] + action_num
	add $t7, $t7, $a3    #board[(row)*num_cols + col+1] + action_num
	rem $t7, $t7, $t2    #board[(row)*num_cols + col+1] + action_num % num_colors
	sb $t7, 0($t6)       #store (board[(row)*num_cols + col +] + action_num) % num_colors in board[(row)*num_cols + col + 1]

return:
	jr	$ra



# bool solve(LightsOut* puzzle, unsigned char* solution, int row, int col){
#     int num_rows = puzzle->num_rows;
#     int num_cols = puzzle->num_cols;
#     int num_colors = puzzle->num_colors;
#     int next_row = ((col == num_cols-1) ? row + 1 : row);
#     if (row >= num_rows || col >= num_cols) {
#          return board_done(num_rows,num_cols,puzzle->board);
#     }
#			if(puzzle->clue[row*num_cols + col]) {
#					(puzzle,solution, next_row, (col + 1) % num_cols);
#			}
#     for(char actions = 0; actions < num_colors; actions++) {
#         solution[row*num_cols + col] = actions;
#         toggle_light(row, col, puzzle, actions);
#         if (solve(puzzle,solution, next_row, (col + 1) % num_cols)) {
#             return true;
#         }
#         toggle_light(row, col, puzzle, num_colors - actions);
#         solution[row*num_cols + col] = 0;
#     }
#     return false;
# }
# $a0 puzzle
# $a1 solution
# $a2 row
# $a3 col

.globl solve
solve:
	sub $sp, $sp, 36     #alloc stack
	sw $ra, 0($sp)       #return address
	sw $s0, 4($sp)       #num_cols
	sw $s1, 8($sp)       #num_colors
	sw $s2, 12($sp)      #next_row
	sw $s3, 16($sp)      #puzzle
	sw $s4, 20($sp)      #solution
	sw $s5, 24($sp)      #row
	sw $s6, 28($sp)      #col
	sw $s7, 32($sp)      #num_rows

	lw $s0, 4($a0)       #int num_cols
	lw $s1, 8($a0)       #int num_color

	move $s3, $a0        #store puzzle
	move $s4, $a1        #store solution
	move $s5, $a2        #store row
	move $s6, $a3        #store col

next_row_if:
	sub $t0, $s1, 1             #store num_cols-1
	bne $s6, $t0, next_row_if
	add $s2, $s5, 1             #next_row = row + 1
	j first_if

next_row_else:
	move $s2, $s5               #next_row = row
	j first_if

first_if:
	lw $s7, 0($s3)              #load num_rows
	blt $s5, $s7, alt_if        #if(row < num_rows): jump to alt_if
	move $a0, $s7               #$a0 = num_rows
	move $a1, $s0               #$a1 = num_cols
	add $a2, $s3, 12            #get address for puzzle->board
	jal solver_board_done
	j complete

alt_if:
	blt $s6, $s0, second_if
	move $a0, $s7               #$a0 = num_rows
	move $a1, $s0               #$a1 = num_cols
	add $a2, $s3, 12            #get address for (puzzle->board)
	jal solver_board_done
	j complete

# if(puzzle->clue[row*num_cols + col]) {
#		(puzzle,solution, next_row, (col + 1) % num_cols);
second_if:
	add $t1, $zero, 16          #store max_gridsize
	mul $t1, $t1, $t1           #store max_gridsize * max_gridsize
	add $s7, $s3, 12            #get base address for board
	add $s7, $t1, $s7           #get base address for clue
	mul $t0, $s5, $s0           #row*num_cols
	addu $t0, $t0, $s6          #row*num_cols + col
	add $s7, $s7, $t0           #get address for puzzle->clue[rows*num_cols + col]
	lbu $t5, 0($t5)             #get char(boolean)
	beq $t2, $zero, begin_for_loop
	move $a0, $s3               #store puzzle into $a0
	move $a1, $s4               #store solution into $a2
	move $a2, $s2               #sotre next_row
	addu $a3, $s6, 1            #col + 1
	rem $a3, $a3, $s0           #store (col +1) % num_cols
	jal solve
	j complete

begin_for_loop:
	li $s7, 0                   #actions = 0
	j for_loop

for_loop:
	bge $s7, $s1, false_return  #if(actions >= num_colors): jump to return
	mul $t0, $s5, $s0           #row*num_cols
	addu $t0, $t0, $s6          #row*num_cols + 1
	addu $t0, $t0, $s4          #get address if solution[(row+1)*num_rows+col]
	sb $s7, 0($t0)              #store actions in solution[row*num_cols + col]
	move $a0, $s5               #store row
	move $a1, $s6               #store col
	move $a2, $s3               #store puzzle
	move $a3, $s7               #store actions
	jal toggle_light
	j third_if

third_if:
	move $a0, $s3               #store puzzle
	move $a1, $s4               #store solution
	move $a2, $s2               #store next_row
	add $a3, $a3, 1             #store col + 1
	rem $a3, $a3, $s0           #store (col+1)%num_cols
	jal solve
	beq $v0, $zero, cont_loop
	j complete

cont_loop:
	move $a0, $s5               #store row
	move $a1, $s6               #store col
	move $a2, $s3               #store puzzle
	sub $a3, $s1, $s7           #store num_colors - actions
	jal toggle_light
	mul $t0, $s5, $s0           #rows * num_cols
	add $t0, $t0, $s6           #rows * num_cols + col
	add $t0, $t0, $s4           #get address of solution[rows * num_cols + col]
	li $t3, 0
	sb $t3, 0($t0)              #store 0
	addu $s7, $s7, 1            #actions++
	j for_loop

false_return:
	li $v0, 0
	j complete

complete:
	add $sp, $sp, 36            #alloc stack
	lw  $ra, 0($sp)             #restore ra
	lw  $s0, 4($sp)             #restore s0
	lw  $s1, 8($sp)             #restore s1
	lw  $s2, 12($sp)            #restore s2
	lw  $s3, 16($sp)            #restore s3
	lw  $s4, 20($sp)            #restore s4
	lw  $s5, 24($sp)            #restore s5
	lw  $s6, 28($sp)            #restore s6
	lw  $s7, 32($sp)            #restore s7

	jr $ra
