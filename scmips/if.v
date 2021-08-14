module IF (
           input reg         CLK, RST, WE,
           input reg [31:0]  newPC,
           input reg [31:0]  W_Ins,
           output reg [31:0] nextPC,
           output reg [31:0] Ins);
`include "common_param.vh"
   
   reg [31:0]                IMem [0:IMEM_SIZE-1];
   reg [31:0]                PC;

   initial begin
      $readmemb("IMems/IMem63_4.txt", IMem, 8'h00, 8'h3f);
   end

   always @(posedge CLK) begin
      if (~RST && WE) IMem[PC>>2] <= W_Ins;
      if (RST) PC = 32'd0;
      else PC = newPC;
   end

   assign Ins = IMem[PC>>2];
   assign nextPC = PC + 4;
endmodule
