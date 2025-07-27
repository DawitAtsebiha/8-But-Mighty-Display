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


module Mux_4x1_NBits #(
    parameter Bits = 2
)
(
    input [1:0] sel,
    input [(Bits - 1):0] in_0,
    input [(Bits - 1):0] in_1,
    input [(Bits - 1):0] in_2,
    input [(Bits - 1):0] in_3,
    output reg [(Bits - 1):0] out
);
    always @ (*) begin
        case (sel)
            2'h0: out = in_0;
            2'h1: out = in_1;
            2'h2: out = in_2;
            2'h3: out = in_3;
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
  input [5:0] \CX_(colour) ,
  input [7:0] \CY(colour) ,
  input [6:0] Character_0,
  input [6:0] Character_1,
  input [6:0] Character_2,
  input [6:0] Character_3,
  input [7:0] cutoff,
  input enable,
  output [7:0] CX_o,
  output [7:0] CY_o,
  output [11:0] foreground_o,
  output [11:0] background_o,
  output [6:0] character_o
);
  wire s0;
  wire [6:0] s1;
  wire [5:0] s2;
  wire s3;
  wire s4;
  wire s5;
  wire [1:0] s6;
  CompUnsigned #(
    .Bits(8)
  )
  CompUnsigned_i0 (
    .a( CY ),
    .b( \CY(colour)  ),
    .\= ( s4 )
  );
  CompUnsigned #(
    .Bits(8)
  )
  CompUnsigned_i1 (
    .a( cutoff ),
    .b( CY ),
    .\= ( s5 )
  );
  assign s6 = CX[1:0];
  assign s2 = CX[7:2];
  CompUnsigned #(
    .Bits(6)
  )
  CompUnsigned_i2 (
    .a( s2 ),
    .b( \CX_(colour)  ),
    .\= ( s3 )
  );
  Mux_4x1_NBits #(
    .Bits(7)
  )
  Mux_4x1_NBits_i3 (
    .sel( s6 ),
    .in_0( Character_0 ),
    .in_1( Character_1 ),
    .in_2( Character_2 ),
    .in_3( Character_3 ),
    .out( s1 )
  );
  assign s0 = (s3 & enable & s5 & s4);
  Mux_2x1_NBits #(
    .Bits(7)
  )
  Mux_2x1_NBits_i4 (
    .sel( s0 ),
    .in_0( character ),
    .in_1( s1 ),
    .out( character_o )
  );
  Mux_2x1_NBits #(
    .Bits(12)
  )
  Mux_2x1_NBits_i5 (
    .sel( s0 ),
    .in_0( foreground ),
    .in_1( \foreground_(colour)  ),
    .out( foreground_o )
  );
  Mux_2x1_NBits #(
    .Bits(12)
  )
  Mux_2x1_NBits_i6 (
    .sel( s0 ),
    .in_0( background ),
    .in_1( \background_(colour)  ),
    .out( background_o )
  );
  assign CX_o = CX;
  assign CY_o = CY;
endmodule
