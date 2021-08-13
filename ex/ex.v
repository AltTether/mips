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
   reg [31:0]               rec1, rec2, rec3;

   reg [5:0]                Opcode, Funct;

   // Instructions for RType
   function [31:0] getALURResult (input[6:0] Funct);
      case(Funct)
        ADD:    getALURResult = Rdata1 + Rdata2;
        ADDU:   getALURResult = Rdata1 + Rdata2;
        SUB:    getALURResult = Rdata1 - Rdata2;
        SUBU:   getALURResult = Rdata1 - Rdata2;
        AND:    getALURResult = Rdata1 & Rdata2;
        OR:     getALURResult = Rdata1 | Rdata2;
        XOR:    getALURResult = Rdata1 ^ Rdata2;
        NOR:    getALURResult = ~(Rdata1 | Rdata2);
        SLT:    getALURResult = Rdata1 < Rdata2;
        SLTU:   getALURResult = Rdata1 < Rdata2;
        // Shift Op
        SLL:    getALURResult = Rdata1 << Rdata2;
        SRL:    getALURResult = Rdata1 >> Rdata2;
        // TODO: research how to do on arithmetic shift
        SRA:    getALURResult = Rdata1 >> Rdata2;
        SLLV:   getALURResult = Rdata1 << Rdata2;
        SRLV:   getALURResult = Rdata1 >> Rdata2;
        SRAV:   getALURResult = Rdata1 >> Rdata2;
        // Mult & Div
        //MFHI:  begin Rdata2 = hi; getALURResult = 32'd0; end
        MTHI:   begin hi = Rdata2; getALURResult = 32'd0; end
        //MFLO:  begin Rdata2 = lo; getALURResult = 32'd0; end
        MTLO:   begin lo = Rdata2; getALURResult = 32'd0; end
        MULT:   begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        MULTU:  begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        DIV:    begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        DIVU:   begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; getALURResult = 32'd0; end
        default getALURResult = 32'd0;
      endcase // case (Funct)
   endfunction

   function [31:0] getALUIResult (input[5:0] Opcode);
      begin
         case(Opcode)
           // Immediate Arithmetic Instrunctions
           ADDI:   getALUIResult = Rdata1 + Ed32;
           ADDIU:  getALUIResult = Rdata1 + Ed32;
           SLTI:   getALUIResult = Rdata1 < Ed32;
           SLTIU:  getALUIResult = Rdata1 < Ed32;
           ANDI:   getALUIResult = Rdata1 & Ed32;
           ORI:    getALUIResult = Rdata1 | Ed32;
           XORI:   getALUIResult = Rdata1 ^ Ed32;
           // Branch Instructions
           BLTZ:   getALUIResult = (Rdata2 == 32'd1) ? Rdata1 < 0 : Rdata1 >= 0;
           //BGEZ:   getALUIResult = Rdata1 >= 0;
           BEQ:    getALUIResult = Rdata1 == Rdata2;
           BNE:    getALUIResult = Rdata1 != Rdata2;
           BLEZ:   getALUIResult = Rdata1 <= 0;
           BGTZ:   getALUIResult = Rdata1 > 0;
           default getALUIResult = 32'd0;
         endcase // case (Opcode)
      end
   endfunction

   function [31:0] getMUX5IJResult (input[5:0] Opcode);
      begin
         case(Opcode)
           J:      begin jadr = (Ins[25:0] << 2); getMUX5IJResult = {nextPC[31:28], jadr}; end
           JAL:    begin jadr = (Ins[25:0] << 2); getMUX5IJResult = {nextPC[31:28], jadr}; end

           BLTZ:   begin getMUX5IJResult = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BGEZ:   begin getMUX5IJResult = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BEQ:    begin getMUX5IJResult = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BNE:    begin getMUX5IJResult = (Result) ? nextPC + (Ed32 << 2) : nextPC; Result = 32'd0; end
           BLEZ:   begin getMUX5IJResult = (Result) ? nextPC + (Ed32 << 2) : nextPC; Result = 32'd0; end
           BGTZ:   begin getMUX5IJResult = (Result) ? nextPC + (Ed32 << 2) : nextPC; Result = 32'd0; end
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
