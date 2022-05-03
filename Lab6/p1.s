.text

# // Ignore integer overflow for addition
# int update_alert_level(unsigned int* stockpiles, unsigned int cutoff,
#   unsigned int alert_level) {
#     int total_monster = 0;
#     for (int i = 0; i < 10; i++) {
#         total_monster += stockpiles[i];
#     }
#     if (total_monster < cutoff) {
#         return alert_level + 1;
#     } else if (total_monster == cutoff) {
#         return alert_level;
#     } else {
#         return alert_level - 1;
#     }
# }
# // a0: unsigned int *stockpiles
# // a1: unsigned int cutoff
# // a2: unsigned int alert_level

.globl update_alert_level
update_alert_level:
	li $t0, 0 #total_monster
	li $t1, 0 #i
	li $t2, 10 #i < 10
for_loop:
	bge $t1, $t2, if
	lw $t3, 0($a0)
	add $t0, $t3, $t0
	add $t1, $t1, 1
	j for_loop
if:
	bge $t0, $a1, else_if
	addi $v0, $a1, 1
	j return
else_if:
	bge $t0, $a1, else
	addi $v0, $a1, 0
	j return
else:
	sub $a2, $a2, 1
	j return
return:
	jr $ra
