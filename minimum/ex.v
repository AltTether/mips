module EX(
          input         CLK, RST,
          input [31:0]  nextPC, Ins,
          input [31:0]  Rdata1, Rdata2, Ed32,
          output [31:0] Result, newPC
);
`include "common_param.vh"

   wire [5:0]           Opcode, Funct;
   wire [31:0]          Shamt;

   // Instructions for RType
   function [31:0] getALURResult (input[5:0] fct, input[31:0] rdata1, rdata2, shamt);
      case(fct)
        SLL:    getALURResult = {rdata2 << shamt};
        ADD:    getALURResult = rdata1 + rdata2;
        ADDU:   getALURResult = rdata1 + rdata2;
        SLT:    getALURResult = {31'b0, (rdata1 < rdata2)};
        default getALURResult = 32'd0;
      endcase // case (Funct)
   endfunction // getALURResult

   // Instructions for RType
   function [31:0] getALUIResult (input[5:0] opc, input[31:0] rdata1, rdata2, ed32);
      case(opc)
        ADDI:    getALUIResult = rdata1 + ed32;
        ADDIU:   getALUIResult = rdata1 + ed32;
        LW:      getALUIResult = rdata1 + ed32;
        SW:      getALUIResult = rdata1 + ed32;
        BEQ:     getALUIResult = {31'b0, (rdata1 == rdata2)};
        SLTI:    getALUIResult = {31'b0, (rdata1 < ed32)};
        default  getALUIResult = 32'd0;
      endcase // case (Funct)
   endfunction // getALUIResult

   function [31:0] getMUX5RResult (input[5:0] fct, input[31:0] rdata1, nextpc);
      begin
         case(fct)
           JR:     getMUX5RResult = rdata1;
           default getMUX5RResult = nextPC;
         endcase
      end
   endfunction // getMUX5RResult

   reg [31:0] pc;
   reg [27:0] jadr;
   function [31:0] beqAddr(input[31:0] ed32, nextpc);
      beqAddr = nextpc + (ed32 << 2);
   endfunction // beqAddr

   function [31:0] getMUX5IJResult (input[5:0] opc, input[31:0] ins, ed32, nextpc, result);
      case(opc)
        J:      begin jadr = (ins[25:0] << 2); pc = nextpc - 4; getMUX5IJResult = {pc[31:28], jadr}; end
        JAL:    begin jadr = (ins[25:0] << 2); pc = nextpc - 4; getMUX5IJResult = {pc[31:28], jadr}; end
        BEQ:    getMUX5IJResult = (result) ? beqAddr(ed32, nextpc) : nextpc;
        default getMUX5IJResult = nextpc;
      endcase
   endfunction

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];
   assign Shamt = {27'd0, Ins[10:6]};
   
   //assign MUX2Result = (Opcode == 6'h00) ? Rdata2 : Ed32;
   assign Result = (Opcode == R_FORM) ? getALURResult(Funct, Rdata1, Rdata2, Shamt) : getALUIResult(Opcode, Rdata1, Rdata2, Ed32);
   assign newPC = (Opcode == R_FORM) ? getMUX5RResult(Funct, Rdata1, nextPC) : getMUX5IJResult(Opcode, Ins, Ed32, nextPC, Result);

endmodule
