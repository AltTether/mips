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

   reg [5:0]                Opcode, Funct;

   // Instructions for RType
   function [31:0] getALURResult (input[6:0] Funct);
      case(Funct)
        ADD:   getALURResult = Rdata1 + Rdata2;
        ADDU:  getALURResult = Rdata1 + Rdata2;
        SUB:   getALURResult = Rdata1 - Rdata2;
        SUBU:  getALURResult = Rdata1 - Rdata2;
        AND:   getALURResult = Rdata1 & Rdata2;
        OR:    getALURResult = Rdata1 | Rdata2;
        XOR:   getALURResult = Rdata1 ^ Rdata2;
        NOR:   getALURResult = ~(Rdata1 | Rdata2);
        SLT:   getALURResult = Rdata1 < Rdata2;
        SLTU:  getALURResult = Rdata1 < Rdata2;
        // Shift Op
        SLL:   getALURResult = Rdata1 << Rdata2;
        SRL:   getALURResult = Rdata1 >> Rdata2;
        // TODO: research how to do on arithmetic shift
        SRA:   getALURResult = Rdata1 >> Rdata2;
        SLLV:  getALURResult = Rdata1 << Rdata2;
        SRLV:  getALURResult = Rdata1 >> Rdata2;
        SRAV:  getALURResult = Rdata1 >> Rdata2;
        // Mult & Div
        MFHI:  hi = Rdata2;
        MTHI:  hi = Rdata2;
        MFLO:  lo = Rdata2;
        MTLO:  lo = Rdata2;
        MULT:  begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
        MULTU: begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
        DIV:   begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
        DIVU:  begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
      endcase // case (Funct)
   endfunction

   function [31:0] getALUIResult (input[5:0] Opcode);
     case(Opcode)
       // Immediate Arithmetic Instrunctions
       ADDI:   getALUIResult = Rdata1 + Ed32;
       ADDIU:  getALUIResult = Rdata1 + Ed32;
       SLTI:   getALUIResult = Rdata1 < Ed32;
       SLTIU:  getALUIResult = Rdata1 < Ed32;
       ANDI:   getALUIResult = Rdata1 & Ed32;
       ORI:    getALUIResult = Rdata1 | Ed32;
       XORI:   getALUIResult = Rdata1 ^ Ed32;
       default getALUIResult = 32'd0;
     endcase // case (Opcode)
   endfunction

   function [31:0] getMUX5IJResult (input[5:0] Opcode);
      begin
         case(Opcode)
           J:      begin jadr = (Ins[25:0] << 2); getMUX5IJResult = {nextPC[31:28], jadr}; end
           JAL:    begin jadr = (Ins[25:0] << 2); getMUX5IJResult = {nextPC[31:28], jadr}; end
           default getMUX5IJResult = nextPC;
         endcase // case (Opcode)
      end
   endfunction

   function [31:0] getMUX5RResult (input[5:0] Fct);
      begin
         case(Fct)
           JR:     getMUX5RResult = Rdata1;
           JALR:   getMUX5RResult = Rdata1;
           default getMUX5RResult = nextPC;
         endcase
      end
   endfunction

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];

   //assign MUX2Result = (Opcode == 6'h00) ? Rdata2 : Ed32;
   assign Result = (Opcode == 6'h00) ? getALURResult(Funct) : getALUIResult(Opcode);
   assign newPC = (Opcode == 6'h00) ? getMUX5RResult(Funct) : getMUX5IJResult(Opcode);
endmodule
