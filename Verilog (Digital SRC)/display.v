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


module DIG_CounterPreset #(
    parameter Bits = 2,
    parameter maxValue = 4
)
(
    input C,
    input en,
    input clr,
    input dir,
    input [(Bits-1):0] in,
    input ld,
    output [(Bits-1):0] out,
    output ovf
);

    reg [(Bits-1):0] count = 'h0;

    function [(Bits-1):0] maxVal (input [(Bits-1):0] maxv);
        if (maxv == 0)
            maxVal = (1 << Bits) - 1;
        else
            maxVal = maxv;
    endfunction

    assign out = count;
    assign ovf = ((count == maxVal(maxValue) & dir == 1'b0)
                  | (count == 'b0 & dir == 1'b1))? en : 1'b0;

    always @ (posedge C) begin
        if (clr == 1'b1)
            count <= 'h0;
        else if (ld == 1'b1)
            count <= in;
        else if (en == 1'b1) begin
            if (dir == 1'b0) begin
                if (count == maxVal(maxValue))
                    count <= 'h0;
                else
                    count <= count + 1'b1;
            end
            else begin
                if (count == 'h0)
                    count <= maxVal(maxValue);
                else
                    count <= count - 1;
            end
        end
    end
endmodule


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


module timing (
  input enable,
  input clock,
  input [15:0] resolution,
  input [15:0] front_porch,
  input [15:0] sync,
  input [15:0] back_porch,
  input negative,
  output [15:0] V,
  output pulse,
  output next
);
  wire [15:0] s0;
  wire next_temp;
  wire [15:0] V_temp;
  wire [15:0] s1;
  wire [15:0] s2;
  wire [15:0] s3;
  wire s4;
  wire s5;
  wire s6;
  wire s7;
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i0 (
    .a( resolution ),
    .b( 16'b1 ),
    .c_i( 1'b0 ),
    .s( s1 )
  );
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i1 (
    .a( 16'b0 ),
    .b( back_porch ),
    .c_i( 1'b0 ),
    .s( s2 )
  );
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i2 (
    .a( s2 ),
    .b( sync ),
    .c_i( 1'b0 ),
    .s( s3 )
  );
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i3 (
    .a( s3 ),
    .b( front_porch ),
    .c_i( 1'b0 ),
    .s( s0 )
  );
  DIG_CounterPreset #(
    .Bits(16),
    .maxValue(0)
  )
  DIG_CounterPreset_i4 (
    .en( enable ),
    .C( clock ),
    .dir( 1'b0 ),
    .in( s0 ),
    .ld( next_temp ),
    .clr( 1'b0 ),
    .out( V_temp )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i5 (
    .a( V_temp ),
    .b( s1 ),
    .\= ( next_temp )
  );
  assign pulse = (s4 ^ negative);
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i6 (
    .a( V_temp ),
    .b( s2 ),
    .\= ( s5 )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i7 (
    .a( V_temp ),
    .b( s3 ),
    .\= ( s6 )
  );
  assign s7 = (~ s5 & (s6 | s4));
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i8 (
    .D( s7 ),
    .C( clock ),
    .Q( s4 )
  );
  assign V = V_temp;
  assign next = next_temp;
endmodule

module sync (
  input clock,
  output Horizontal,
  output Vertical,
  output picture,
  output [15:0] X,
  output [15:0] Y
);
  wire [15:0] X_temp;
  wire s0;
  wire [15:0] Y_temp;
  wire s1;
  wire s2;
  timing timing_i0 (
    .enable( 1'b1 ),
    .clock( clock ),
    .resolution( 16'b10100000000 ),
    .front_porch( 16'b1101110 ),
    .sync( 16'b101000 ),
    .back_porch( 16'b11011100 ),
    .negative( 1'b0 ),
    .V( X_temp ),
    .pulse( Horizontal ),
    .next( s2 )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i1 (
    .a( X_temp ),
    .b( 16'b10100000000 ),
    .\< ( s0 )
  );
  timing timing_i2 (
    .enable( s2 ),
    .clock( clock ),
    .resolution( 16'b1011010000 ),
    .front_porch( 16'b101 ),
    .sync( 16'b101 ),
    .back_porch( 16'b10101 ),
    .negative( 1'b0 ),
    .V( Y_temp ),
    .pulse( Vertical )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i3 (
    .a( Y_temp ),
    .b( 16'b1011010000 ),
    .\< ( s1 )
  );
  assign picture = (s0 & s1);
  assign X = X_temp;
  assign Y = Y_temp;
endmodule

module character_position (
  input [15:0] X,
  input [15:0] Y,
  output [4:0] row,
  output [3:0] column,
  output [7:0] CX,
  output [7:0] CY
);
  assign column = X[3:0];
  assign CX = X[11:4];
  assign row = Y[4:0];
  assign CY = Y[12:5];
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


module text (
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

module display (
  input clock,
  input enable,
  input [15:0] Character_Data,
  output [3:0] R,
  output [3:0] G,
  output [3:0] B,
  output H_output,
  output V_output,
  output [10:0] Character_Address
);
  wire [15:0] s0;
  wire [15:0] s1;
  wire [4:0] s2;
  wire [3:0] s3;
  wire [7:0] s4;
  wire [7:0] s5;
  wire [6:0] s6;
  wire [11:0] s7;
  wire [11:0] s8;
  wire s9;
  wire s10;
  wire s11;
  sync sync_i0 (
    .clock( clock ),
    .Horizontal( s9 ),
    .Vertical( s10 ),
    .picture( s11 ),
    .X( s0 ),
    .Y( s1 )
  );
  character_position character_position_i1 (
    .X( s0 ),
    .Y( s1 ),
    .row( s2 ),
    .column( s3 ),
    .CX( s4 ),
    .CY( s5 )
  );
  strings strings_i2 (
    .CX( s4 ),
    .CY( s5 ),
    .foreground( 12'b10011110 ),
    .background( 12'b1 ),
    .character( 7'b0 ),
    .\foreground_(colour) ( 12'b1111000001 ),
    .\background_(colour) ( 12'b1 ),
    .\CX_(colour) ( 4'b10 ),
    .\CY(colour) ( 8'b0 ),
    .Character_0( 7'b111000 ),
    .Character_1( 7'b101101 ),
    .Character_2( 7'b1000010 ),
    .Character_3( 7'b1010101 ),
    .Character_4( 7'b1010100 ),
    .Character_5( 7'b100000 ),
    .Character_6( 7'b1001101 ),
    .Character_7( 7'b1001001 ),
    .Character_8( 7'b1000111 ),
    .Character_9( 7'b1001000 ),
    .Character_10( 7'b1010100 ),
    .Character_11( 7'b1011001 ),
    .Character_12( 7'b100000 ),
    .Character_13( 7'b1010110 ),
    .Character_14( 7'b1000111 ),
    .Character_15( 7'b1000001 ),
    .enable( enable ),
    .character_o( s6 ),
    .foreground_o( s7 ),
    .background_o( s8 )
  );
  text text_i3 (
    .H_input( s9 ),
    .V_input( s10 ),
    .picture( s11 ),
    .row( s2 ),
    .column( s3 ),
    .clock( clock ),
    .character( s6 ),
    .foreground( s7 ),
    .background( s8 ),
    .Character_Data( Character_Data ),
    .R( R ),
    .G( G ),
    .B( B ),
    .H_output( H_output ),
    .V_output( V_output ),
    .Character_Address( Character_Address )
  );
endmodule
