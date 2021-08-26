module IF (
           input             CLK, RST, WE,
           input [1:0]       bout,
           input [31:0]      newPC,
           input [31:0]      W_Ins,
           output reg [31:0] PC,
           output [31:0]     nextPC,
           output [31:0]     Ins);
`include "common_param.vh"
   
   reg [31:0]                IMem [0:IMEM_SIZE-1];


   initial begin
      $readmemh("IMems/IMem_hanoi.txt", IMem, 8'h00, 8'h3f);
   end

   always @(posedge CLK) begin
      if (~RST == 1'b1 && WE == 1'b1) IMem[PC >> 2] = W_Ins;
      if (RST == 1'b1) PC = 32'd0;
      else if (bout[0] == 1'b1 | bout[1] == 1'b1) PC = newPC;
      else PC = PC;
   end

   assign nextPC = PC + 4;
   assign Ins = IMem[PC>>2];

endmodule
