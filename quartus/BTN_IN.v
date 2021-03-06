/* Copyright(C) 2017 Cobac.Net All Rights Reserved. */
/* outline: チャタリング除去 */

module BTN_IN (
               input wire       CLK, RST,
               input wire [1:0] nBIN,
               output reg [1:0] BOUT);

/* 50MHzを1250000分周して40Hzを作る              */
/* en40hzはシステムクロック1周期分のパルスで40Hz */
reg [20:0] cnt;

wire en40hz = (cnt==1250000-1);

always @( posedge CLK ) begin
    if ( RST )
        cnt <= 21'b0;
    else if ( en40hz )
        cnt <= 21'b0;
    else
        cnt <= cnt + 21'b1;
end

/*  ボタン入力をFF2個で受ける*/
reg [1:0] ff1, ff2;

always @( posedge CLK ) begin
    if ( RST ) begin
        ff2 <=2'b0;
        ff1 <=2'b0;
    end
    else if ( en40hz ) begin
        ff2 <= ff1;
        ff1 <= nBIN;
    end
end

/* ボタンは押すと0なので、立下りを検出 */
wire [1:0] temp = ~ff1 & ff2 & {2{en40hz}};

/* 念のためFFで受ける */
always @( posedge CLK ) begin
    if ( RST )
        BOUT <=2'b0;
    else
        BOUT <=temp;
end

endmodule
