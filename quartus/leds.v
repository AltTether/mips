module LEDS (input            CLK, RST,
             input [4:0]      SLCT,
             output reg [4:0] LEDR);
   always @(*) begin
      case(SLCT)
        5'b00010: LEDR = 5'b00010;
        5'b00100: LEDR = 5'b00100;
        5'b01000: LEDR = 5'b01000;
        5'b10000: LEDR = 5'b10000;
        default   LEDR = 5'b00001;
      endcase
   end
endmodule
