module SingleClockMIPS (input         CLK, RST, WE,
                        input [1:0]   BOUT,
                        input [4:0]   SLCT,
                        input [31:0]  W_Ins,
                        output [31:0] PC, Result);

  wire [31:0] newPC, nextPC, Ins, rslt;
  wire [31:0] Rdata1, Rdata2, Ed32, Wdata;
  //wire WE;

   IF IF0 (.CLK(CLK),
           .RST(RST),
           .WE(WE),
           .bout(BOUT),
           .newPC(newPC),
           .W_Ins(W_Ins),
           .PC(PC),
           .nextPC(nextPC),
           .Ins(Ins));

   ID ID0 (.CLK(CLK),
           .RST(RST),
           .BOUT(BOUT),
           .Ins(Ins),
           .Wdata(Wdata),
           .Rdata1(Rdata1),
           .Rdata2(Rdata2),
           .Ed32(Ed32));

   EX EX0 (.CLK(CLK),
           .RST(RST),
           .BOUT(BOUT),
           .nextPC(nextPC),
           .Ins(Ins),
           .Rdata1(Rdata1),
           .Rdata2(Rdata2),
           .Ed32(Ed32),
           .Result(rslt),
           .newPC(newPC));

   DM DM0 (.CLK(CLK),
           .RST(RST),
           .BOUT(BOUT),
           .Result(rslt),
           .Rdata2(Rdata2),
           .nextPC(nextPC),
           .Ins(Ins),
           .Wdata(Wdata));

   LCD LCD0 (.CLK(CLK),
             .RST(RST),
             .SLCT(SLCT),
             .Rdata1(Rdata1),
             .Rdata2(Rdata2),
             .Wdata(Wdata),
             .nextPC(nextPC),
             .Rslt(rslt),
             .Result(Result));

endmodule
