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
   assign {Rdata1, Rdata2} = {RegFile[Ins[25:21]], RegFile[Ins[20:16]]};

   /*
   function [31:0] getSE(input[31:0] ins);
      case(ins[15])
        1'd1: getSE = {16'd65535, ins[15:0]};
        1'd0: getSE = {16'd0, ins[15:0]};
      endcase
   endfunction
    */
   assign Ed32 = (Ins[31:26] <= ADDI && XORI >= Ins[31:26]) ? {16'd0, Ins[15:0]} : {{16{Ins[15]}}, Ins[15:0]};

endmodule


module ID_(
            input             CLK, RST,
            input [31:0]      Ins, Wdata,
            output [31:0]     Rdata1, Rdata2,
            output reg [31:0] Ed32);
`include "common_param.vh"
   reg [31:0]             RegFile [0:REGFILE_SIZE-1];
   reg [4:0]              Wadr;

   //wire [5:0]             Opcode, Funct;

   integer                i;

   initial begin
     for (i = 0; i < REGFILE_SIZE; i = i + 1) RegFile[i] = 32'd0;
   end

   always @(posedge CLK) begin
      if (RST) for (i = 0; i < REGFILE_SIZE; i = i + 1) RegFile[i] = 32'd0;
      if ((BGTZ < Ins[31:26] || Ins[31:26] == JAL || Ins[31:26] == 6'h00) && Ins[31:26] != SW && Ins[5:0] != JR) RegFile[Wadr] = Wdata;
   end

   // getMUX1Result
   always @(*) begin
      if (Ins[31:26] == 6'h00) Wadr = Ins[15:11];
      else if (Ins[31:26] == JAL) Wadr = 5'b11111;
      else Wadr = Ins[20:16];
   end

   assign Rdata1 = RegFile[Ins[25:21]];
   assign Rdata2 = RegFile[Ins[20:16]];
   //assign Rdata2 = 32'd0;

   // UE/SE
   always @(*) begin
      if (Ins[31:26] < ADDI && XORI > Ins[31:26]) Ed32 = {16'd0, Ins[15:0]};
      else Ed32 = (Ins[15]) ? {16'd65535, Ins[15:0]} : {16'd0, Ins[15:0]};
   end

endmodule
