module DIG_Sub #(
    parameter Bits = 2
)
(
    input [(Bits-1):0] a,
    input [(Bits-1):0] b,
    input c_i,
    output [(Bits-1):0] s,
    output c_o
);
    wire [Bits:0] temp;

    assign temp = a - b - c_i;
    assign s = temp[(Bits-1):0];
    assign c_o = temp[Bits];
endmodule

module DIG_D_FF_Nbit
#(
    parameter Bits = 2,
    parameter Default = 0
)
(
   input [(Bits-1):0] D,
   input C,
   output [(Bits-1):0] Q,
   output [(Bits-1):0] \~Q
);
    reg [(Bits-1):0] state;

    assign Q = state;
    assign \~Q = ~state;

    always @ (posedge C) begin
        state <= D;
    end

    initial begin
        state = Default;
    end
endmodule

module DIG_D_FF_1bit
#(
    parameter Default = 0
)
(
   input D,
   input C,
   output Q,
   output \~Q
);
    reg state;

    assign Q = state;
    assign \~Q = ~state;

    always @ (posedge C) begin
        state <= D;
    end

    initial begin
        state = Default;
    end
endmodule


module Mux_16x1
(
    input [3:0] sel,
    input in_0,
    input in_1,
    input in_2,
    input in_3,
    input in_4,
    input in_5,
    input in_6,
    input in_7,
    input in_8,
    input in_9,
    input in_10,
    input in_11,
    input in_12,
    input in_13,
    input in_14,
    input in_15,
    output reg out
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


module vga_text (
  input H_input,
  input V_input,
  input picture,
  input [4:0] row,
  input [3:0] column,
  input clock,
  input [6:0] character,
  input [11:0] foreground,
  input [11:0] background,
  input [15:0] Character_Data,
  output [3:0] R,
  output [3:0] G,
  output [3:0] B,
  output H_output,
  output V_output,
  output [10:0] Character_Address
);
  wire [6:0] s0;
  wire s1;
  wire [5:0] s2;
  wire [5:0] s3;
  wire s4;
  wire s5;
  wire [1:0] s6;
  wire [11:0] s7;
  wire [11:0] s8;
  wire [11:0] s9;
  wire [3:0] s10;
  wire s11;
  wire s12;
  wire s13;
  wire s14;
  wire s15;
  wire s16;
  wire s17;
  wire s18;
  wire s19;
  wire s20;
  wire s21;
  wire s22;
  wire s23;
  wire s24;
  wire s25;
  wire s26;
  DIG_Sub #(
    .Bits(7)
  )
  DIG_Sub_i0 (
    .a( character ),
    .b( 7'b100000 ),
    .c_i( 1'b0 ),
    .s( s0 ),
    .c_o( s1 )
  );
  DIG_D_FF_Nbit #(
    .Bits(4),
    .Default(0)
  )
  DIG_D_FF_Nbit_i1 (
    .D( column ),
    .C( clock ),
    .Q( s10 )
  );
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i2 (
    .D( V_input ),
    .C( clock ),
    .Q( V_output )
  );
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i3 (
    .D( H_input ),
    .C( clock ),
    .Q( H_output )
  );
  DIG_D_FF_Nbit #(
    .Bits(12),
    .Default(0)
  )
  DIG_D_FF_Nbit_i4 (
    .D( foreground ),
    .C( clock ),
    .Q( s8 )
  );
  DIG_D_FF_Nbit #(
    .Bits(12),
    .Default(0)
  )
  DIG_D_FF_Nbit_i5 (
    .D( background ),
    .C( clock ),
    .Q( s7 )
  );
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i6 (
    .D( picture ),
    .C( clock ),
    .Q( s5 )
  );
  assign s26 = Character_Data[0];
  assign s25 = Character_Data[1];
  assign s24 = Character_Data[2];
  assign s23 = Character_Data[3];
  assign s22 = Character_Data[4];
  assign s21 = Character_Data[5];
  assign s20 = Character_Data[6];
  assign s19 = Character_Data[7];
  assign s18 = Character_Data[8];
  assign s17 = Character_Data[9];
  assign s16 = Character_Data[10];
  assign s15 = Character_Data[11];
  assign s14 = Character_Data[12];
  assign s13 = Character_Data[13];
  assign s12 = Character_Data[14];
  assign s11 = Character_Data[15];
  Mux_16x1 Mux_16x1_i7 (
    .sel( s10 ),
    .in_0( s11 ),
    .in_1( s12 ),
    .in_2( s13 ),
    .in_3( s14 ),
    .in_4( s15 ),
    .in_5( s16 ),
    .in_6( s17 ),
    .in_7( s18 ),
    .in_8( s19 ),
    .in_9( s20 ),
    .in_10( s21 ),
    .in_11( s22 ),
    .in_12( s23 ),
    .in_13( s24 ),
    .in_14( s25 ),
    .in_15( s26 ),
    .out( s4 )
  );
  assign s2 = s0[5:0];
  Mux_2x1_NBits #(
    .Bits(6)
  )
  Mux_2x1_NBits_i8 (
    .sel( s1 ),
    .in_0( s2 ),
    .in_1( 6'b0 ),
    .out( s3 )
  );
  assign s6[0] = s4;
  assign s6[1] = s5;
  assign Character_Address[4:0] = row;
  assign Character_Address[10:5] = s3;
  Mux_4x1_NBits #(
    .Bits(12)
  )
  Mux_4x1_NBits_i9 (
    .sel( s6 ),
    .in_0( 12'b0 ),
    .in_1( 12'b0 ),
    .in_2( s7 ),
    .in_3( s8 ),
    .out( s9 )
  );
  assign B = s9[3:0];
  assign G = s9[7:4];
  assign R = s9[11:8];
endmodule
