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
  input [15:0] resolution_x,
  input [15:0] front_porch_x,
  input [15:0] sync_x,
  input [15:0] back_porch_x,
  input [15:0] resolution_y,
  input [15:0] front_porch_y,
  input [15:0] sync_y,
  input [15:0] back_porch_y,
  input negative,
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
    .resolution( resolution_x ),
    .front_porch( front_porch_x ),
    .sync( sync_x ),
    .back_porch( back_porch_x ),
    .negative( negative ),
    .V( X_temp ),
    .pulse( Horizontal ),
    .next( s2 )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i1 (
    .a( X_temp ),
    .b( resolution_x ),
    .\< ( s0 )
  );
  timing timing_i2 (
    .enable( s2 ),
    .clock( clock ),
    .resolution( resolution_y ),
    .front_porch( front_porch_y ),
    .sync( sync_y ),
    .back_porch( back_porch_y ),
    .negative( negative ),
    .V( Y_temp ),
    .pulse( Vertical )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i3 (
    .a( Y_temp ),
    .b( resolution_y ),
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


module text (
  input H_input,
  input V_input,
  input picture,
  input [4:0] row,
  input [3:0] column,
  input clock,
  input [11:0] foreground,
  input [11:0] background,
  input [6:0] character,
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

module Mux_4x1
(
    input [1:0] sel,
    input in_0,
    input in_1,
    input in_2,
    input in_3,
    output reg out
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


module display (
  input clock,
  input [1:0] enable,
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
  wire s6;
  wire [7:0] s7;
  wire [7:0] s8;
  wire [11:0] s9;
  wire [11:0] s10;
  wire [6:0] s11;
  wire s12;
  wire s13;
  wire s14;
  wire [11:0] s15;
  wire [11:0] s16;
  wire [6:0] s17;
  wire [3:0] s18;
  wire [3:0] s19;
  wire [3:0] s20;
  wire s21;
  wire s22;
  wire [10:0] s23;
  wire [7:0] s24;
  wire [7:0] s25;
  wire [11:0] s26;
  wire [11:0] s27;
  wire [6:0] s28;
  wire [7:0] s29;
  wire [7:0] s30;
  wire [11:0] s31;
  wire [11:0] s32;
  wire [6:0] s33;
  wire [7:0] s34;
  wire [7:0] s35;
  wire [11:0] s36;
  wire [11:0] s37;
  wire [6:0] s38;
  wire [15:0] s39;
  wire [15:0] s40;
  wire [4:0] s41;
  wire [3:0] s42;
  wire [7:0] s43;
  wire [7:0] s44;
  wire s45;
  wire [7:0] s46;
  wire [7:0] s47;
  wire [11:0] s48;
  wire [11:0] s49;
  wire [6:0] s50;
  wire s51;
  wire s52;
  wire s53;
  wire [11:0] s54;
  wire [11:0] s55;
  wire [6:0] s56;
  wire [3:0] s57;
  wire [3:0] s58;
  wire [3:0] s59;
  wire s60;
  wire s61;
  wire [10:0] s62;
  wire [7:0] s63;
  wire [7:0] s64;
  wire [11:0] s65;
  wire [11:0] s66;
  wire [6:0] s67;
  wire [7:0] s68;
  wire [7:0] s69;
  wire [11:0] s70;
  wire [11:0] s71;
  wire [6:0] s72;
  wire [7:0] s73;
  wire [7:0] s74;
  wire [11:0] s75;
  wire [11:0] s76;
  wire [6:0] s77;
  wire [15:0] s78;
  wire [15:0] s79;
  wire [4:0] s80;
  wire [3:0] s81;
  wire [7:0] s82;
  wire [7:0] s83;
  wire s84;
  wire [7:0] s85;
  wire [7:0] s86;
  wire [11:0] s87;
  wire [11:0] s88;
  wire [6:0] s89;
  wire s90;
  wire s91;
  wire s92;
  wire [11:0] s93;
  wire [11:0] s94;
  wire [6:0] s95;
  wire [3:0] s96;
  wire [3:0] s97;
  wire [3:0] s98;
  wire s99;
  wire s100;
  wire [10:0] s101;
  wire [7:0] s102;
  wire [7:0] s103;
  wire [11:0] s104;
  wire [11:0] s105;
  wire [6:0] s106;
  wire [7:0] s107;
  wire [7:0] s108;
  wire [11:0] s109;
  wire [11:0] s110;
  wire [6:0] s111;
  wire [7:0] s112;
  wire [7:0] s113;
  wire [11:0] s114;
  wire [11:0] s115;
  wire [6:0] s116;
  sync sync_i0 (
    .clock( clock ),
    .resolution_x( 16'b1010000000 ),
    .front_porch_x( 16'b10000 ),
    .sync_x( 16'b1100000 ),
    .back_porch_x( 16'b110000 ),
    .resolution_y( 16'b111100000 ),
    .front_porch_y( 16'b1011 ),
    .sync_y( 16'b10 ),
    .back_porch_y( 16'b100001 ),
    .negative( 1'b1 ),
    .Horizontal( s51 ),
    .Vertical( s52 ),
    .picture( s53 ),
    .X( s39 ),
    .Y( s40 )
  );
  CompUnsigned #(
    .Bits(2)
  )
  CompUnsigned_i1 (
    .a( enable ),
    .b( 2'b10 ),
    .\< ( s45 )
  );
  CompUnsigned #(
    .Bits(2)
  )
  CompUnsigned_i2 (
    .a( enable ),
    .b( 2'b10 ),
    .\= ( s6 )
  );
  CompUnsigned #(
    .Bits(2)
  )
  CompUnsigned_i3 (
    .a( enable ),
    .b( 2'b10 ),
    .\> ( s84 )
  );
  sync sync_i4 (
    .clock( clock ),
    .resolution_x( 16'b10100000000 ),
    .front_porch_x( 16'b1101110 ),
    .sync_x( 16'b101000 ),
    .back_porch_x( 16'b11011100 ),
    .resolution_y( 16'b1011010000 ),
    .front_porch_y( 16'b110 ),
    .sync_y( 16'b101 ),
    .back_porch_y( 16'b10100 ),
    .negative( 1'b0 ),
    .Horizontal( s90 ),
    .Vertical( s91 ),
    .picture( s92 ),
    .X( s78 ),
    .Y( s79 )
  );
  sync sync_i5 (
    .clock( clock ),
    .resolution_x( 16'b1100100000 ),
    .front_porch_x( 16'b101000 ),
    .sync_x( 16'b10000000 ),
    .back_porch_x( 16'b1011000 ),
    .resolution_y( 16'b1001011000 ),
    .front_porch_y( 16'b10 ),
    .sync_y( 16'b100 ),
    .back_porch_y( 16'b10111 ),
    .negative( 1'b0 ),
    .Horizontal( s12 ),
    .Vertical( s13 ),
    .picture( s14 ),
    .X( s0 ),
    .Y( s1 )
  );
  character_position character_position_i6 (
    .X( s0 ),
    .Y( s1 ),
    .row( s2 ),
    .column( s3 ),
    .CX( s4 ),
    .CY( s5 )
  );
  character_position character_position_i7 (
    .X( s39 ),
    .Y( s40 ),
    .row( s41 ),
    .column( s42 ),
    .CX( s43 ),
    .CY( s44 )
  );
  character_position character_position_i8 (
    .X( s78 ),
    .Y( s79 ),
    .row( s80 ),
    .column( s81 ),
    .CX( s82 ),
    .CY( s83 )
  );
  strings strings_i9 (
    .CX( s4 ),
    .CY( s5 ),
    .foreground( 12'b10011110 ),
    .background( 12'b0 ),
    .character( 7'b1000000 ),
    .\foreground_(colour) ( 12'b111111111111 ),
    .\background_(colour) ( 12'b111100000000 ),
    .\CX_(colour) ( 6'b100 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b111000 ),
    .Character_1( 7'b101101 ),
    .Character_2( 7'b1000010 ),
    .Character_3( 7'b1010101 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s7 ),
    .CY_o( s8 ),
    .foreground_o( s9 ),
    .background_o( s10 ),
    .character_o( s11 )
  );
  strings strings_i10 (
    .CX( s43 ),
    .CY( s44 ),
    .foreground( 12'b10011110 ),
    .background( 12'b0 ),
    .character( 7'b1000000 ),
    .\foreground_(colour) ( 12'b111111111111 ),
    .\background_(colour) ( 12'b111100000000 ),
    .\CX_(colour) ( 6'b1 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b111000 ),
    .Character_1( 7'b101101 ),
    .Character_2( 7'b1000010 ),
    .Character_3( 7'b1010101 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s46 ),
    .CY_o( s47 ),
    .foreground_o( s48 ),
    .background_o( s49 ),
    .character_o( s50 )
  );
  strings strings_i11 (
    .CX( s82 ),
    .CY( s83 ),
    .foreground( 12'b10011110 ),
    .background( 12'b0 ),
    .character( 7'b1000000 ),
    .\foreground_(colour) ( 12'b111111111111 ),
    .\background_(colour) ( 12'b111100000000 ),
    .\CX_(colour) ( 6'b111 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b111000 ),
    .Character_1( 7'b101101 ),
    .Character_2( 7'b1000010 ),
    .Character_3( 7'b1010101 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s85 ),
    .CY_o( s86 ),
    .foreground_o( s87 ),
    .background_o( s88 ),
    .character_o( s89 )
  );
  strings strings_i12 (
    .CX( s7 ),
    .CY( s8 ),
    .foreground( s9 ),
    .background( s10 ),
    .character( s11 ),
    .\foreground_(colour) ( 12'b0 ),
    .\background_(colour) ( 12'b11011110010 ),
    .\CX_(colour) ( 6'b101 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b1010100 ),
    .Character_1( 7'b100000 ),
    .Character_2( 7'b1001101 ),
    .Character_3( 7'b1001001 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s24 ),
    .CY_o( s25 ),
    .foreground_o( s26 ),
    .background_o( s27 ),
    .character_o( s28 )
  );
  strings strings_i13 (
    .CX( s46 ),
    .CY( s47 ),
    .foreground( s48 ),
    .background( s49 ),
    .character( s50 ),
    .\foreground_(colour) ( 12'b0 ),
    .\background_(colour) ( 12'b11011110010 ),
    .\CX_(colour) ( 6'b10 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b1010100 ),
    .Character_1( 7'b100000 ),
    .Character_2( 7'b1001101 ),
    .Character_3( 7'b1001001 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s63 ),
    .CY_o( s64 ),
    .foreground_o( s65 ),
    .background_o( s66 ),
    .character_o( s67 )
  );
  strings strings_i14 (
    .CX( s85 ),
    .CY( s86 ),
    .foreground( s87 ),
    .background( s88 ),
    .character( s89 ),
    .\foreground_(colour) ( 12'b0 ),
    .\background_(colour) ( 12'b11011110010 ),
    .\CX_(colour) ( 6'b1000 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b1010100 ),
    .Character_1( 7'b100000 ),
    .Character_2( 7'b1001101 ),
    .Character_3( 7'b1001001 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s102 ),
    .CY_o( s103 ),
    .foreground_o( s104 ),
    .background_o( s105 ),
    .character_o( s106 )
  );
  strings strings_i15 (
    .CX( s24 ),
    .CY( s25 ),
    .foreground( s26 ),
    .background( s27 ),
    .character( s28 ),
    .\foreground_(colour) ( 12'b111100010111 ),
    .\background_(colour) ( 12'b11111111 ),
    .\CX_(colour) ( 6'b110 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b1000111 ),
    .Character_1( 7'b1001000 ),
    .Character_2( 7'b1010100 ),
    .Character_3( 7'b1011001 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s29 ),
    .CY_o( s30 ),
    .foreground_o( s31 ),
    .background_o( s32 ),
    .character_o( s33 )
  );
  strings strings_i16 (
    .CX( s63 ),
    .CY( s64 ),
    .foreground( s65 ),
    .background( s66 ),
    .character( s67 ),
    .\foreground_(colour) ( 12'b111100010111 ),
    .\background_(colour) ( 12'b11111111 ),
    .\CX_(colour) ( 6'b11 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b1000111 ),
    .Character_1( 7'b1001000 ),
    .Character_2( 7'b1010100 ),
    .Character_3( 7'b1011001 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s68 ),
    .CY_o( s69 ),
    .foreground_o( s70 ),
    .background_o( s71 ),
    .character_o( s72 )
  );
  strings strings_i17 (
    .CX( s102 ),
    .CY( s103 ),
    .foreground( s104 ),
    .background( s105 ),
    .character( s106 ),
    .\foreground_(colour) ( 12'b111100010111 ),
    .\background_(colour) ( 12'b11111111 ),
    .\CX_(colour) ( 6'b1001 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b1000111 ),
    .Character_1( 7'b1001000 ),
    .Character_2( 7'b1010100 ),
    .Character_3( 7'b1011001 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s107 ),
    .CY_o( s108 ),
    .foreground_o( s109 ),
    .background_o( s110 ),
    .character_o( s111 )
  );
  strings strings_i18 (
    .CX( s29 ),
    .CY( s30 ),
    .foreground( s31 ),
    .background( s32 ),
    .character( s33 ),
    .\foreground_(colour) ( 12'b10001010001 ),
    .\background_(colour) ( 12'b111011111111 ),
    .\CX_(colour) ( 6'b111 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b1010110 ),
    .Character_2( 7'b1000111 ),
    .Character_3( 7'b1000001 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s34 ),
    .CY_o( s35 ),
    .foreground_o( s36 ),
    .background_o( s37 ),
    .character_o( s38 )
  );
  strings strings_i19 (
    .CX( s68 ),
    .CY( s69 ),
    .foreground( s70 ),
    .background( s71 ),
    .character( s72 ),
    .\foreground_(colour) ( 12'b10001010001 ),
    .\background_(colour) ( 12'b111011111111 ),
    .\CX_(colour) ( 6'b100 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b1010110 ),
    .Character_2( 7'b1000111 ),
    .Character_3( 7'b1000001 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s73 ),
    .CY_o( s74 ),
    .foreground_o( s75 ),
    .background_o( s76 ),
    .character_o( s77 )
  );
  strings strings_i20 (
    .CX( s107 ),
    .CY( s108 ),
    .foreground( s109 ),
    .background( s110 ),
    .character( s111 ),
    .\foreground_(colour) ( 12'b10001010001 ),
    .\background_(colour) ( 12'b111011111111 ),
    .\CX_(colour) ( 6'b1010 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b1010110 ),
    .Character_2( 7'b1000111 ),
    .Character_3( 7'b1000001 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s112 ),
    .CY_o( s113 ),
    .foreground_o( s114 ),
    .background_o( s115 ),
    .character_o( s116 )
  );
  strings strings_i21 (
    .CX( s73 ),
    .CY( s74 ),
    .foreground( s75 ),
    .background( s76 ),
    .character( s77 ),
    .\foreground_(colour) ( 12'b1101000010 ),
    .\background_(colour) ( 12'b11101001 ),
    .\CX_(colour) ( 6'b101 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b110100 ),
    .Character_2( 7'b111000 ),
    .Character_3( 7'b110000 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .foreground_o( s54 ),
    .background_o( s55 ),
    .character_o( s56 )
  );
  strings strings_i22 (
    .CX( s34 ),
    .CY( s35 ),
    .foreground( s36 ),
    .background( s37 ),
    .character( s38 ),
    .\foreground_(colour) ( 12'b1101000010 ),
    .\background_(colour) ( 12'b11101001 ),
    .\CX_(colour) ( 6'b1000 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b110110 ),
    .Character_2( 7'b110000 ),
    .Character_3( 7'b110000 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .foreground_o( s15 ),
    .background_o( s16 ),
    .character_o( s17 )
  );
  strings strings_i23 (
    .CX( s112 ),
    .CY( s113 ),
    .foreground( s114 ),
    .background( s115 ),
    .character( s116 ),
    .\foreground_(colour) ( 12'b1101000010 ),
    .\background_(colour) ( 12'b11101001 ),
    .\CX_(colour) ( 6'b1011 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b110111 ),
    .Character_2( 7'b110010 ),
    .Character_3( 7'b110000 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .foreground_o( s93 ),
    .background_o( s94 ),
    .character_o( s95 )
  );
  text text_i24 (
    .H_input( s12 ),
    .V_input( s13 ),
    .picture( s14 ),
    .row( s2 ),
    .column( s3 ),
    .clock( clock ),
    .foreground( s15 ),
    .background( s16 ),
    .character( s17 ),
    .Character_Data( Character_Data ),
    .R( s18 ),
    .G( s19 ),
    .B( s20 ),
    .H_output( s21 ),
    .V_output( s22 ),
    .Character_Address( s23 )
  );
  text text_i25 (
    .H_input( s51 ),
    .V_input( s52 ),
    .picture( s53 ),
    .row( s41 ),
    .column( s42 ),
    .clock( clock ),
    .foreground( s54 ),
    .background( s55 ),
    .character( s56 ),
    .Character_Data( Character_Data ),
    .R( s57 ),
    .G( s58 ),
    .B( s59 ),
    .H_output( s60 ),
    .V_output( s61 ),
    .Character_Address( s62 )
  );
  text text_i26 (
    .H_input( s90 ),
    .V_input( s91 ),
    .picture( s92 ),
    .row( s80 ),
    .column( s81 ),
    .clock( clock ),
    .foreground( s93 ),
    .background( s94 ),
    .character( s95 ),
    .Character_Data( Character_Data ),
    .R( s96 ),
    .G( s97 ),
    .B( s98 ),
    .H_output( s99 ),
    .V_output( s100 ),
    .Character_Address( s101 )
  );
  Mux_4x1_NBits #(
    .Bits(4)
  )
  Mux_4x1_NBits_i27 (
    .sel( enable ),
    .in_0( 4'b0 ),
    .in_1( s57 ),
    .in_2( s18 ),
    .in_3( s96 ),
    .out( R )
  );
  Mux_4x1 Mux_4x1_i28 (
    .sel( enable ),
    .in_0( 1'b0 ),
    .in_1( s61 ),
    .in_2( s22 ),
    .in_3( s100 ),
    .out( V_output )
  );
  Mux_4x1 Mux_4x1_i29 (
    .sel( enable ),
    .in_0( 1'b0 ),
    .in_1( s60 ),
    .in_2( s21 ),
    .in_3( s99 ),
    .out( H_output )
  );
  Mux_4x1_NBits #(
    .Bits(4)
  )
  Mux_4x1_NBits_i30 (
    .sel( enable ),
    .in_0( 4'b0 ),
    .in_1( s59 ),
    .in_2( s20 ),
    .in_3( s98 ),
    .out( B )
  );
  Mux_4x1_NBits #(
    .Bits(4)
  )
  Mux_4x1_NBits_i31 (
    .sel( enable ),
    .in_0( 4'b0 ),
    .in_1( s58 ),
    .in_2( s19 ),
    .in_3( s97 ),
    .out( G )
  );
  Mux_4x1_NBits #(
    .Bits(11)
  )
  Mux_4x1_NBits_i32 (
    .sel( enable ),
    .in_0( 11'b0 ),
    .in_1( s62 ),
    .in_2( s23 ),
    .in_3( s101 ),
    .out( Character_Address )
  );
endmodule
