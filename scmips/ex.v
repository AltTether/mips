module EX(
          input reg         CLK, RST,
          input reg [31:0]  nextPC, Ins,
          input reg [31:0]  Rdata1, Rdata2, Ed32,
          output reg [31:0] Result, newPC
);
`include "common_param.vh"

   reg [31:0]               lo, hi;
   reg [64:0]               reg64;
   reg [27:0]               jadr;
   reg [31:0]               rec1, rec2, rec3, rec4, rec5;

   reg [5:0]                Opcode, Funct;

   // Instructions for RType
   function [31:0] getALURResult (input[6:0] Funct, input[31:0] rdata1, rdata2);
      case(Funct)
        ADD:    getALURResult = rdata1 + rdata2;
        ADDU:   getALURResult = rdata1 + rdata2;
        SUB:    getALURResult = rdata1 - rdata2;
        SUBU:   getALURResult = rdata1 - rdata2;
        AND:    getALURResult = rdata1 & rdata2;
        OR:     getALURResult = rdata1 | rdata2;
        XOR:    getALURResult = rdata1 ^ rdata2;
        NOR:    getALURResult = ~(rdata1 | rdata2);
        SLT:    getALURResult = rdata1 < rdata2;
        SLTU:   getALURResult = rdata1 < rdata2;
        // Shift Op
        SLL:    getALURResult = rdata1 << rdata2;
        SRL:    getALURResult = rdata1 >> rdata2;
        // TODO: research how to do on arithmetic shift
        SRA:    getALURResult = rdata1 >> rdata2;
        SLLV:   getALURResult = rdata1 << rdata2;
        SRLV:   getALURResult = rdata1 >> rdata2;
        SRAV:   getALURResult = rdata1 >> rdata2;
        // Mult & Div
        //MFHI:  begin Rdata2 = hi; getALURResult = 32'd0; end
        MTHI:   begin hi = rdata2; getALURResult = 32'd0; end
        //MFLO:  begin Rdata2 = lo; getALURResult = 32'd0; end
        MTLO:   begin lo = rdata2; getALURResult = 32'd0; end
        MULT:   begin reg64 = rdata1 * rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        MULTU:  begin reg64 = rdata1 * rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        DIV:    begin reg64 = rdata1 / rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        DIVU:   begin reg64 = rdata1 / rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        default getALURResult = 32'd0;
      endcase // case (Funct)
   endfunction

   function [31:0] getALUIResult (input[5:0] opc, input[31:0] rdata1, rdata2, ed32);
      begin
         rec2 = rdata1;
         rec3 = ed32;
         case(opc)
           // Immediate Arithmetic Instrunctions
           ADDI:   begin getALUIResult = rdata1 + ed32; rec1 = rdata1 + ed32; end
           ADDIU:  getALUIResult = rdata1 + ed32;
           SLTI:   getALUIResult = rdata1 < ed32;
           SLTIU:  getALUIResult = rdata1 < ed32;
           ANDI:   getALUIResult = rdata1 & ed32;
           ORI:    getALUIResult = rdata1 | ed32;
           XORI:   getALUIResult = rdata1 ^ ed32;
           // Branch Instructions
           BLTZ:   getALUIResult = (rdata2 == 32'd1) ? rdata1 < 0 : rdata1 >= 0;
           //BGEZ:   getALUIResult = rdata1 >= 0;
           BEQ:    getALUIResult = rdata1 == rdata2;
           BNE:    getALUIResult = rdata1 != rdata2;
           BLEZ:   getALUIResult = rdata1 <= 0;
           BGTZ:   getALUIResult = rdata1 > 0;
           // Load and Store
           LW:     getALUIResult = rdata1 + ed32;
           SW:     getALUIResult = rdata1 + ed32;
           default getALUIResult = 32'd0;
         endcase // case (Opcode)
      end
   endfunction

   function [31:0] getMUX5IJResult (input[5:0] opc, input[31:0] ins, ed32, nextpc, result);
      begin
         case(opc)
           J:      begin jadr = (ins[25:0] << 2); getMUX5IJResult = {nextpc[31:28], jadr}; end
           JAL:    begin jadr = (ins[25:0] << 2); getMUX5IJResult = {nextpc[31:28], jadr}; end

           BLTZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BGEZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BEQ:    begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BNE:    begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; result = 32'd0; end
           BLEZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; result = 32'd0; end
           BGTZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; result = 32'd0; end
           default getMUX5IJResult = nextpc;
         endcase // case (Opcode)
      end
   endfunction

   function [31:0] getMUX5RResult (input[5:0] fct, input[31:0] rdata1, nextpc);
      begin
         case(fct)
           JR:     getMUX5RResult = Rdata1;
           JALR:   getMUX5RResult = Rdata1;
           default getMUX5RResult = nextPC;
         endcase
      end
   endfunction

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];

   assign rec4 = Rdata1;
   assign rec5 = Ed32;
   
   //assign MUX2Result = (Opcode == 6'h00) ? Rdata2 : Ed32;
   assign Result = (Opcode == 6'h00) ? getALURResult(Funct, Rdata1, Rdata2) : getALUIResult(Opcode, Rdata2, Rdata1, Ed32);
   assign newPC = (Opcode == 6'h00) ? getMUX5RResult(Funct, Rdata1, nextPC) : getMUX5IJResult(Opcode, Ins, Ed32, nextPC, Result);
endmodule
