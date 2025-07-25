module CompUnsigned #(
    parameter Bits = 1
)
(
    input [(Bits -1):0] a,
    input [(Bits -1):0] b,
    output \> ,
    output \= ,
    output \<
);
    assign \> = a > b;
    assign \= = a == b;
    assign \< = a < b;
endmodule


module Mux_16x1_NBits #(
    parameter Bits = 2
)
(
    input [3:0] sel,
    input [(Bits - 1):0] in_0,
    input [(Bits - 1):0] in_1,
    input [(Bits - 1):0] in_2,
    input [(Bits - 1):0] in_3,
    input [(Bits - 1):0] in_4,
    input [(Bits - 1):0] in_5,
    input [(Bits - 1):0] in_6,
    input [(Bits - 1):0] in_7,
    input [(Bits - 1):0] in_8,
    input [(Bits - 1):0] in_9,
    input [(Bits - 1):0] in_10,
    input [(Bits - 1):0] in_11,
    input [(Bits - 1):0] in_12,
    input [(Bits - 1):0] in_13,
    input [(Bits - 1):0] in_14,
    input [(Bits - 1):0] in_15,
    output reg [(Bits - 1):0] out
);
    always @ (*) begin
        case (sel)
            4'h0: out = in_0;
            4'h1: out = in_1;
            4'h2: out = in_2;
            4'h3: out = in_3;
            4'h4: out = in_4;
            4'h5: out = in_5;
            4'h6: out = in_6;
            4'h7: out = in_7;
            4'h8: out = in_8;
            4'h9: out = in_9;
            4'ha: out = in_10;
            4'hb: out = in_11;
            4'hc: out = in_12;
            4'hd: out = in_13;
            4'he: out = in_14;
            4'hf: out = in_15;
            default:
                out = 'h0;
        endcase
    end
endmodule


module Mux_2x1_NBits #(
    parameter Bits = 2
)
(
    input [0:0] sel,
    input [(Bits - 1):0] in_0,
    input [(Bits - 1):0] in_1,
    output reg [(Bits - 1):0] out
);
    always @ (*) begin
        case (sel)
            1'h0: out = in_0;
            1'h1: out = in_1;
            default:
                out = 'h0;
        endcase
    end
endmodule


module strings (
  input [7:0] CX,
  input [7:0] CY,
  input [11:0] foreground,
  input [11:0] background,
  input [6:0] character,
  input [11:0] \foreground_(colour) ,
  input [11:0] \background_(colour) ,
  input [3:0] \CX_(colour) ,
  input [7:0] \CY(colour) ,
  input [6:0] Character_0,
  input [6:0] Character_1,
  input [6:0] Character_2,
  input [6:0] Character_3,
  input [6:0] Character_4,
  input [6:0] Character_5,
  input [6:0] Character_6,
  input [6:0] Character_7,
  input [6:0] Character_8,
  input [6:0] Character_9,
  input [6:0] Character_10,
  input [6:0] Character_11,
  input [6:0] Character_12,
  input [6:0] Character_13,
  input [6:0] Character_14,
  input [6:0] Character_15,
  input enable,
  output [6:0] character_o,
  output [11:0] foreground_o,
  output [11:0] background_o,
  output [7:0] CX_o,
  output [7:0] CY_o
);
  wire s0;
  wire [6:0] s1;
  wire [3:0] s2;
  wire s3;
  wire s4;
  wire [3:0] s5;
  CompUnsigned #(
    .Bits(8)
  )
  CompUnsigned_i0 (
    .a( CY ),
    .b( \CY(colour)  ),
    .\> ( s4 )
  );
  assign s5 = CX[3:0];
  assign s2 = CX[7:4];
  CompUnsigned #(
    .Bits(4)
  )
  CompUnsigned_i1 (
    .a( s2 ),
    .b( \CX_(colour)  ),
    .\= ( s3 )
  );
  Mux_16x1_NBits #(
    .Bits(7)
  )
  Mux_16x1_NBits_i2 (
    .sel( s5 ),
    .in_0( Character_0 ),
    .in_1( Character_1 ),
    .in_2( Character_2 ),
    .in_3( Character_3 ),
    .in_4( Character_4 ),
    .in_5( Character_5 ),
    .in_6( Character_6 ),
    .in_7( Character_7 ),
    .in_8( Character_8 ),
    .in_9( Character_9 ),
    .in_10( Character_10 ),
    .in_11( Character_11 ),
    .in_12( Character_12 ),
    .in_13( Character_13 ),
    .in_14( Character_14 ),
    .in_15( Character_15 ),
    .out( s1 )
  );
  assign s0 = (s3 & enable & s4);
  Mux_2x1_NBits #(
    .Bits(7)
  )
  Mux_2x1_NBits_i3 (
    .sel( s0 ),
    .in_0( character ),
    .in_1( s1 ),
    .out( character_o )
  );
  Mux_2x1_NBits #(
    .Bits(12)
  )
  Mux_2x1_NBits_i4 (
    .sel( s0 ),
    .in_0( foreground ),
    .in_1( \foreground_(colour)  ),
    .out( foreground_o )
  );
  Mux_2x1_NBits #(
    .Bits(12)
  )
  Mux_2x1_NBits_i5 (
    .sel( s0 ),
    .in_0( background ),
    .in_1( \background_(colour)  ),
    .out( background_o )
  );
  assign CX_o = CX;
  assign CY_o = CY;
endmodule
