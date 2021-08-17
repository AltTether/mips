module SEG7DEC(input [3:0]  DIN,
               input        DOT,
               output reg [7:0] nHEX);
   always @(*) begin
      case(DIN)
        0:  nHEX = 8'b11000000;
        1:  nHEX = 8'b11111001;
        2:  nHEX = 8'b10100100;
        3:  nHEX = 8'b10110000;
        4:  nHEX = 8'b10011001;
        5:  nHEX = 8'b10010010;
        6:  nHEX = 8'b10000011;
        7:  nHEX = 8'b11011000;
        8:  nHEX = 8'b10000000;
        9:  nHEX = 8'b10010000;
        10: nHEX = 8'b10001000;
        11: nHEX = 8'b10000011;
        12: nHEX = 8'b11000110;
        13: nHEX = 8'b10100001;
        14: nHEX = 8'b10000110;
        15: nHEX = 8'b10001110;
      endcase // case (DIN)
   
      if (DOT) nHEX = nHEX & 8'b01111111;
   end

endmodule
