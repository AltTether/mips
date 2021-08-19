module ID(
          input         CLK, RST,
          input [31:0]  Ins, Wdata,
          output [31:0] Rdata1, Rdata2, Ed32
);
`include "common_param.vh"

   reg [31:0]               RegFile [0:REGFILE_SIZE-1];
   
   wire [5:0]                Opcode, Funct;
   wire [4:0]                Wadr;
   wire [4:0]                Radr1, Radr2;

   integer                  i;
   
   initial begin
     for (i = 0; i < REGFILE_SIZE; i = i + 1) RegFile[i] = 32'd0;
   end

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];

   always @(posedge CLK) begin
      if (RST) begin
         for (i = 0; i < REGFILE_SIZE; i = i + 1) RegFile[i] <= 32'd0;
      end else if (Opcode == R_FORM && Funct != JR) begin
         RegFile[Wadr] <= Wdata;
      end else if ((BGTZ < Opcode || Opcode == JAL) && Opcode != SW) begin
         RegFile[Wadr] <= Wdata;
      end else if (Opcode == R_FORM && Funct == SLL) begin
         RegFile[Wadr] <= Wdata;
      end
   end

   function [4:0] getMUX1Result(input[5:0] opc, input[31:0] ins);
      if (opc == 6'h00) getMUX1Result = ins[15:11];
      else if (opc == JAL) getMUX1Result = 5'b11111;
      else getMUX1Result = ins[20:16];
   endfunction

   assign Wadr = getMUX1Result(Opcode, Ins);

   assign Radr1 = Ins[25:21];
   assign Radr2 = Ins[20:16];
   assign Rdata1 = RegFile[Radr1];
   assign Rdata2 = RegFile[Radr2];
   assign Ed32 = (Ins[31:26] <= ADDI && XORI >= Ins[31:26]) ? {16'd0, Ins[15:0]} : {{16{Ins[15]}}, Ins[15:0]};
   
endmodule
