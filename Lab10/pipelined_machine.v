module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target;
    wire [31:0]  inst;

    wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
    wire [4:0]   rs = inst[25:21];
    wire [4:0]   rt = inst[20:16];
    wire [4:0]   rd = inst[15:11];
    wire [5:0]   opcode = inst[31:26];
    wire [5:0]   funct = inst[5:0];

    wire [4:0]   wr_regnum;
    wire [2:0]   ALUOp;

    wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst;
    wire         PCSrc, zero;
    wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

    wire [29:0]  temp_PCp4_IF, temp_PCp4_DE;
    wire [31:0]  temp_inst_IF, temp_alu_out_DE, temp_alu_out_MW, temp_rd2_DE, temp_rd2_MW;
    wire         temp_RegWrite_DE, temp_BEQ_DE, temp_aluSrc_DE, temp_MemRead_DE, temp_MemWrite_DE, temp_MemToReg_DE, temp_RegDst_DE;
    wire [2:0]   temp_AluOp_DE, temp_AluOp_MW;
    wire [4:0]   temp_wrRegnum_DE, temp_wrRegnum_MW;

    wire         ForwardA, ForwardB, stall;
    wire [31:0]  temp_rd1_data, temp_rd2_data;

    assign ForwardA = (rs != 5'b0) & (rs == temp_wrRegnum_MW) & RegWrite;
    assign ForwardB = (rt != 5'b0) & (rt == temp_wrRegnum_MW) & RegWrite;

    assign stall = (((temp_wrRegnum_MW == rs) & (rs != 5'b0)) | ((temp_wrRegnum_MW == rt) & (rt != 5'b0)) & (rt != wr_regnum)) & MemRead;

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */1'b1, reset);

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
    register_pc pipeline_reg_IF(temp_PCp4_IF, PC_plus4, clk, ~stall, (PCSrc |reset));  //PC_plus4
    adder30 target_PC_adder(PC_target, temp_PCp4_IF, imm[29:0]);
    mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
    assign PCSrc = BEQ & zero;

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory imem(temp_inst_IF, PC[31:2]);
    register inst_IF(inst, temp_inst_IF, clk, ~stall, (PCSrc | reset));

    mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst,
                      opcode, funct);

    // Pipeline
    register_decode1 rRegWrite_DE(RegWrite, temp_RegWrite_DE, clk, 1'b1, reset);
    register_decode1 rMemRead_DE(MemRead, temp_MemRead_DE, clk, 1'b1, reset);
    register_decode1 rMemWrite_DE(MemWrite, temp_MemWrite_DE, clk, 1'b1, reset);
    register_decode1 rMemToReg_DE(MemToReg, temp_MemToReg_DE, clk, 1'b1, reset);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (temp_rd1_data, temp_rd2_data,
               rs, rt, temp_wrRegnum_MW, wr_data,
               RegWrite, clk, reset);

    mux2v #(32) forwardMuxA(rd1_data, temp_rd1_data, alu_out_data, ForwardA);
    mux2v #(32) forwardMuxB(temp_rd2_DE, temp_rd2_data, alu_out_data, ForwardB);
    mux2v #(32) imm_mux(B_data, temp_rd2_DE, imm, ALUSrc);
    alu32 alu(temp_alu_out_DE, zero, ALUOp, rd1_data, B_data);

    register alu_out_IF(alu_out_data, temp_alu_out_DE, clk, 1'b1, reset);
    register rd2_data_DE(rd2_data, temp_rd2_DE, clk, 1'b1, reset);

    // DO NOT comment out or rename this module
    // or the test bench will break
    data_mem data_memory(load_data, alu_out_data, rd2_data, MemRead, MemWrite, clk, reset);

    mux2v #(32) wb_mux(wr_data, alu_out_data, load_data, MemToReg);
    mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

    register_RegNum rRegNum_DE(temp_wrRegnum_MW, wr_regnum, clk, 1'b1, reset);

endmodule // pipelined_machine

module register_pc(q, d, clk, enable, reset);

   parameter
            width = 30,
            reset_value = 0;

   output [(width-1):0] q;
   reg    [(width-1):0] q;
   input  [(width-1):0] d;
   input                clk, enable, reset;

   always@(posedge clk)
     if (reset == 1'b1)
       q <= reset_value;
     else if (enable == 1'b1)
       q <= d;

endmodule // register

module register_decode1(q, d, clk, enable, reset);

   parameter
            width = 1,
            reset_value = 0;

   output [(width-1):0] q;
   reg    [(width-1):0] q;
   input  [(width-1):0] d;
   input                clk, enable, reset;

   always@(posedge clk)
     if (reset == 1'b1)
       q <= reset_value;
     else if (enable == 1'b1)
       q <= d;

endmodule // register

module register_decode_3(q, d, clk, enable, reset);

   parameter
            width = 3,
            reset_value = 0;

   output [(width-1):0] q;
   reg    [(width-1):0] q;
   input  [(width-1):0] d;
   input                clk, enable, reset;

   always@(posedge clk)
     if (reset == 1'b1)
       q <= reset_value;
     else if (enable == 1'b1)
       q <= d;

endmodule // register

module register_RegNum(q, d, clk, enable, reset);

   parameter
            width = 5,
            reset_value = 0;

   output [(width-1):0] q;
   reg    [(width-1):0] q;
   input  [(width-1):0] d;
   input                clk, enable, reset;

   always@(posedge clk)
     if (reset == 1'b1)
       q <= reset_value;
     else if (enable == 1'b1)
       q <= d;

endmodule // register
