// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire[31:0] inst;
    wire[31:0] PC;
    wire[31:0] nextPC, PC_four, branch_out, branch_offset, rs_data, jump, imm32, lui_connect, mem, rd_data, B, rt_data, out, slt_out, data_out, byte_load, byte_out, new_neg, b_out, rd_final, addm_data;
    // wire [31:0] nextPC, rsdata, rtdata, b, out, imm32, PC0, PC1, branch_offset, jump, addr, negzero, zeroadd,
    //             slt_out, mr_out, bl_out, rddata, bout, addmout, dataout, mr_in, lui1, bl_change;
    //wire [7:0] bl_in;
    wire [4:0] rdest;
    wire [2:0] alu_op;
    wire [1:0] control_type;
    wire wr_enable, alu_src2, rd_src, lui, slt, byte_load, word_we, byte_we, mem_read, addm;
    wire overflow, zero, negative;

    assign jump[31:28] = PC[31:28];
    assign jump[1:0] = 0;
    assign jump[27:2] = inst[25:0];

    assign lui_connect[31:16] = inst[15:0];
    assign lui_connect[15:0] = 0;

    assign byte_load[31:8] = 0;
    assign new_neg[0] = negative;
    assign new_neg[31:1] = 0;

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(32) PC_reg(PC,[31:0] nextPC[31:0], clock, 1'b1, reset);
    instruction_memory im(inst[31:0], PC[31:2]);
    mips_decode m1(alu_op[2:0], wr_enable, rd_src, alu_src2, except, control_type[1:0], mem_read, word_we, byte_we, byte_load, lui, slt, addm, inst[31:26], inst[5:0], zero);
    data_mem dm1(dataout[31:0], out[31:0], rt_data[31:0], word_we, byte_we, clock, reset);
    regfile rf (rs_data[31:0], rt_data[31:0], inst[25:21], inst[20:16], r_dest[4:0], rd_data[31:0], wr_enable, clock, reset);

    /* add other modules */

    alu32 #(32) a1(PC_four, , , , PC[31:0], 32'h4, `ALU_ADD);
    alu32 #(32) a2(branch_out[31:0], , , , PC_four[31:0], branch_offset[31:0], `ALU_ADD);
    alu32 #(32) a3(out[31:0], overflow, zero, negative, rs_data[31:0], B[31:0], alu_op[2:0]);
    alu32 #(32) a4(addm_data[31:0], , , , rt_data[31:0], data_out[31:0], 3'b010);

    mux2v maddm(B[31:0], b_out[31:0], 32'b0, addm);
    mux2v maddm2(rd_data[31:0], rd_final[31:0], addm_data[31:0], addm);
    mux2v #(5) msrc(rdest[4:0], inst[15:11], inst[20:16], rd_src);
    mux2v #(32) mlui(rd_final[31:0], mem_read[31:0], lui_connect[31:0], lui);
    mux2v #(32) mslt(slt_out[31:0], out[31:0], new_neg, slt);
    mux2v #(32) mem_read(mem_read[31:0], slt_out,[31:0] byte_out[31:0], mem_read);
    mux2v #(32) byte_load(byte_out[31:0], dataout[31:0], byte_load[31:0], byte_load);
    mux2v #(32) msrc2(b_out[31:0], rt_data[31:0], imm32[31:0], alu_src2);

    mux4v #(32) m4_to_PC(nextPC[31:0], PC_four[31:0], branch_out[31:0], jump, rs_data, control_type);
    mux4v #(8) m4_dataout(byte_load[7:0], data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24], out[1:0]);

    sign_extender se(imm32, inst[15:0]);
    shift_left_2 sl2(branch_offset, imm32[29:0]);

endmodule // full_machine

module sign_extender(imm32, inst);
  output[31:0] imm32;
  input[15:0] inst;

  assign imm32 = {{16{inst[15]}}, inst[15:0]};

endmodule //sign_extender

module shift_left_2(branch_offset, imm32);
  output[31:0] branch_offset ;
  input[29:0] imm32;

  assign branch_offset[31:2] = imm32[29:0];
  assign branch_offset[1:0] = 0;

endmodule //shift_left_2
