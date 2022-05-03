module machine(clk, reset);
   input        clk, reset;

   wire [31:0]  PC;
   wire [31:2]  next_PC, PC_plus4, PC_target;
   wire [31:0]  inst;

   wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
   wire [4:0]   rs = inst[25:21];
   wire [4:0]   rt = inst[20:16];
   wire [4:0]   rd = inst[15:11];

   wire [4:0]   wr_regnum;
   wire [2:0]   ALUOp;

   wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET;
   wire         PCSrc, zero, negative;
   wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

   wire [31:0]  mfc0_mux_in, t_address, cycle, c0_rd;
   wire         new_mem_read, new_mem_wr;
   wire [31:0]  t_data, c0_wr_data;
   wire [29:0]  EPC;
   wire         TakenInterrupt, TimerInterrupt, TimerAddress, NotIO;
   wire [31:2]  eret_out, taken_io;
   wire [31:0]  read_data;

   mux2v #(30) mEret(eret_out, next_PC, EPC, ERET);
   mux2v #(30) mTakeint(taken_io, eret_out, 30'h20000060, TakenInterrupt);

   register #(30, 30'h100000) PC_reg(PC[31:2], taken_io, clk, /* enable */1'b1, reset);
   assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
   adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
   adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
   mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
   assign PCSrc = BEQ & zero;

   instruction_memory imem (inst, PC[31:2]);

   mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET,
                      inst);

   regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum, wr_data,
               RegWrite, clk, reset);

   mux2v #(32) imm_mux(B_data, rd2_data, imm, ALUSrc);
   alu32 alu(alu_out_data, zero, negative, ALUOp, rd1_data, B_data);

   data_mem data_memory(load_data, alu_out_data, rd2_data, new_mem_read, new_mem_wr, clk, reset);

   mux2v #(32) wb_mux(mfc0_mux_in, alu_out_data, load_data, MemToReg);
   mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

   assign c0_wr_data = rd2_data;
   assign t_data = rd2_data;
   assign t_address = alu_out_data;
   assign load_data = cycle;
   assign load_data = read_data;

   mux2v mMfc0(wr_data, mfc0_mux_in, c0_rd, MFC0);

   not nTimerAddr(NotIO, TimerAddress);
   and aMemRead(new_mem_read, MemRead, NotIO);
   and aMemWrite(new_mem_wr, NotIO, MemWrite);

   cp0 cpO_one(c0_rd, EPC, TakenInterrupt, c0_wr_data, rd, next_PC, MTC0, ERET, TimerInterrupt, clk, reset);
   timer timer1(TimerInterrupt, cycle, TimerAddress, t_data, t_address, MemRead, MemWrite, clk, reset);

endmodule // machine
