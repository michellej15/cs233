// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_op       (output) - control signal to be sent to the ALU
// writeenable  (output) - should a new value be captured by the register file
// rd_src       (output) - should the destination register be rd (0) or rt (1)
// alu_src2     (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// except       (output) - set to 1 when we don't recognize an opdcode & funct combination
// control_type (output) - 00 = fallthrough, 01 = branch_target, 10 = jump_target, 11 = jump_register
// mem_read     (output) - the register value written is coming from the memory
// word_we      (output) - we're writing a word's worth of data
// byte_we      (output) - we're only writing a byte's worth of data
// byte_load    (output) - we're doing a byte load
// slt          (output) - the instruction is an slt
// lui          (output) - the instruction is a lui
// addm         (output) - the instruction is an addm
// opcode        (input) - the opcode field from the instruction
// funct         (input) - the function field from the instruction
// zero          (input) - from the ALU
//

module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   opcode, funct, zero);
    output [2:0] alu_op;
    //output [1:0] alu_src2;
    output       writeenable, rd_src, alu_src2, except;
    output [1:0] control_type;
    output       mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    input  [5:0] opcode, funct;
    input        zero;

    wire wadd, wsub, w_and, w_or, wnor, wxor, waddi, wandi, wori, wxori;
    wire bne, beq, j, jr, lw, lbu, sw, sb;

    assign wadd = ((opcode == `OP_OTHER0 & funct == `OP0_ADD));
    assign wsub = ((opcode == `OP_OTHER0 & funct == `OP0_SUB));
    assign w_and = ((opcode == `OP_OTHER0 & funct == `OP0_AND));
    assign w_or = ((opcode == `OP_OTHER0 & funct == `OP0_OR));
    assign wnor = ((opcode == `OP_OTHER0 & funct == `OP0_NOR));
    assign wxor = ((opcode == `OP_OTHER0 & funct == `OP0_XOR));
    assign waddi = (opcode == `OP_ADDI);
    assign wandi = (opcode == `OP_ANDI);
    assign wori = (opcode == `OP_ORI);
    assign wxori = (opcode == `OP_XORI);

    assign alu_op[0] = (wsub | w_or | wxor | wori | wxori | bne | beq | slt);
    assign alu_op[1] = (wadd | wsub | wnor | wxor | waddi | wxori | bne | beq | lw | lbu | sw | sb | slt | addm);
    assign alu_op[2] = (w_and | w_or | wnor | wxor | wandi | wori | wxori);

    assign writeenable = (wadd | wsub | w_and | w_or | wnor | wxor | waddi | wandi | wori | wxori | bne | beq | j | jr | lw | lbu | sw | sb | lui | slt | addm);
    assign rd_src = (waddi | wandi | wori | wxori | lw | lbu | lui);
    assign alu_src2 = (waddi | wandi | wori | wxori | lw | lbu | sw | sb);
    assign except = (wadd | wsub | w_and | w_or | wnor | wxor | waddi | wandi | wori | wxori | lw | lbu | sw | sb | lui | slt | addm);

    assign bne = (opcode == `OP_BNE);
    assign beq = (opcode == `OP_BEQ);
    assign j = (opcode == `OP_J);
    assign jr = ((opcode == `OP_OTHER0) & funct == `OP0_JR);
    assign lw = (opcode == `OP_LW);
    assign lbu = (opcode == `OP_LBU);
    assign sw = (opcode == `OP_SW);
    assign sb = (opcode == `OP_SB);

    assign lui = (opcode == `OP_LUI);
    assign slt = ((opcode == `OP_OTHER0) & funct == `OP0_SLT);
    assign addm = ((opcode == `OP_OTHER0) & funct == `OP0_ADDM);
    assign mem_read = (lw | lbu);
    assign word_we = sw;
    assign byte_we = sb;
    assign byte_load = lbu;
    assign control_type[0] = ((beq & zero) | (bne & ~zero) | jr);
    assign control_type[1] = (j | jr);

endmodule // mips_decode
