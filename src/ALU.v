/*
* ALU Module
* Operations supported:
*   - Arithmetic: addition, subtraction
*   - Logical: and, or, xor
*   - Shift: shift right logical, shift left logical, shift right arithmetic
*   - Comparison: set less than, set less than unsigned
* Anderson Contreras
*/

//Currently the clk_i and rst_i are only for simulation purposes

module alu(clk_i, rst_i, in0_i, in1_i, op_i, out_o);
  localparam ALU_ADD  = 4'b0000;
  localparam ALU_SUB  = 4'b1000;
  localparam ALU_AND  = 4'b0111;
  localparam ALU_OR   = 4'b0110;
  localparam ALU_XOR  = 4'b0100;
  localparam ALU_SRL  = 4'b0101;
  localparam ALU_SLL  = 4'b0001;
  localparam ALU_SRA  = 4'b1101;
  localparam ALU_SLT  = 4'b0010;
  localparam ALU_SLTU = 4'b0011;
 
  input clk_i;
  input rst_i;

  input [31:0] in0_i;
  input [31:0] in1_i;
  input [3:0] op_i;
  output [31:0] out_o;

  wire signed [31:0] A = in0_i;
  wire signed [31:0] B = in1_i;

  always @(*) begin
    case(op_i)
      ALU_ADD: out_o = A + B;
      ALU_SUB: out_o = A - B;
      ALU_AND: out_o = A & B;
      ALU_OR: out_o = A | B;
      ALU_XOR: out_o = A ^ B;
      ALU_SRL: out_o = A >> B;
      ALU_SLL: out_o = A << B;
      ALU_SRA: out_o = A >>> B;
      ALU_SLT: out_o = (A < B) ? 1 : 0;
      ALU_SLTU: out_o = (0 != A) ? 1 : 0;
    endcase
  end
endmodule
