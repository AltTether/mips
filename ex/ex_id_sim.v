`timescale 1 ps/ 1 ps


module ex_id_sim();
`include "common_param.vh"
   parameter PERIOD=10000;  // (clock period)/2

// constants
// general purpose registers
   reg clk, rst;
   wire [31:0] rdata1, rdata2, ed32;
   reg [31:0] nextpc, ins;

// wires
   wire [31:0] newpc;
   wire [31:0] result;
   reg [31:0] wdata;

   /*/
// assign statements (if any)
EX ex1 (
// port map - connection between master ports and signals/registers
        .CLK(clk),
        .RST(rst),
        .nextPC(nextpc),
        .newPC(newpc),
        .Ins(ins),
        .Rdata1(rdata1),
        .Rdata2(rdata2),
        .Ed32(ed32),
        .Result(result)
);
    /*/
   ID id1 (
           .CLK(clk),
           .RST(rst),
           .Ins(ins),
           .Rdata1(rdata1),
           .Rdata2(rdata2),
           .Ed32(ed32),
           .Wdata(wdata)
           );

   always begin
      clk=#(PERIOD) 1'd1;
      clk=#(PERIOD) 1'd0;
   end

   initial
     begin
        rst=1'd0;
        nextpc=32'd0;
        
        ins=#(PERIOD) {6'h00, 5'd16, 5'd16, 5'd16, 5'd0, ADD};
        wdata=32'd32;

        ins=#(PERIOD*2) {6'h00, 5'd4, 5'd4, 5'd4, 5'd0, ADD};
        wdata=32'd64;

        ins=#(PERIOD*2) {6'h00, 5'd16, 5'd4, 10'd0, JR};

        ins=#(PERIOD*2) {6'h00, 5'd4, 5'd16, 10'd0, JR};
     end
endmodule
