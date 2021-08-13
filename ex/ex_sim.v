`timescale 1 ps/ 1 ps


module ex_sim();
parameter PERIOD=10000;  // (clock period)/2

// constants
// general purpose registers
   reg clk, rst;
   reg [31:0] rdata1, rdata2, ed32;
   reg [31:0] nextpc, ins;

// wires
   wire [31:0] newpc;
   wire [31:0] result;

// assign statements (if any)
EX ex1 (
// port map - connection between master ports and signals/registers
        .CLK(clk),
        .RST(rst),
        .nextPC(nextpc),
        .newPC(newpc),
        .Ins(ins),
        .Rdata1(rdata1),
        .Rdata2(rdata2),
        .Ed32(ed32),
        .Result(result)
);

initial
  begin
     // ADD
     clk=#(PERIOD) 1'd1; rst=1'd0;
     nextpc=32'd0;
     ins={6'h00, 20'd0, 6'h20};
     rdata1=32'd1; rdata2=32'd1; ed32=32'd0;

     // ADDU
     ins=#(PERIOD) {6'h00, 20'd0, 6'h21};
     rdata1=32'd1; rdata2=32'd2; ed32=32'd0;

     // SUB
     ins=#(PERIOD) {6'h00, 20'd0, 6'h22};
     rdata1=32'd5; rdata2=32'd3; ed32=32'd0;

     // SUBU
     ins=#(PERIOD) {6'h00, 20'd0, 6'h23};
     rdata1=32'd20; rdata2=32'd11; ed32=32'd0;

     // AND
     ins=#(PERIOD) {6'h00, 20'd0, 6'h24};
     rdata1=32'd20; rdata2=32'd30; ed32=32'd0;

     // OR
     ins=#(PERIOD) {6'h00, 20'd0, 6'h25};
     rdata1=32'd42; rdata2=32'd12; ed32=32'd0;

     // XOR
     ins=#(PERIOD) {6'h00, 20'd0, 6'h26};
     rdata1=32'd23; rdata2=32'd32; ed32=32'd0;

     // NOR
     ins=#(PERIOD) {6'h00, 20'd0, 6'h27};
     rdata1=32'd43; rdata2=32'd32; ed32=32'd0;

     // SLT
     ins=#(PERIOD) {6'h00, 20'd0, 6'h2A};
     rdata1=32'd1; rdata2=32'd1; ed32=32'd0;
     ins=#(PERIOD) {6'h00, 20'd0, 6'h2A};
     rdata1=32'd1; rdata2=32'd4; ed32=32'd0;

     // SLTU
     ins=#(PERIOD) {6'h00, 20'd0, 6'h2B};
     rdata1=32'd1; rdata2=32'd1; ed32=32'd0;

     // ADDI
     ins=#(PERIOD) {6'h08, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd1;

     // ADDIU
     ins=#(PERIOD) {6'h09, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd3;

     // SLTI
     ins=#(PERIOD) {6'h0A, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd1;
     ins=#(PERIOD) {6'h0A, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd100;

     // SLTIU
     ins=#(PERIOD) {6'h0B, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd1;

     // ANDI
     ins=#(PERIOD) {6'h0C, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd1;

     // ORI
     ins=#(PERIOD) {6'h0D, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd1;

     // XORI
     ins=#(PERIOD) {6'h0E, 20'd0, 6'h00};
     rdata1=32'd1; ed32=32'd1;

     // SLL
     ins=#(PERIOD) {6'h00, 20'd0, 6'h00};
     rdata1=32'd1; rdata2=32'd1;

     // SRL
     ins=#(PERIOD) {6'h00, 20'd0, 6'h02};
     rdata1=32'd1; rdata2=32'd1;

     // SRA
     ins=#(PERIOD) {6'h00, 20'd0, 6'h03};
     rdata1=32'd1; rdata2=32'd1;

     // SLLV
     ins=#(PERIOD) {6'h00, 20'd0, 6'h04};
     rdata1=32'd1; rdata2=32'd1;

     // SRLV
     ins=#(PERIOD) {6'h00, 20'd0, 6'h06};
     rdata1=32'd1; rdata2=32'd1;

     // SRAV
     ins=#(PERIOD) {6'h00, 20'd0, 6'h07};
     rdata1=32'd1; rdata2=32'd1;

     // MULT, MFHI, MTLO, MFLO, MTLO
     ins=#(PERIOD) {6'h00, 20'd0, 6'h18};
     rdata1=32'd12345678; rdata2=32'd1234567;
     ins=#(PERIOD) {6'h00, 20'd0, 6'h10};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h11};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h12};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h13};

     // MULTU, MFHI, MTLO, MFLO, MTLO
     ins=#(PERIOD) {6'h00, 20'd0, 6'h19};
     rdata1=32'd87654321; rdata2=32'd7654321;
     ins=#(PERIOD) {6'h00, 20'd0, 6'h10};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h11};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h12};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h13};

     // DIV
     ins=#(PERIOD) {6'h00, 20'd0, 6'h1A};
     rdata1=32'd123456789; rdata2=32'd2;
     ins=#(PERIOD) {6'h00, 20'd0, 6'h10};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h11};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h12};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h13};

     // DIVU
     ins=#(PERIOD) {6'h00, 20'd0, 6'h1B};
     rdata1=32'd123456789; rdata2=32'd2;
     rdata1=32'd1; rdata2=32'd1;
     ins=#(PERIOD) {6'h00, 20'd0, 6'h10};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h11};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h12};
     ins=#(PERIOD) {6'h00, 20'd0, 6'h13};

     // JR
     ins=#(PERIOD) {6'h00, 20'd0, 6'h08};
     rdata1=32'd34; rdata2=32'd4;

     // JALR
     ins=#(PERIOD) {6'h00, 20'd0, 6'h09};
     rdata1=32'd248;

     // J
     ins=#(PERIOD) {6'd2, 26'd64};
     nextpc={4'd2, 28'd1213};

     // JAL
     ins=#(PERIOD) {6'd3, 26'd128};
     nextpc={4'd6, 28'd0};

     // BLTZ
     ins=#(PERIOD) {6'd1, 20'd0, 6'd0};
     rdata1=32'd10; rdata2=32'd0; nextpc=32'd12; ed32=32'd24;
     ins=#(PERIOD) {6'd1, 20'd0, 6'd0};
     rdata1=-32'd10; rdata2=32'd0; nextpc=32'd12; ed32=32'd24;

     // BGEZ
     ins=#(PERIOD) {6'd1, 20'd0, 6'd0}; rdata2=32'd100;
     rdata1=32'd10; rdata2=32'd1; nextpc=32'd12; ed32=32'd24;
     ins=#(PERIOD) {6'd1, 20'd0, 6'd0}; rdata2=32'd100;
     rdata1=-32'd10; rdata2=32'd1; nextpc=32'd12; ed32=32'd24;

     // BEQ
     ins=#(PERIOD) {6'h04, 20'd0, 6'd0};
     rdata1=32'd10; rdata2=32'd10; nextpc=32'd12; ed32=32'd24;
     ins=#(PERIOD) {6'h04, 20'd0, 6'd0};
     rdata1=32'd10; rdata2=32'd20; nextpc=32'd12; ed32=32'd24;

end
endmodule
