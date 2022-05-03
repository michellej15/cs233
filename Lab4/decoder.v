// mips_decode: a decoder for MIPS arithmetic instructions
//
// rd_src      (output) - should the destination register be rd (0) or rt (1)
// writeenable (output) - should a new value be captured by the register file
// alu_src2    (output) - should the 2nd ALU source be a register (0), zero extended immediate or sign extended immediate
// alu_op      (output) - control signal to be sent to the ALU
// except      (output) - set to 1 when the opcode/funct combination is unrecognized
// opcode      (input)  - the opcode field from the instruction
// funct       (input)  - the function field from the instruction
//

module mips_decode(rd_src, writeenable, alu_src2, alu_op, except, opcode, funct);
    output       rd_src, writeenable, except;
    output [1:0] alu_src2;
    output [2:0] alu_op;
    input  [5:0] opcode, funct;

    wire wadd = (opcode == `OP_OTHER0) && (funct  == `OP0_ADD);
    wire waddu = (opcode == `OP_OTHER0) && (funct == `OP0_ADDU);
    wire wsub = (opcode == `OP_OTHER0) && (funct == `OP0_SUB);
    wire w_and = (opcode == `OP_OTHER0) && (funct == `OP0_AND);
    wire w_or = (opcode == `OP_OTHER0) && (funct == `OP0_OR);
    wire wnor = (opcode == `OP_OTHER0) && (funct == `OP0_NOR);
    wire wxor = (opcode == `OP_OTHER0) && (funct == `OP0_XOR);
    wire waddi = (opcode == `OP_ADDI);
    wire waddui = (opcode == `OP_ADDIU);
    wire wandi = (opcode == `OP_ANDI);
    wire wori = (opcode == `OP_ORI);
    wire wxori = (opcode == `OP_XORI);

    assign rd_src = (waddi | waddui | wandi | wori | wxori);
    assign except = (wadd | waddu | wsub | w_and | w_or | wnor | wxor | waddi | waddui | wandi | wori | wxori);
    assign writeenable = ~except;
    assign alu_src2 = (waddi | waddui | wandi | wori | wxori);
    assign alu_op[0] = (wsub | w_or | wxor | wori | wxori);
    assign alu_op[1] = (wadd | wsub | wnor | wxor | waddi | wxori);
    assign alu_op[2] = (w_and | w_or | wxor | wnor | wandi | wori | wxori);

endmodule // mips_decode
