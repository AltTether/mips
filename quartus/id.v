module ID(
          input wire         CLK, RST,
          input wire [31:0]  Ins, Wdata,
          output wire [31:0] Rdata1, Rdata2, Ed32);
`include "common_param.vh"

   reg [31:0]           RegFile [0:REGFILE_SIZE-1];

   wire [4:0]           Wadr;
   wire [31:0]          Opcode, Funct;

   integer              i;
   
   initial begin
     for (i = 0; i < REGFILE_SIZE; i = i + 1) begin
        RegFile[i] <= 32'd0;
     end
   end

   assign Opcode = Ins[31:26];
   assign Funct = Ins[5:0];

   always @(posedge CLK) begin
      if (RST) begin
         for (i = 0; i < REGFILE_SIZE; i = i + 1) RegFile[i] <= 32'd0;
      end else if ((BGTZ < Opcode || Opcode == JAL || Opcode == R_FORM) && Opcode != SW && Funct != JR) begin
        RegFile[Wadr] <= Wdata;
      end
   end

   function [4:0] getMUX1Result(input[5:0] opc);
      if (opc == R_FORM) getMUX1Result = Ins[15:11];
      else if (opc == JAL) getMUX1Result = 5'b11111;
      else getMUX1Result = Ins[20:16];
   endfunction

   assign Wadr = getMUX1Result(Opcode);
   assign Rdata1 = RegFile[Ins[25:21]];
   assign Rdata2 = RegFile[Ins[20:16]];
   assign Ed32 = (Ins[31:26] <= ADDI && XORI >= Ins[31:26]) ? {16'd0, Ins[15:0]} : {{16{Ins[15]}}, Ins[15:0]};

endmodule
