/*
* ALU Module
* 6 Operations : +, -, &, |, >>, <<
* Anderson Contreras
*/

//Currently the clk_i and rst_i are only for simulation purposes

module ALU(clk_i, rst_i, in0, in1, op, out);
  input clk_i;
  input rst_i;

  input [31:0] in0;
  input [31:0] in1;
  input [5:0] op;

  output [31:0] out;

  always @(in0 or in1 or op) begin
    case(op)
      0: assign out = in0 + in1;
      1: assign out = in0 - in1;
      2: assign out = in0 & in1;
      3: assign out = in0 | in1;
      4: assign out = in0 >> in1;
      5: assign out = in0 << in1;
    endcase
  end
endmodule
