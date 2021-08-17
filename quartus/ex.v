module EX(
          input wire         CLK, RST,
          input wire [31:0]  nextPC, Ins,
          input wire [31:0]  Rdata1, Rdata2, Ed32,
          output wire [31:0] Result, newPC
);
`include "common_param.vh"

   reg [31:0]               lo, hi;
   reg [63:0]               reg64;

   wire [5:0]               Opcode, Funct;
   wire [4:0]               Shamt;

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];
   assign Shamt = Ins[10:6];
   
   always @(posedge CLK) begin
      // Mult & Div
      if (Opcode == 6'h00) begin
         case (Funct)
           MTHI:   hi = Rdata2;
           MTLO:   lo = Rdata2;
           MULT:   begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
           MULTU:  begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
           DIV:    begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
           DIVU:   begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; end
         endcase // case (Ins[5:0])
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
           SLL:    getALURResult = rdata2 << shamt;
           SRL:    getALURResult = rdata2 >> shamt;
           // TODO: research how to do on arithmetic shift
           SRA:    getALURResult = rdata1 >> rdata2;
           SLLV:   getALURResult = rdata1 << rdata2;
           SRLV:   getALURResult = rdata1 >> rdata2;
           SRAV:   getALURResult = rdata1 >> rdata2;
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
           J:      begin jadr = (ins[25:0] << 2); pc = (nextpc-4); getMUX5IJResult = {pc[31:28], jadr}; end
           JAL:    begin jadr = (ins[25:0] << 2); pc = (nextpc-4); getMUX5IJResult = {pc[31:28], jadr}; end

           BLTZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
           //BGEZ:   begin getMUX5IJResult = (result) ? nextpc + (ed32 << 2) : nextpc; end
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
           JR:     getMUX5RResult = rdata1;
           JALR:   getMUX5RResult = rdata1;
           default getMUX5RResult = nextpc;
         endcase // case (fct)
      end
   endfunction
   
   //assign MUX2Result = (Opcode == 6'h00) ? Rdata2 : Ed32;
   assign Result = (Opcode == 6'h00) ? getALURResult(Funct, Rdata1, Rdata2, Shamt) : getALUIResult(Opcode, Rdata1, Rdata2, Ed32);
   assign newPC = (Opcode == 6'h00) ? getMUX5RResult(Funct, Rdata1, nextPC) : getMUX5IJResult(Opcode, Ins, Ed32, nextPC, Result);
   //assign newPC = nextPC;
endmodule


module EX_(
          input         CLK, RST,
          input [31:0]  nextPC, Ins,
          input [31:0]  Rdata1, Rdata2, Ed32,
          output reg [31:0] Result, newPC
);
`include "common_param.vh"

   reg [31:0]               lo, hi;
   reg [64:0]               reg64;
   reg [27:0]               jadr;

   //wire [5:0]               Opcode, Funct, Shamt;
   //assign Opcode = Ins[31:26];
   //assign Funct = Ins[5:0];
   //assign Shamt = Ins[10:6];
   always @(*) begin
      if (Ins[31:26] == 6'h00) begin
         case(Ins[5:0])
           ADD:    Result = Rdata1 + Rdata2;
           ADDU:   Result = Rdata1 + Rdata2;
           SUB:    Result = Rdata1 - Rdata2;
           SUBU:   Result = Rdata1 - Rdata2;
           AND:    Result = Rdata1 & Rdata2;
           OR:     Result = Rdata1 | Rdata2;
           XOR:    Result = Rdata1 ^ Rdata2;
           NOR:    Result = ~(Rdata1 | Rdata2);
           SLT:    Result = Rdata1 < Rdata2;
           SLTU:   Result = Rdata1 < Rdata2;
           // Shift Op
           SLL:    Result = Rdata2 << Ins[10:6];
           SRL:    Result = Rdata2 >> Ins[10:6];
           // TODO: research how to do on arithmetic shift
           SRA:    Result = Rdata1 >> Rdata2;
           SLLV:   Result = Rdata1 << Rdata2;
           SRLV:   Result = Rdata1 >> Rdata2;
           SRAV:   Result = Rdata1 >> Rdata2;
           // Mult & Div
           //MFHI:  begin Rdata2 = hi; Result = 32'd0; end
           MTHI:   begin hi = Rdata2; Result = 32'd0; end
           //MFLO:  begin Rdata2 = lo; Result = 32'd0; end
           MTLO:   begin lo = Rdata2; Result = 32'd0; end
           MULT:   begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; Result = 32'd0; end
           MULTU:  begin reg64 = Rdata1 * Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; Result = 32'd0; end
           DIV:    begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; Result = 32'd0; end
           DIVU:   begin reg64 = Rdata1 / Rdata2; hi = reg64[63:32]; lo = reg64[31:0]; Result = 32'd0; end
           default Result = 32'd0;
         endcase
      end else begin
         case(Ins[31:26])
           // Immediate Arithmetic Instrunctions
           ADDI:   Result = Rdata1 + Ed32;
           ADDIU:  Result = Rdata1 + Ed32;
           SLTI:   Result = Rdata1 < Ed32;
           SLTIU:  Result = Rdata1 < Ed32;
           ANDI:   Result = Rdata1 & Ed32;
           ORI:    Result = Rdata1 | Ed32;
           XORI:   Result = Rdata1 ^ Ed32;
           // Branch Instructions
           BLTZ:   Result = (Rdata2 == 32'd1) ? Rdata1 < 0 : Rdata1 >= 0;
           //BGEZ:   Result = Rdata1 >= 0;
           BEQ:    Result = Rdata1 == Rdata2;
           BNE:    Result = Rdata1 != Rdata2;
           BLEZ:   Result = Rdata1 <= 0;
           BGTZ:   Result = Rdata1 > 0;
           // Load and Store
           LW:     Result = Rdata1 + Ed32;
           SW:     Result = Rdata1 + Ed32;
           default Result = 32'd0;
         endcase
      end
   end // always @ (*)

   always @(*) begin
      if (Ins[31:26] == 6'h00) begin
         case(Ins[5:0])
           J:      begin jadr = (Ins[25:0] << 2); newPC = {nextPC[31:28], jadr}; end
           JAL:    begin jadr = (Ins[25:0] << 2); newPC = {nextPC[31:28], jadr}; end

           BLTZ:   begin newPC = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BGEZ:   begin newPC = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BEQ:    begin newPC = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BNE:    begin newPC = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BLEZ:   begin newPC = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           BGTZ:   begin newPC = (Result) ? nextPC + (Ed32 << 2) : nextPC; end
           default newPC = nextPC;
         endcase // case (Opcode)
      end else begin
         case(Ins[31:26])
           JR:     newPC = Rdata1;
           JALR:   newPC = Rdata1;
           default newPC = nextPC;
         endcase
      end // else: !if(Ins[31:26] == 6'h00)
   end
endmodule // EX_


module EX2 (
          input wire         CLK, RST,
          input wire [31:0]  nextPC, Ins,
          input wire [31:0]  Rdata1, Rdata2, Ed32,
          output wire [31:0] Result, newPC
);
`include "common_param.vh"

   reg [31:0]               lo, hi;
   reg [63:0]               reg64;

   wire [5:0]               Opcode, Funct;
   wire [4:0]               Shamt;

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];
   assign Shamt = Ins[10:6];

   function [31:0] getALUResult(
                                input [5:0]  opc, opcOrFct,
                                input [31:0] rdata1, rdata2, ed32,
                                input [4:0]  shamt);
      case (opcOrFct)
        SLL:    getALUResult = (opc == R_FORM) ? rdata2 << shamt : ((rdata2 == 32'd1) ? {31'b0, (rdata1 < 0)} : {31'b0, (rdata1 >= 0)}); // 0x00
        SRL:    getALUResult = rdata2 >> shamt;  // 0x02
        SRA:    getALUResult = rdata1 >> rdata2; // 0x03
        SLLV:   getALUResult = (opc == R_FORM) ? rdata1 << rdata2 : {31'b0, (rdata1 == rdata2)}; // 0x04
        BNE:    getALUResult = {31'b0, (rdata1 != rdata2)}; // 0x05
        SRLV:   getALUResult = (opc == R_FORM) ? rdata1 >> rdata2 : {31'b0, (rdata1 <= 0)}; // 0x06
        SRAV:   getALUResult = (opc == R_FORM) ? rdata1 >> rdata2 : {31'b0, (rdata1 > 0)};// 0x07
        ADDI:   getALUResult = rdata1 + ed32; // 0x08
        ADDIU:  getALUResult = $unsigned(rdata1) + $unsigned(ed32); //0x09
        SLTI:   getALUResult = {31'b0, (rdata1 < ed32)}; //0x0a
        SLTIU:  getALUResult = {31'b0, ($unsigned(rdata1) < $unsigned(ed32))}; // 0x0b
        ANDI:   getALUResult = rdata1 & ed32; // 0x0c
        ORI:    getALUResult = rdata1 | ed32; // 0x0d
        XORI:   getALUResult = rdata1 ^ ed32; // 0x0e
        MFHI:   getALUResult = hi; // 0x10
        MFLO:   getALUResult = lo; // 0x12
        ADD:    getALUResult = rdata1 + rdata2; // 0x20
        ADDU:   getALUResult = $unsigned(rdata1) + $unsigned(rdata2); // 0x21
        SUB:    getALUResult = rdata1 - rdata2; // 0x22
        SUBU:   getALUResult = (opc == R_FORM) ? $unsigned(rdata1) - $unsigned(rdata2) : rdata1 + ed32; // 0x23
        AND:    getALUResult = rdata1 & rdata2; // 0x24
        OR:     getALUResult = rdata1 | rdata2; // 0x25
        XOR:    getALUResult = rdata1 ^ rdata2; // 0x26
        NOR:    getALUResult = ~(rdata1 | rdata2); // 0x27
        SLT:    getALUResult = {31'b0, (rdata1 < rdata2)}; // 0x2a
        SLTU:   getALUResult = (opc == R_FORM) ? {31'b0, ($unsigned(rdata1) < $unsigned(rdata2))} : rdata1 + ed32; // 0x2b
        default getALUResult = 32'd0;
        //BGEZ:   getALUIResult = rdata1 >= 0;
      endcase
   endfunction

   reg [31:0] pc;
   reg [27:0] jadr;
   function [31:0] getMUX5Result (input[5:0] opc, fct, input[31:0] ins, rdata1, ed32, nextpc, result);
      begin
         if (opc == J || opc == JAL) begin
            jadr = (ins[25:0] << 2);
            pc = (nextpc-4);
            getMUX5Result = {pc[31:28], jadr};
         end else if (fct == JR || fct == JALR) begin
            getMUX5Result = rdata1;
         end else if (BLTZ <= opc && opc <= BGTZ) begin
            getMUX5Result = (result) ? nextpc + (ed32 << 2) : nextpc;
         end else begin
            getMUX5Result = nextpc;
         end
      end
   endfunction

   assign Result = (Opcode == R_FORM) ? getALUResult(Opcode, Funct, Rdata1, Rdata2, Ed32, Shamt) : getALUResult(Opcode, Opcode, Rdata1, Rdata2, Ed32, Shamt);
   assign newPC = getMUX5Result(Opcode, Funct, Ins, Rdata1, Ed32, nextPC, Result);

endmodule
