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


module vga_timing (
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
