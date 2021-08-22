module LCD(input         CLK, RST,
           input [4:0]   SLCT,
           input [31:0]  Rdata1, Rdata2, Ed32, Wdata, nextPC, Rslt, Ins,
           output [31:0] Result);

   function [31:0] selectDisplay(input[4:0]   slct,
                                 input [31:0] rdata1, rdata2, ed32, wdata, nextpc, rslt);
      case(slct)
        5'b00001: selectDisplay = rslt[31:16];
        5'b00010: selectDisplay = rdata1;
        5'b00100: selectDisplay = rdata2;
        5'b01000: selectDisplay = wdata;
        5'b10000: selectDisplay = nextpc;
        5'b00011: selectDisplay = ed32;
        5'd00101: selectDisplay = rdata2 << 32'd1;
        5'b00110: selectDisplay = Ins[31:26];
        5'd01001: selectDisplay = 32'd1 << 32'd1;
        5'b01100: selectDisplay = Ins[5:0];
        5'b00111: selectDisplay = Ins[25:21];
        5'b01110: selectDisplay = Ins[20:16];
        5'b11100: selectDisplay = Ins[10:6];
        5'b01111: selectDisplay = Ins[15:0];
        5'b11110: selectDisplay = Ins[31:16];
        default   selectDisplay = rslt;
      endcase
   endfunction

   assign Result = selectDisplay(SLCT, Rdata1, Rdata2, Ed32, Wdata, nextPC, Rslt);
endmodule
