module EX(
          input         CLK, RST,
          input [31:0]  nextPC, Ins,
          input [31:0]  Rdata1, Rdata2, Ed32,
          output [31:0] Result, newPC
);
`include "common_param.vh"

   reg [31:0]               lo, hi;
   reg [64:0]               reg64;
   reg [27:0]               jadr;

   wire [5:0]               Opcode, Funct, Shamt;

   // Instructions for RType
   function [31:0] getALURResult (input[6:0] fct, input[31:0] rdata1, rdata2, input[4:0] shamt);
      case(fct)
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
        SLL:    getALURResult = rdata2 << shamt;
        SRL:    getALURResult = rdata2 >> shamt;
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
         case(opc)
           // Immediate Arithmetic Instrunctions
           ADDI:   getALUIResult = rdata1 + ed32;
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
   endfunction // getALUIResult

   reg [31:0] cpc;
   function [31:0] getMUX5IJResult (input[5:0] opc, input[31:0] ins, ed32, nextpc, result);
      begin
         case(opc)
           J:      begin jadr = (ins[25:0] << 2); cpc = nextpc - 4; getMUX5IJResult = {cpc[31:28], jadr}; end
           JAL:    begin jadr = (ins[25:0] << 2); cpc = nextpc - 4; getMUX5IJResult = {cpc[31:28], jadr}; end

           BLTZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BGEZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BEQ:    begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BNE:    begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BLEZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BGTZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
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
   assign Shamt = Ins[10:6];
   
   //assign MUX2Result = (Opcode == 6'h00) ? Rdata2 : Ed32;
   assign Result = (Opcode == 6'h00) ? getALURResult(Funct, Rdata1, Rdata2, Shamt) : ((Opcode == JAL) ? nextPC : getALUIResult(Opcode, Rdata1, Rdata2, Ed32));
   assign newPC = (Opcode == 6'h00) ? getMUX5RResult(Funct, Rdata1, nextPC) : getMUX5IJResult(Opcode, Ins, Ed32, nextPC, Result);
endmodule
