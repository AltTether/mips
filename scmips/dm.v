module DM(
          input         CLK, RST,
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
   assign Adr = Result & 32'd1023;

   always @(posedge CLK) begin
      if (RST) for (i = 0; i < DMEM_SIZE; i = i + 1) DMem[i] = 32'd0;
      else if (~RST && Opcode == SW) DMem[Adr] = Rdata2;
   end

   function [31:0] getMUX3Result(input[5:0] opc, fct, input[31:0] result, nextpc);
      if (opc == JAL || (fct == JALR && opc == R_FORM))
        getMUX3Result = nextpc;
      else
        getMUX3Result = result;
   endfunction // getMUX3Result

   assign Wdata = (Ins[31:26] == LW) ? DMem[Adr] : getMUX3Result(Ins[31:26], Ins[5:0], Result, nextPC);

endmodule
