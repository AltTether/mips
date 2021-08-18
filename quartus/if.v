module IF (
           input wire         CLK, RST, WE,
           input wire [2:0]   bout,
           input wire [31:0]  newPC, W_Ins,
           output reg [31:0]  PC,
           output wire [31:0] nextPC, Ins);
`include "common_param.vh"
   
   reg [31:0]                 IMem [0:IMEM_SIZE-1];

   initial begin
      $readmemb("IMems/IMem63_1.txt", IMem, 8'h00, 8'h3f);
   end

   always @(posedge CLK) begin
      if (RST) PC = 32'd0;
      else if (WE) IMem[PC >> 2] <= W_Ins;
      else if (bout[0] | bout[1]) PC = newPC;
   end

   assign Ins = IMem[PC >> 2];
   assign nextPC = PC + 4;
endmodule
