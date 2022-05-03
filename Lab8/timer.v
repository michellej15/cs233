module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;

    // complete the timer circuit here

    // HINT: make your interrupt cycle register reset to 32'hffffffff
    //       (using the reset_value parameter)
    //       to prevent an interrupt being raised the very first cycle
    wire [31:0]   qCycle, dCycle, qInterrupt;

    wire equalOne = {32'hffff001c == address};
    wire equalTwo = {32'hffff006c == address};

    assign TimerAddress = (equalOne || equalTwo);

    wire TimerWrite = MemWrite & equalOne;
    wire TimerRead = MemRead & equalOne;
    wire Acknowledge = MemWrite & equalTwo;

    register #(32) cycleCounter(qCycle, dCycle, clock, 1'b1, reset);

    register #(, 32'hffffffff) interruptCycle(qInterrupt, data, clock, TimerWrite, reset);
    register #(1) interruptLine(TimerInterrupt, 1'b1, clock, (qCycle == qInterrupt), Acknowledge || reset);
    alu32 aluOp(dCycle, , , `ALU_ADD, qCycle, 32'b1);
    tristate timeReadTristate(cycle, qCycle, TimerRead);
endmodule
