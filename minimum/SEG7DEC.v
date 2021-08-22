module SEG7DEC(input [3:0]  DIN,
               input        DOT,
               output [7:0] nHEX);

   function [7:0] decode (input [3:0] din);
      case(DIN)
        0:  decode = 8'b11000000;
        1:  decode = 8'b11111001;
        2:  decode = 8'b10100100;
        3:  decode = 8'b10110000;
        4:  decode = 8'b10011001;
        5:  decode = 8'b10010010;
        6:  decode = 8'b10000011;
        7:  decode = 8'b11011000;
        8:  decode = 8'b10000000;
        9:  decode = 8'b10010000;
        10: decode = 8'b10001000;
        11: decode = 8'b10000011;
        12: decode = 8'b11000110;
        13: decode = 8'b10100001;
        14: decode = 8'b10000110;
        15: decode = 8'b10001110;
      endcase // case (DIN)
   endfunction

   assign nHEX = (DOT) ? decode(DIN) & 8'b01111111 : decode(DIN);

endmodule
