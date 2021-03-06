/*
* Execution Stage
* Anderson Contreras
*/

module stage_exe(pc_i, imm_i, dat_a_i, dat_b_i, alu_op_i, funct3_i,
				 is_jal_inst_i, is_jalr_inst_i, is_br_inst_i,
				 is_br_j_taken_o, e_inst_addr_mis_o, br_j_addr_o, alu_out_o, is_br_j_valid_o);

	input [31:0] pc_i;
	input [31:0] imm_i;
	input [31:0] dat_a_i;
	input [31:0] dat_b_i;
	input [3:0] alu_op_i;
	input [2:0] funct3_i;
	input is_jal_inst_i;
	input is_jalr_inst_i;
	input is_br_inst_i;
	output is_br_j_taken_o;
	output e_inst_addr_mis_o;
	output [31:0] br_j_addr_o;
	output [31:0] alu_out_o;
	output is_br_j_valid_o;


	wire alu_equ;
	wire alu_lt;
	wire alu_ltu;
	wire branch_res;


	assign br_j_addr_o = is_jalr_inst_i ? (alu_out_o & 0'hFFFFFFFE) : pc_i + imm_i;
	assign e_inst_addr_mis_o = |br_j_addr_o[1:0] && (is_br_inst_i || is_jal_inst_i || is_jalr_inst_i);
	assign is_br_j_taken_o = ((branch_res & is_br_inst_i) | is_jal_inst_i | is_jalr_inst_i) & !e_inst_addr_mis_o;
	assign is_br_j_valid_o = ((branch_res & is_br_inst_i) | is_jal_inst_i | is_jalr_inst_i);


	alu exe_alu (.in0_i(dat_a_i),
			  	 .in1_i(dat_b_i),
			  	 .op_i(alu_op_i),
			  	 .equ_o(alu_equ),
			  	 .lt_o(alu_lt),
			  	 .ltu_o(alu_ltu),
			  	 .out_o(alu_out_o));

	branch_unit exe_branch_unit (.branch_op_i(funct3_i),
                                 .equ_i(alu_equ),
                                 .lt_i(alu_lt),
                                 .ltu_i(alu_ltu),
                                 .is_branch_taken_o(branch_res));

endmodule
