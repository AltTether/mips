module EX(
    input reg [31:0] Rdata1, Rdata2, Ed32,
    input [5:0] ALU,
    input [5:0] Op,
    input reg [25:0] Jadr,
    input reg [31:0] nextPC,
    output reg [31:0] newPC,
    output reg [31:0] Result
);
    `include "common_param.vh"

    reg [31:0] lo, hi;
    reg [64:0] reg64;
    wire [31:0] MUX2Result;

    assign MUX2Result = (Op == 6'd0) ? Rdata2 : Ed32;

    always @(*) begin
        case(ALU)
            // hoge
            ADD:   Result = Rdata1 + MUX2Result;
            ADDU:  Result = Rdata1 + MUX2Result;
            SUB:   Result = Rdata1 - MUX2Result;
            SUBU:  Result = Rdata1 - MUX2Result;
            AND:   Result = Rdata1 & MUX2Result;
            OR:    Result = Rdata1 | MUX2Result;
            XOR:   Result = Rdata1 ^ MUX2Result;
            NOR:   Result = ~(Rdata1 | MUX2Result);
            SLT:   Result = Rdata1 < MUX2Result;
            SLTU:  Result = Rdata1 < MUX2Result;

            // Immediate Arithmetic Instrunctions
            ADDI:  Result = Rdata1 + MUX2Result;
            ADDIU: Result = Rdata1 + MUX2Result;
            SLTI:  Result = Rdata1 < MUX2Result;
            SLTIU: Result = Rdata1 < MUX2Result;
            ANDI:  Result = Rdata1 & MUX2Result;
            ORI:   Result = Rdata1 | MUX2Result;
            XORI:  Result = Rdata1 ^ MUX2Result;

            // Shift Op
            SLL:   Result = Rdata1 << MUX2Result;
            SRL:   Result = Rdata1 >> MUX2Result;
            // TODO: research how to do on arithmetic shift
            SRA:   Result = Rdata1 >> MUX2Result;
            SLLV:  Result = Rdata1 << MUX2Result;
            SRLV:  Result = Rdata1 >> MUX2Result;
            SRAV:  Result = Rdata1 >> MUX2Result;

            // Mult & Div
            MFHI:  hi = MUX2Result;
            MTHI:  hi = MUX2Result;
            MFLO:  lo = MUX2Result;
            MTLO:  lo = MUX2Result;
            MULT:  begin reg64 = Rdata1 * MUX2Result; hi = reg64[63:32]; lo = reg64[31:0]; end
            MULTU: begin reg64 = Rdata1 * MUX2Result; hi = reg64[63:32]; lo = reg64[31:0]; end
            DIV:   begin reg64 = Rdata1 / MUX2Result; hi = reg64[63:32]; lo = reg64[31:0]; end
            DIVU:  begin reg64 = Rdata1 / MUX2Result; hi = reg64[63:32]; lo = reg64[31:0]; end

        endcase
    end
  assign newPC = nextPC + 4;
endmodule
