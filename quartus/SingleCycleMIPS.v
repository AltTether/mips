module SingleClockMIPS (
                        input wire         CLK, RST, WE,
                        input wire [1:0]   BOUT,
                        input wire [4:0]   SLCT,
                        input wire [31:0]  W_Ins,
                        output wire [31:0] PC, Result);

   wire [31:0]                        newPC, nextPC, Ins, rslt;
   wire [31:0]                        Rdata1, Rdata2, Ed32, Wdata;
   wire [31:0]                        rec;

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
           .Ins(Ins),
           .Wdata(Wdata),
           .Rdata1(Rdata1),
           .Rdata2(Rdata2),
           .Ed32(Ed32));

   EX EX0 (.CLK(CLK),
           .RST(RST),
           .nextPC(nextPC),
           .Ins(Ins),
           .Rdata1(Rdata1),
           .Rdata2(Rdata2),
           .Ed32(Ed32),
           .Result(rslt),
           .newPC(newPC),
           .rec(rec));

   DM DM0 (.CLK(CLK),
           .RST(RST),
           .Result(rslt),
           .Rdata2(Rdata2),
           .nextPC(nextPC),
           .Ins(Ins),
           .Wdata(Wdata));

   LCD LCD0 (.CLK(CLK),
             .SLCT(SLCT),
             .Rdata1(Rdata1),
             .Rdata2(Rdata2),
             .Wdata(Wdata),
             .Ed32(Ed32),
             .nextPC(nextPC),
             .Rslt(rslt),
             .Ins(Ins),
             .rec(rec),
             .Result(Result));
   
endmodule
