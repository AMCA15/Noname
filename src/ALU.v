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

module ALU(clk_i, rst_i, in0, in1, op, out);
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

  input [31:0] in0;
  input [31:0] in1;
  input [3:0] op;
  output [31:0] out;

  wire signed [31:0] A = in0;
  wire signed [31:0] B = in1;

  always @(*) begin
    case(op)
      ALU_ADD: out = A + B;
      ALU_SUB: out = A - B;
      ALU_AND: out = A & B;
      ALU_OR: out = A | B;
      ALU_XOR: out = A ^ B;
      ALU_SRL: out = A >> B;
      ALU_SLL: out = A << B;
      ALU_SRA: out = A >>> B;
      ALU_SLT: out = (A < B) ? 1 : 0;
      ALU_SLTU: out = (0 != A) ? 1 : 0;
    endcase
  end
endmodule
