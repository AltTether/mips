module DM(
          input wire         CLK, RST,
          input wire [31:0]  Result, Rdata2, nextPC, Ins,
          output wire [31:0] Wdata);
`include "common_param.vh"

   reg [31:0]           DMem [0:DMEM_SIZE-1];

   integer              i;

   /*
   initial begin
      for (i = 0; i < DMEM_SIZE; i = i + 1) DMem[i] = 32'd0;
   end
    */

   assign Adr = Result;
   
   always @(posedge CLK) begin
      if (RST) begin
         for (i = 0; i < DMEM_SIZE; i = i + 1)
           DMem[i] = 32'd0;
      end else if (~RST && Ins[31:26] == SW) begin
         DMem[Adr] = Rdata2;
      end
   end

   function [31:0] getMUX3Result(input[5:0] opc, fct, input[31:0] result, nextpc);
      if (opc == JAL || (fct == JALR && opc == R_FORM))
        getMUX3Result = nextpc;
      else
        getMUX3Result = result;
   endfunction

   assign Wdata = (Ins[31:26] == LW) ? DMem[Adr] : getMUX3Result(Ins[31:26],Ins[5:0], Result, nextPC);

endmodule
