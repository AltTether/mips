`timescale 1 ps/ 1 ps


module scmips_sim();
`include "common_param.vh"
   parameter PERIOD=10000;  // (clock period)/2

   // constants
   // general purpose registers
   reg        clk, rst, we;
   reg [2:0]  bin;
   reg [4:0]  slct;
   reg [1:0]  key;
   reg [9:0]  sw;
   reg [31:0] gpio;

   // wires
   wire [4:0]  ledr;
   wire [7:0]  hex0, hex1, hex2, hex3, hex4, hex5;

   Board board0 (.CLK(clk),
                 .RST(rst),
                 .KEY(key),
                 .SW(sw),
                 .GPIO(gpio),
                 .LEDR(ledr),
                 .HEX0(hex0),
                 .HEX1(hex1),
                 .HEX2(hex2),
                 .HEX3(hex3),
                 .HEX4(hex4),
                 .HEX5(hex5));

   always begin
      clk=#(PERIOD) 1'd1;
      clk=#(PERIOD) 1'd0;
   end

   initial
     begin
        we=1'd0; rst=1'd0; bin=3'd0;
        gpio=32'd0; slct=5'd0;
        rst=#(PERIOD) 1'd1;
        rst=#(PERIOD) 1'd0;
     end
endmodule
