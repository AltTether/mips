module EX(
          input         CLK, RST,
          input [1:0]   BOUT,
          input [31:0]  nextPC, Ins,
          input [31:0]  Rdata1, Rdata2, Ed32,
          output [31:0] Result, newPC
);
`include "common_param.vh"

   reg [31:0]           lo, hi;

   wire [4:0]           rtField;
   wire [5:0]           Opcode, Funct;
   wire [31:0]          Shamt;


   assign rtField = Ins[20:16];
   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];
   assign Shamt = {27'd0, Ins[10:6]};


   always @(posedge CLK) begin
      if (RST) {hi, lo} = 64'd0;
      else if(Opcode == R_FORM && (BOUT[0] || BOUT[1]))
        case(Funct)
          MTHI:    {hi, lo} = {Rdata1, lo};
          MTLO:    {hi, lo} = {hi, Rdata1};
          MULT:    {hi, lo} = $signed(Rdata1) * $signed(Rdata2);
          MULTU:   {hi, lo} = $unsigned(Rdata1) * $unsigned(Rdata2);
          DIV:     {hi, lo} = $signed(Rdata1) / $signed(Rdata2);
          DIVU:    {hi, lo} = $unsigned(Rdata1) / $unsigned(Rdata2);
          default: {hi, lo} = {hi, lo};
        endcase
      else {hi, lo} = {hi, lo};
   end

   // Instructions for RType
   function [31:0] getALURResult (input[5:0] fct, input[31:0] rdata1, rdata2, shamt);
      case(fct)
        SLL:    getALURResult = rdata2 << shamt;
        SRL:    getALURResult = rdata2 >> shamt;
        SRA:    getALURResult = $signed(rdata2) >>> shamt;
        SLLV:   getALURResult = rdata2 << rdata1;
        SRLV:   getALURResult = rdata2 >> rdata1;
        SRAV:   getALURResult = $signed(rdata2) >>> rdata1;
        MFHI:   getALURResult = hi;
        MFLO:   getALURResult = lo;
        ADD:    getALURResult = rdata1 + rdata2;
        ADDU:   getALURResult = $unsigned(rdata1) + $unsigned(rdata2);
        SUB:    getALURResult = rdata1 - rdata2;
        SUBU:   getALURResult = $unsigned(rdata1) - $unsigned(rdata2);
        AND:    getALURResult = rdata1 & rdata2;
        OR:     getALURResult = rdata1 | rdata2;
        XOR:    getALURResult = rdata1 ^ rdata2;
        NOR:    getALURResult = ~(rdata1 | rdata2);
        SLT:    getALURResult = {31'b0, ($signed(rdata1) < $signed(rdata2))};
        SLTU:   getALURResult = {31'b0, ($unsigned(rdata1) < $unsigned(rdata2))};
        default getALURResult = 32'd0;
      endcase
   endfunction

   // Instructions for IType
   function [31:0] getALUIResult (input[5:0] opc, input[31:0] rdata1, rdata2, ed32, input[4:0] rtfield);
      case(opc)
        BLTZ,
        BGEZ:    getALUIResult = (rtfield) ? {31'b0, ($signed(rdata1) >= 0)} : {31'b0, ($signed(rdata1) < 0)};
        BEQ:     getALUIResult = {31'b0, (rdata1 == rdata2)};
        BNE:     getALUIResult = {31'b0, (rdata1 != rdata2)};
        BLEZ:    getALUIResult = {31'b0, ($signed(rdata1) <= 0)};
        BGTZ:    getALUIResult = {31'b0, ($signed(rdata1) > 0)};
        ADDI:    getALUIResult = $signed(rdata1) + $signed(ed32);
        ADDIU:   getALUIResult = $unsigned(rdata1) + $unsigned(ed32);
        SLTI:    getALUIResult = {31'b0, ($signed(rdata1) < $signed(ed32))};
        SLTIU:   getALUIResult = {31'b0, ($unsigned(rdata1) < $unsigned(ed32))};
        ANDI:    getALUIResult = rdata1 & ed32;
        ORI:     getALUIResult = rdata1 | ed32;
        XORI:    getALUIResult = rdata1 ^ ed32;
        LW:      getALUIResult = rdata1 + ed32;
        SW:      getALUIResult = rdata1 + ed32;
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
        BLTZ:   getMUX5IJResult = (result) ? beqAddr(ed32, nextpc) : nextpc;
        BEQ:    getMUX5IJResult = (result) ? beqAddr(ed32, nextpc) : nextpc;
        BNE:    getMUX5IJResult = (result) ? beqAddr(ed32, nextpc) : nextpc;
        BLEZ:   getMUX5IJResult = (result) ? beqAddr(ed32, nextpc) : nextpc;
        BGTZ:   getMUX5IJResult = (result) ? beqAddr(ed32, nextpc) : nextpc;
        default getMUX5IJResult = nextpc;
      endcase
   endfunction
   
   //assign MUX2Result = (Opcode == 6'h00) ? Rdata2 : Ed32;
   assign Result = (Opcode == R_FORM) ? getALURResult(Funct, Rdata1, Rdata2, Shamt) : getALUIResult(Opcode, Rdata1, Rdata2, Ed32, rtField);
   assign newPC = (Opcode == R_FORM) ? getMUX5RResult(Funct, Rdata1, nextPC) : getMUX5IJResult(Opcode, Ins, Ed32, nextPC, Result);

endmodule
