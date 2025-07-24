module vga_character_position (
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
