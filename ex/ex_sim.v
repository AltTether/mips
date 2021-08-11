`timescale 1 ps/ 1 ps


module ex_sim();
parameter PERIOD=10000;  // (clock period)/2

// constants
// general purpose registers
  reg [31:0] rdata1, rdata2, ed32;
  reg [25:0] jadr;
  reg [31:0] nextpc;
  reg [5:0] alu, op;

// wires
  wire [31:0] newpc;
  wire [31:0] result;

// assign statements (if any)
EX ex1 (
// port map - connection between master ports and signals/registers
  .Rdata1(rdata1),
  .Rdata2(rdata2),
  .ALU(alu),
  .Op(op),
  .Ed32(ed32),
  .Jadr(jadr),
  .nextPC(nextpc),
  .newPC(newpc),
  .Result(result)
);

initial
begin
    alu=#(PERIOD) 6'd32; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;
    ed32=1'b0; jadr=26'd0; nextpc=1'b0;

    alu=#(PERIOD) 6'd33; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    alu=#(PERIOD) 6'd34; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    alu=#(PERIOD) 6'd35; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    alu=#(PERIOD) 6'd36; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    alu=#(PERIOD) 6'd37; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    alu=#(PERIOD) 6'd38; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    alu=#(PERIOD) 6'd39; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // SLT
    alu=#(PERIOD) 6'd42; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;
    alu=#(PERIOD) 6'd42; op=6'h00;
    rdata1=32'd1; rdata2=32'd4;

    alu=#(PERIOD) 6'd43; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // ADDI
    alu=#(PERIOD) 6'd8; op=6'h08;
    rdata1=32'd1; ed32=32'd1;

    // ADDIU
    alu=#(PERIOD) 6'd9; op=6'h09;
    rdata1=32'd1; ed32=32'd1;

    // SLTI
    alu=#(PERIOD) 6'd10; op=6'h0a;
    rdata1=32'd1; ed32=32'd1;
    alu=#(PERIOD) 6'd10; op=6'h0a;
    rdata1=32'd1; ed32=32'd4;

    // SLTIU
    alu=#(PERIOD) 6'd11; op=6'h0b;
    rdata1=32'd1; ed32=32'd1;

    // ANDI
    alu=#(PERIOD) 6'd12; op=6'h0c;
    rdata1=32'd1; ed32=32'd1;

    // ORI
    alu=#(PERIOD) 6'd13; op=6'h0d;
    rdata1=32'd1; ed32=32'd1;

    // XORI
    alu=#(PERIOD) 6'd14; op=6'h0e;
    rdata1=32'd1; ed32=32'd1;

    // SLL
    alu=#(PERIOD) 6'd0; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // SRL
    alu=#(PERIOD) 6'd2; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // SRA
    alu=#(PERIOD) 6'd3; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // SLLV
    alu=#(PERIOD) 6'd4; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // SRLV
    alu=#(PERIOD) 6'd6; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // SRAV
    alu=#(PERIOD) 6'd7; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // MFHI
    alu=#(PERIOD) 6'd16; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // MTHI
    alu=#(PERIOD) 6'd17; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // MFLO
    alu=#(PERIOD) 6'd18; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // MTLO
    alu=#(PERIOD) 6'd19; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // MULT
    alu=#(PERIOD) 6'd24; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // MULTU
    alu=#(PERIOD) 6'd25; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // DIV
    alu=#(PERIOD) 6'd26; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;

    // DIVU
    alu=#(PERIOD) 6'd27; op=6'h00;
    rdata1=32'd1; rdata2=32'd1;
end
endmodule
