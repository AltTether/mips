module ID(
          input         CLK, RST,
          input [1:0]   BOUT,
          input [31:0]  Ins, Wdata,
          output [31:0] Rdata1, Rdata2, Ed32
);
`include "common_param.vh"

   reg [31:0]               RegFile [0:REGFILE_SIZE-1];
   
   wire [5:0]               Opcode, Funct;
   wire [4:0]               Wadr;

   integer                  i;
   
   
   initial begin
     for (i = 0; i < REGFILE_SIZE; i = i + 1) RegFile[i] = 32'd0;
   end

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];

   always @(posedge CLK) begin
      if (RST) begin
         for (i = 0; i < REGFILE_SIZE; i = i + 1) RegFile[i] <= 32'd0;
      end else if(Ins == 32'd0) begin
         ;
      end else if (Opcode == R_FORM && Funct&& (BOUT[0] || BOUT[1])) begin
         RegFile[Wadr] <= Wdata;
      end else if ((Opcode == ADDI || Opcode == LW || Opcode == SLTI || Opcode == SLT || Opcode == JAL) && (BOUT[0] || BOUT[1])) begin
         RegFile[Wadr] <= Wdata;
      end else ;
   end

   function [4:0] getAddr(input[5:0] opc, input[31:0] ins);
      if (opc == R_FORM) getAddr = ins[15:11];
      else if (opc == JAL) getAddr = 5'b11111;
      else getAddr = ins[20:16];
   endfunction // getAddr

   function [31:0] getUESE(input[5:0] opc, input[31:0] ins);
      case(opc)
        ADDI, ADDIU, SLTI, SLTIU: getUESE = {{16{Ins[15]}}, Ins[15:0]};
        default getUESE = {16'd0, Ins[15:0]};
      endcase
   endfunction

   assign Wadr = getAddr(Opcode, Ins);
   assign Rdata1 = RegFile[Ins[25:21]];
   assign Rdata2 = RegFile[Ins[20:16]];
   assign Ed32 = getUESE(Opcode, Ins);
   
endmodule
