module IF (
           input             CLK, RST, WE,
           input [2:0]       bout,
           input [31:0]      newPC,
           input [31:0]      W_Ins,
           output reg [31:0] PC,
           output [31:0]     nextPC,
           output [31:0]     Ins);
`include "common_param.vh"
   
   reg [31:0]                IMem [0:IMEM_SIZE-1];

   initial begin
      $readmemb("IMems/IMem63_3.txt", IMem, 8'h00, 8'h3f);
   end

   always @(posedge CLK) begin
      if (~RST && WE) IMem[PC>>2] <= W_Ins;
      if (RST) PC = 32'd0;
      else PC = newPC;
   end

   assign Ins = IMem[PC>>2];
   assign nextPC = PC + 4;
endmodule
