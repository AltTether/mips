module LCD(input         CLK, RST,
           input [4:0]   SLCT,
           input [31:0]  Rdata1, Rdata2, Wdata, nextPC, Rslt,
           input [2:0]   BOUT,
           output [31:0] Result);

   function [31:0] selectDisplay(input[4:0]   slct,
                                 input [31:0] rdata1, rdata2, wdata, nextpc, rslt,
                                 input [2:0]  bout);
      case(slct)
        5'b00010: selectDisplay = rdata1;
        5'b00100: selectDisplay = rdata2;
        5'b01000: selectDisplay = wdata;
        5'b10000: selectDisplay = nextpc;
        5'b01110: selectDisplay = {29'b0, bout};
        default   selectDisplay = rslt;
      endcase
   endfunction

   assign Result = selectDisplay(SLCT, Rdata1, Rdata2, Wdata, nextPC, Rslt, BOUT);
endmodule