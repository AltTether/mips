module EX(
          input wire         CLK, RST,
          input wire [31:0]  nextPC, Ins,
          input wire [31:0]  Rdata1, Rdata2, Ed32,
          output wire [31:0] Result, newPC,
          output reg [31:0] rec
);
`include "common_param.vh"

   reg [31:0]               lo, hi;

   wire [5:0]               Opcode, Funct;
   wire [4:0]               Shamt;
   wire [63:0]              reg64;

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];
   assign Shamt = Ins[10:6];

   function [63:0] mulAndDiv(input[5:0] fct, input[31:0] rdata1, rdata2);  begin
      case (fct)
        MULT:    mulAndDiv = Rdata1 * Rdata2;
        MULTU:   mulAndDiv = Rdata1 * Rdata2;
        DIV:     mulAndDiv = Rdata1 / Rdata2;
        DIVU:    mulAndDiv = Rdata1 / Rdata2;
        default: mulAndDiv = 64'd0;
      endcase
   end
   endfunction

   assign reg64 = mulAndDiv(Funct, Rdata1, Rdata2);
   always @(posedge CLK) begin
      if (RST) begin
         hi <= 32'd0;
         lo <= 32'd0;
      // Mult & Div
      end else if (Opcode == 6'h00) begin
         case (Funct)
           MTHI:   begin hi <= Rdata2; lo <= lo; end
           MTLO:   begin hi <= hi; lo = Rdata2; end
           MULT:   begin hi <= reg64[63:32]; lo <= reg64[31:0]; end
           MULTU:   begin hi <= reg64[63:32]; lo <= reg64[31:0]; end
           DIV:   begin hi <= reg64[63:32]; lo <= reg64[31:0]; end
           DIVU:   begin hi <= reg64[63:32]; lo <= reg64[31:0]; end
           default: begin hi <= hi; lo <= lo; end
         endcase
      end
   end

   // Instructions for RType
   function [31:0] getALURResult (input[5:0] fct, input[31:0] rdata1, rdata2, input[4:0] shamt);
      begin
         case(fct)
           ADD:    getALURResult = rdata1 + rdata2;
           ADDU:   getALURResult = rdata1 + rdata2;
           SUB:    getALURResult = rdata1 - rdata2;
           SUBU:   getALURResult = rdata1 - rdata2;
           AND:    getALURResult = rdata1 & rdata2;
           OR:     getALURResult = rdata1 | rdata2;
           XOR:    getALURResult = rdata1 ^ rdata2;
           NOR:    getALURResult = ~(rdata1 | rdata2);
           SLT:    getALURResult = {31'b0, (rdata1 < rdata2)};
           SLTU:   getALURResult = {31'b0, (rdata1 < rdata2)};
           // Shift Op
           //SLL:    getALURResult = {11'd0, (rdata2[15:0] << {11'd0, shamt}), shamt};
           SLL:    getALURResult = rdata2 << shamt;//{16'd2 << 2, 16'd8 << 1};
           SRL:    getALURResult = rdata2 >> shamt;
           // TODO: research how to do on arithmetic shift
           SRA:    getALURResult = rdata1 >>> rdata2;
           SLLV:   getALURResult = rdata1 << rdata2;
           SRLV:   getALURResult = rdata1 >> rdata2;
           SRAV:   getALURResult = rdata1 >>> rdata2;
           MFHI:   getALURResult = hi;
           MFLO:   getALURResult = lo;
           default getALURResult = 32'd0;
         endcase // case (Funct)
      end
   endfunction // getALURResult

   function [31:0] getALUIResult (input[5:0] opc, input[31:0] rdata1, rdata2, ed32);
      begin
         case(opc)
           // Immediate Arithmetic Instrunctions
           ADDI:   getALUIResult = rdata1 + ed32;
           ADDIU:  getALUIResult = rdata1 + ed32;
           SLTI:   getALUIResult = {31'b0, (rdata1 < ed32)};
           SLTIU:  getALUIResult = {31'b0, (rdata1 < ed32)};
           ANDI:   getALUIResult = rdata1 & ed32;
           ORI:    getALUIResult = rdata1 | ed32;
           XORI:   getALUIResult = rdata1 ^ ed32;
           // Branch Instructions
           BLTZ:   getALUIResult = (rdata2 == 32'd1) ? {31'b0, (rdata1 < 0)} : {31'b0, (rdata1 >= 0)};
           //BGEZ:   getALUIResult = rdata1 >= 0;
           BEQ:    getALUIResult = {31'b0, (rdata1 == rdata2)};
           BNE:    getALUIResult = {31'b0, (rdata1 != rdata2)};
           BLEZ:   getALUIResult = {31'b0, (rdata1 <= 0)};
           BGTZ:   getALUIResult = {31'b0, (rdata1 > 0)};
           // Load and Store
           LW:     getALUIResult = rdata1 + ed32;
           SW:     getALUIResult = rdata1 + ed32;
           default getALUIResult = 32'd0;
         endcase // case (Opcode)
      end
   endfunction

   reg [31:0] pc;
   reg [27:0] jadr;
   function [31:0] getMUX5IJResult (input[5:0] opc, input[31:0] ins, ed32, nextpc, result);
      begin
         case(opc)
           J:      begin jadr = (ins[25:0] << 2); pc = nextpc - 4; getMUX5IJResult = {pc[31:28], jadr}; end
           JAL:    begin jadr = (ins[25:0] << 2); pc = nextpc - 4; getMUX5IJResult = {pc[31:28], jadr}; end

           BLTZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           //BGEZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BEQ:    begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BNE:    begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BLEZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           BGTZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           default getMUX5IJResult = nextpc;
         endcase
      end
   endfunction

   function [31:0] getMUX5RResult (input[5:0] fct, input[31:0] rdata1, nextpc);
      begin
         case(fct)
           JR:     getMUX5RResult = rdata1;
           JALR:   getMUX5RResult = rdata1;
           default getMUX5RResult = nextpc;
         endcase // case (fct)
      end
   endfunction
   
   //assign MUX2Result = (Opcode == 6'h00) ? Rdata2 : Ed32;
   assign Result = (Opcode == 6'h00) ? getALURResult(Funct, Rdata1, Rdata2, Shamt) : ((Opcode == JAL) ? nextPC : getALUIResult(Opcode, Rdata1, Rdata2, Ed32));
   assign newPC = (Opcode == 6'h00) ? getMUX5RResult(Funct, Rdata1, nextPC) : getMUX5IJResult(Opcode, Ins, Ed32, nextPC, Result);
   //assign newPC = nextPC;
endmodule
