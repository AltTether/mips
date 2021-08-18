module Board (
              input wire        CLK, RST, WE,
              input wire [1:0]  KEY,
              input wire [4:0]  SLCT,
              input wire [31:0] W_Ins,
              output wire [4:0] LEDR,
              output wire [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

   wire [1:0]             BOUT;
   wire [31:0]            PC, Result;
   wire [31:0]            Result2;

   BTN_IN B0 (.CLK(CLK), .RST(RST), .nBIN(KEY), .BOUT(BOUT));
   
   SingleClockMIPS SCM0 (.CLK(CLK), .RST(RST), .WE(WE), .BOUT(BOUT),
                         .SLCT(SLCT), .W_Ins(W_Ins), .PC(PC), .Result(Result));

   LEDS l0 (.CLK(CLK), .RST(RST), .SLCT(SLCT), .LEDR(LEDR));
   // Indicate selected Result
   SEG7DEC s0 (.DIN(Result[3:0]),   .DOT(1'd0), .nHEX(HEX0));
   SEG7DEC s1 (.DIN(Result[7:4]),   .DOT(1'd0), .nHEX(HEX1));
   SEG7DEC s2 (.DIN(Result[11:8]),  .DOT(1'd0), .nHEX(HEX2));
   SEG7DEC s3 (.DIN(Result[15:12]), .DOT(1'd0), .nHEX(HEX3));
   // Indicate PC
   SEG7DEC s4 (.DIN(PC[3:0]),       .DOT(1'd0), .nHEX(HEX4));
   SEG7DEC s5 (.DIN(PC[7:4]),       .DOT(1'd0), .nHEX(HEX5));

endmodule
