/*
* Immediate Gnerator
* Supports immediate generation for I, S, B, U, J and CSR instructions
* Anderson Contreras
*/

//Currently the clk_i and rst_i are only for simulation purposes

module imm_gen(clk_i, rst_i, instruction_i, imm_op_i, imm_o);
  localparam IMM_I = 0'b000;
  localparam IMM_S = 0'b001;
  localparam IMM_B = 0'b010;
  localparam IMM_U = 0'b011;
  localparam IMM_J = 0'b100;
  localparam IMM_C = 0'b101;

  input clk_i;
  input rst_i;

  input  [2:0] imm_op_i;
  input  [31:0] instruction_i;
  output [31:0] imm_o;


  wire [31:0] imm_i;
  wire [31:0] imm_s;
  wire [31:0] imm_b;
  wire [31:0] imm_u;
  wire [31:0] imm_j;
  wire [31:0] imm_c;

  assign imm_i = $signed(instruction_i[31:20]);
  assign imm_s = $signed({instruction_i[31:25], instruction_i[11:7]});
  assign imm_b = $signed({instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0});
  assign imm_u = {instruction_i[31:12], {12{1'b0}}};
  assign imm_j = $signed({instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0});
  assign imm_c = instruction_i[19:15];

  always @(*) begin
    case (imm_op_i)
      IMM_I: imm_o = imm_i; 
      IMM_S: imm_o = imm_s; 
      IMM_B: imm_o = imm_b; 
      IMM_U: imm_o = imm_u; 
      IMM_J: imm_o = imm_j; 
      IMM_C: imm_o = imm_c; 
    endcase    
  end
endmodule