/*
* Instruction Decode Stage
* Anderson Contreras
*/

`include "decoder.v"
`include "reg_file.v"
`include "imm_gen.v"

module stage_id(clk_i, rst_i, instruction_i, rd_i, rf_wd_i, rf_we_i,
                funct3_o, rd_o, is_alu_alt_op_o, is_lui_o, is_auipc_o, is_jal_o, is_jalr_o, is_branch_o,
                is_mem_o, we_mem_o, is_misc_mem_o, is_system_o);
  input clk_i;
  input rst_i;

  input [31:0] instruction_i;
  input [31:0] rf_wd_i;
  input [4:0] rd_i;
  input rf_we_i;
  output [2:0] funct3_o;
  output rd_o;
  output is_alu_alt_op_o;
  output is_lui_o;
  output is_auipc_o;
  output is_jal_o;
  output is_jalr_o;
  output is_branch_o;
  output is_mem_o;
  output we_mem_o;
  output is_misc_mem_o;
  output is_system_o;

  
  wire [2:0] imm_op;
  wire [2:0] sel_dat_a;
  wire [2:0] sel_dat_b;
  wire [4:0] rs1, rs2;
  wire [31:0] rs1_d, rs2_d;

  wire [31:0] imm_out;

  decoder id_decoder(.clk_i(clk_i),
                     .rst_i(rst_i),
                     .instruction_i(instruction_i),
                     .funct3_o(funct3),
                     .rs1_o(rs1),
                     .rs2_o(rs2),
                     .rd_o(rd),
                     .imm_op_o(imm_op),
                     .sel_dat_a_o(sel_dat_a),
                     .sel_dat_b_o(sel_dat_b),
                     .is_alu_alt_op_o(is_alu_alt_op),
                     .is_lui_o(is_lui),
                     .is_auipc_o(is_auipc),
                     .is_jal_o(is_jal),
                     .is_jalr_o(is_jal),
                     .is_branch_o(is_branch),
                     .is_mem_o(is_mem),
                     .we_mem_o(we_mem_o),
                     .is_misc_mem_o(is_misc_mem),
                     .is_system_o(is_system));

  reg_file id_reg_file(.clk_i(clk_i),
                       .rst_i(rst_i),
                       .rs1_i(rs1),
                       .rs2_i(rs2),
                       .rd_i(rd_i),
                       .rf_wd_i(rf_wd_i),
                       .we_i(rf_we_i),
                       .rs1_d_o(rs1_d),
                       .rs2_d_o(rs2_d));

  imm_gen id_imm_gen(.clk_i(clk_i),
                     .rst_i(rst_i),
                     .instruction_i(instruction_i),
                     .imm_op_i(imm_op),
                     .imm_o(imm_out));

endmodule
