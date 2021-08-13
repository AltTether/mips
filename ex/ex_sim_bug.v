`timescale 1 ps/ 1 ps


module ex_sim_bug();
parameter PERIOD=10000;  // (clock period)/2

// constants
// general purpose registers
   reg clk, rst;
   reg [31:0] rdata1, rdata2, ed32;
   reg [31:0] nextpc, ins;

// wires
   wire [31:0] newpc;
   wire [31:0] result;

// assign statements (if any)
EX ex2 (
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

initial
  begin
     // BEQ
     ins=#(PERIOD) {6'h04, 20'd0, 6'd0};
     rdata1=32'd10; rdata2=32'd10; nextpc=32'd12; ed32=32'd24;
     ins=#(PERIOD) {6'h04, 20'd0, 6'd0};
     rdata1=32'd10; rdata2=32'd300; nextpc=32'd12; ed32=32'd24;

end
endmodule
