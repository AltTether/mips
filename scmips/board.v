module Board (
              input        CLK, RST,
              input [1:0]  KEY,
              input [9:0]  SW,
              input [31:0] GPIO,
              output [4:0] LEDR,
              output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

   wire [2:0]             bout;
   wire [31:0]            pc, result;
   //reg [3:0]              cnt;


   BTN_IN b0 (.CLK(CLK), .RST(RST), .nBIN({1'd0, KEY}), .BOUT(bout));
   SingleClockMIPS scm0 (.CLK(CLK), .RST(RST), .WE(SW[8]), .BOUT(bout),
                         .SLCT(SW[4:0]), .W_Ins(GPIO), .PC(pc), .Result(result));

   LEDS l0 (.CLK(CLK), .RST(RST), .SLCT(SW[4:0]), .LEDR(LEDR));
   // Indicate selected Result
   SEG7DEC s0 (.DIN(result[3:0]),   .DOT(1'd0), .nHEX(HEX0));
   SEG7DEC s1 (.DIN(result[7:4]),   .DOT(1'd0), .nHEX(HEX1));
   SEG7DEC s2 (.DIN(result[11:8]),  .DOT(1'd0), .nHEX(HEX2));
   SEG7DEC s3 (.DIN(result[15:12]), .DOT(1'd0), .nHEX(HEX3));
   // Indicate PC
   SEG7DEC s4 (.DIN(pc[3:0]),       .DOT(1'd0), .nHEX(HEX4));
   SEG7DEC s5 (.DIN(pc[7:4]),       .DOT(1'd0), .nHEX(HEX5));

endmodule
