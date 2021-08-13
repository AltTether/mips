module DM(
          input         CLK, RST,
          input [31:0]  Result, Rdata2, nextPC, Ins,
          output [31:0] Wdata);
`include "common_param.vh"

   integer              i;
   reg [31:0]           DMem [0:DMEM_SIZE-1];
   reg [5:0]            Opcode, Funct;

   initial begin
      for (i = 0; i < DMEM_SIZE; i = i + 1) DMem[i] = 32'd0;
   end

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];
   always @(posedge CLK) begin
      if (RST) for (i = 0; i < DMEM_SIZE; i = i + 1) DMem[i] = 32'd0;
      else if (~RST && Opcode == SW) DMem[Result] = Rdata2;
   end

   function [31:0] getMUX3Result(opc, fct, result, nextpc);
      begin
         case(opc)
           LW:     getMUX3Result = DMem[result];
           JAL:    getMUX3Result = nextpc;
           6'h00:  getMUX3Result = (fct == JALR) ? nextpc : result;
           default getMUX3Result = result;
         endcase
      end
   endfunction

   assign Wdata = getMUX3Result(Opcode, Funct, Result, nextPC);

endmodule
