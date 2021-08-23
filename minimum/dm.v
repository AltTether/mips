module DM(
          input         CLK, RST,
          input [2:0]   BOUT,
          input [31:0]  Result, Rdata2, nextPC, Ins,
          output [31:0] Wdata);
`include "common_param.vh"

   reg [31:0]           DMem [0:DMEM_SIZE-1];

   wire [5:0]           Opcode, Funct;
   wire [31:0]          Adr;
   
   integer              i;

   initial begin
      for (i = 0; i < DMEM_SIZE; i = i + 1) DMem[i] = 32'd0;
   end

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];
   assign Adr = (Result >> 2) & 32'd63;

   always @(posedge CLK) begin
      if (RST == 1'b1) for (i = 0; i < DMEM_SIZE; i = i + 1) DMem[i] = 32'd0;
      else if (Opcode == SW && (BOUT[0] || BOUT[1])) DMem[Adr] = Rdata2;
      else DMem[i] = DMem[i];
   end

   function [31:0] getMUX3Result(input[5:0] opc, fct, input[31:0] result, nextpc);
      if (opc == BEQ) getMUX3Result = result;
      else if (opc == JAL) getMUX3Result = nextpc;
      else if (opc == SW) getMUX3Result = 32'd0;
      else getMUX3Result = result;
   endfunction

   assign Wdata = (Opcode == LW) ? DMem[Adr] : getMUX3Result(Opcode, Funct, Result, nextPC);

endmodule
