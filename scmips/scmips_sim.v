`timescale 1 ps/ 1 ps


module scmips_sim();
`include "common_param.vh"
   parameter PERIOD=10000;  // (clock period)/2

// constants
// general purpose registers
   reg clk, rst, we;
   reg [31:0] wins;
   wire [31:0] rdata1, rdata2, ed32;

// wires
   wire [31:0] result;
   wire [31:0] newpc, nextpc, ins;
   wire [31:0] wdata;

   IF if1 (
           .CLK(clk),
           .RST(rst),
           .WE(we),
           .newPC(newpc),
           .W_Ins(wins),
           .nextPC(nextpc),
           .Ins(ins));

   ID id1 (
           .CLK(clk),
           .RST(rst),
           .Ins(ins),
           .Wdata(wdata),
           .Rdata1(rdata1),
           .Rdata2(rdata2),
           .Ed32(ed32));

   EX ex1 (
           .CLK(clk),
           .RST(rst),
           .nextPC(nextpc),
           .Ins(ins),
           .Rdata1(rdata1),
           .Rdata2(rdata2),
           .Ed32(ed32),
           .Result(result),
           .newPC(newpc));

   DM dm1 (
           .CLK(clk),
           .RST(rst),
           .Result(result),
           .Rdata2(rdata2),
           .nextPC(nextpc),
           .Ins(ins),
           .Wdata(wdata));

   always begin
      clk=#(PERIOD) 1'd1;
      clk=#(PERIOD) 1'd0;
   end

   initial
     begin
        we=1'd0;
        rst=#(PERIOD) 1'd1;
        rst=#(PERIOD) 1'd0;
     end
endmodule
