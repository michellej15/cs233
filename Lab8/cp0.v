`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;

    // your Verilog for coprocessor 0 goes here
    wire [31:0]   status_register, cause_register, user_status;
    wire          exception_level;
    wire [31:0]   decoder_output, epc_extended;
    wire [29:0]   epc_register_data;
    wire          one_output, two_output, not_output;
    wire          except_level_reset, epc_register_enable;

    assign status_register[31:16]  = {16{1'b0}};
    assign status_register[15:8]   = user_status[15:8];
    assign status_register[7:2]    = {6{1'b0}};
    assign status_register[1]      = exception_level;
    assign status_register[0]      = user_status[0];

    assign cause_register[31:16]   = {16{1'b0}};
    assign cause_register[15]      = TimerInterrupt;
    assign cause_register[14:0]    = {15{1'b0}};

    assign epc_extended[31:2]      = EPC[29:0];
    assign epc_extended[1:0]       = {2{1'b0}};

    decoder32 decoder(decoder_output, regnum, MTC0);

    mux2v #(30) muxEPC(epc_register_data, wr_data[31:2], next_pc, TakenInterrupt);
    mux3v #(32) muxRdData(rd_data, status_register, cause_register, epc_extended, regnum[1:0]);

    register #(32) userStatus(user_status, wr_data, clock, decoder_output[12], reset);
    register #(30) epcRegister(EPC, epc_register_data, clock, epc_register_enable, reset);
    dffe exceptionLevel(exception_level, 1'b1, clock, TakenInterrupt, except_level_reset);

    not notStatReg(not_output, status_register[1]);
    and aOne(one_output, cause_register[15], status_register[15]);
    and aTwo(two_output, not_output, status_register[0]);
    and aAnd(TakenInterrupt, one_output, two_output);
    or oReset(except_level_reset, reset, ERET);
    or oEnable(epc_register_enable, decoder_output[14], TakenInterrupt);

endmodule
