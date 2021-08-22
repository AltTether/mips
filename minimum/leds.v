module LEDS (
             input        CLK, RST,
             input [4:0]  SLCT,
             output [4:0] LEDR);
   function [4:0] decode (input[4:0] slct);
      case(SLCT)
        5'b00010: decode = 5'b00010;
        5'b00100: decode = 5'b00100;
        5'b01000: decode = 5'b01000;
        5'b10000: decode = 5'b10000;
        default   decode = 5'b00001;
      endcase
   endfunction // decode

   assign LEDR = decode(SLCT);
endmodule
