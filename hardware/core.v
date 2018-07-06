/*
* Core
* Anderson Contreras
*/

`include "defines.v"
// Debug
module core (clk_i, rst_i, iwbm_ack_i, iwbm_err_i, iwbm_dat_i, iwbm_cyc_o, iwbm_stb_o, iwbm_addr_o,
			 dwbm_ack_i, dwbm_err_i, dwbm_dat_i, dwbm_we_o, dwbm_cyc_o, dwbm_stb_o, dwbm_sel_o, dwbm_addr_o, dwbm_dat_o,
			 xint_meip_i, xint_mtip_i, xint_msip_i);

	parameter [31:0] HART_ID          = 0;
	parameter [31:0] RESET_ADDR       = 32'h8000_0000;
	parameter [0:0]  ENABLE_COUNTERS  = 1;
	parameter [0:0]  ENABLE_M_ISA     = 1;
	parameter 		 UCONTROL         = "ucontrol.list";

	input clk_i;
    input rst_i;

	// Instruction memory port
	input iwbm_ack_i;
	input iwbm_err_i;
	input [31:0] iwbm_dat_i;
	output iwbm_cyc_o;
	output iwbm_stb_o;
	output [31:0] iwbm_addr_o;
	// Data memory port
	input dwbm_ack_i;
	input dwbm_err_i;
	input [31:0] dwbm_dat_i;
	output dwbm_we_o;
	output dwbm_cyc_o;
	output dwbm_stb_o;
	output [3:0] dwbm_sel_o;
	output [31:0] dwbm_addr_o;
	output [31:0] dwbm_dat_o;
	// Interrupts
	input xint_meip_i;
	input xint_mtip_i;
	input xint_msip_i;

	//***************************************************************//
	// 						   Registers							 //
	//***************************************************************//

	//---------------------------------------------------------------
	// 						       IF/ID
	wire if_id_stall = (fwd_stall || id_exe_stall) && !if_id_flush;
	wire if_id_flush = is_br_j_taken || is_exc_taken || (iwbm_cyc_o && !if_id_stall);
	wire [63:0] if_id_i = {if_id_pc_i, if_id_instruction_i};
	reg  [63:0] if_id_o;
	
	// Signals
	wire [31:0] if_id_instruction_i;
	wire [31:0] if_id_pc_i;

	//---------------------------------------------------------------
	// 						       ID/EXE
	wire id_exe_stall = exe_mem_stall;
	wire id_exe_flush = is_br_j_taken | is_exc_taken || (if_id_stall && !id_exe_stall);
	wire [268:0] id_exe_i = {id_exe_funct3_i, id_exe_rs1_i, id_exe_rs2_i, id_exe_rd_i, id_exe_rs1_dat_i, id_exe_rs2_dat_i, id_exe_alu_op_i,
 							 id_exe_csr_addr_i, id_exe_dat_a_i, id_exe_dat_b_i, id_exe_imm_out_i, id_exe_is_op_i, id_exe_is_lui_i, id_exe_is_auipc_i,
 							 id_exe_is_jal_i, id_exe_is_jalr_i, id_exe_is_branch_i, id_exe_is_ld_mem_i, id_exe_is_st_mem_i,
 							 id_exe_is_misc_mem_i, id_exe_is_system_i, id_exe_e_illegal_inst_i, if_id_o};
	reg  [268:0] id_exe_o;


	// Signals
	wire [2:0] id_exe_funct3_i;
	wire [4:0] id_exe_rs1_i;
	wire [4:0] id_exe_rs2_i;
	wire [4:0] id_exe_rd_i;
	wire [31:0] id_exe_rs1_dat_i;
	wire [31:0] id_exe_rs2_dat_i;
	wire [3:0] id_exe_alu_op_i;
	wire [11:0] id_exe_csr_addr_i;
	wire [31:0] id_exe_dat_a_i;
	wire [31:0] id_exe_dat_b_i;
	wire [31:0] id_exe_imm_out_i;
	wire id_exe_is_op_i;
	wire id_exe_is_lui_i;	
	wire id_exe_is_auipc_i;
	wire id_exe_is_jal_i;
	wire id_exe_is_jalr_i;
	wire id_exe_is_branch_i;
    wire id_exe_is_ld_mem_i;
	wire id_exe_is_st_mem_i;
	wire id_exe_is_misc_mem_i;
	wire id_exe_is_system_i;
	wire id_exe_e_illegal_inst_i;

	//---------------------------------------------------------------
	// 						      EXE/MEM
	wire exe_mem_stall = mem_wb_stall;
	wire exe_mem_flush = is_exc_taken;
	wire [301:0] exe_mem_i = {exe_mem_e_inst_addr_mis_o, exe_mem_alu_out_i, id_exe_o};
	reg  [301:0] exe_mem_o;

	// Signals
	wire exe_mem_e_inst_addr_mis_o;
	wire [31:0] exe_mem_alu_out_i;


	//---------------------------------------------------------------
	// 						      MEM/WB
	wire mem_wb_stall = dwbm_cyc_o;
	wire mem_wb_flush = is_exc_taken || (dwbm_cyc_o);
	wire [335:0] mem_wb_i = {mem_wb_mem_data_i, mem_wb_e_ld_addr_mis_i, mem_wb_e_st_addr_mis_i, exe_mem_o};
	reg  [335:0] mem_wb_o;

	// Signals
	wire [31:0] mem_wb_mem_data_i;
	wire mem_wb_e_ld_addr_mis_i;
	wire mem_wb_e_st_addr_mis_i;

	//---------------------------------------------------------------

	// Register behaviors
	always @(posedge clk_i) begin
		if_id_o   <= (rst_i || if_id_flush)   ? `NOP : (if_id_stall)   ? if_id_o   : if_id_i;
		id_exe_o  <= (rst_i || id_exe_flush)  ? `NOP : (id_exe_stall)  ? id_exe_o  : id_exe_i;
		exe_mem_o <= (rst_i || exe_mem_flush) ? `NOP : (exe_mem_stall) ? exe_mem_o : exe_mem_i;
		mem_wb_o  <= (rst_i || mem_wb_flush)  ? `NOP : (mem_wb_stall)  ? mem_wb_o  : mem_wb_i;
	end



	//***************************************************************//
	// 						     Wires  							 //
	//***************************************************************//

	//---------------------------------------------------------------
	// 						    Stage-IF
	wire [31:0] br_j_addr;
	wire [31:0] exc_ret_addr;

	//---------------------------------------------------------------
	// 						   Stage-ID
	wire [4:0] rf_w;
	wire [31:0] rf_wd;
	wire rf_we;
	wire is_fwd_a;
	wire is_fwd_b;
	wire [31:0] dat_fwd_a;
	wire [31:0] dat_fwd_b;
	wire fwd_stall;

	//---------------------------------------------------------------
	// 						   Stage-EXE
	wire is_br_j_taken;

	//---------------------------------------------------------------
	// 						   Stage-MEM
	wire [31:0] mem_fwd_dat;
	//---------------------------------------------------------------
	// 						   Stage-WB
	wire is_exc_taken;


	//***************************************************************//
	// 						   Forwarding 							 //
	//***************************************************************//

	fwd_unit core_fwd_unit(.EX_rd(id_exe_o[`R_RD]),
						   .MEM_rd(exe_mem_o[`R_RD]),
						   .WB_rd(mem_wb_o[`R_RD]),
						   .EX_inst({id_exe_o[`R_IS_LD_MEM], (id_exe_o[`R_IS_OP] || id_exe_o[`R_IS_LUI] || id_exe_o[`R_IS_AUIPC])}),
						   .MEM_inst({exe_mem_o[`R_IS_LD_MEM], (exe_mem_o[`R_IS_OP] || exe_mem_o[`R_IS_LUI] || exe_mem_o[`R_IS_AUIPC])}),
						   .EX_dat(exe_mem_i[`R_ALU_OUT]),
						   .MEM_dat(mem_fwd_dat),
						   .WB_dat(rf_wd),
						   .mem_ack(dwbm_ack_i),
						   .rs1(id_exe_rs1_i),
						   .rs2(id_exe_rs2_i),						   
						   .is_fwd_a_o(is_fwd_a),
						   .is_fwd_b_o(is_fwd_b),
						   .dat_fwd_a_o(dat_fwd_a),
						   .dat_fwd_b_o(dat_fwd_b),
						   .stall(fwd_stall));

	//***************************************************************//
	// 						     Stages 							 //
	//***************************************************************//
	
	//---------------------------------------------------------------
	// 						    Stage-IF

	/* verilator lint_off PINMISSING */
	stage_if #(.RESET_ADDR(RESET_ADDR[31:0]))
		     core_stage_if(.clk_i(clk_i),
						   .rst_i(rst_i),
						   .br_j_addr_i(br_j_addr),
						   .exc_ret_addr_i(exc_ret_addr),
						   .sel_addr_i({is_exc_taken, is_br_j_taken}),
						   .stall_i(if_id_stall),
						   .instruction_o(if_id_instruction_i),
						   .pc_o(if_id_pc_i),
						   .wbm_dat_i(iwbm_dat_i),
						   .wbm_ack_i(iwbm_ack_i),
						   .wbm_err_i(iwbm_err_i),
						   .wbm_cyc_o(iwbm_cyc_o),
						   .wbm_stb_o(iwbm_stb_o),
						   .wbm_addr_o(iwbm_addr_o));
	/* verilator lint_on PINMISSING */


	//---------------------------------------------------------------
	// 						   Stage-ID

	stage_id core_stage_id(.clk_i(clk_i),
						   .instruction_i(if_id_o[`R_INSTRUCTION]),
						   .pc_i(if_id_o[`R_PC]),
						   .rd_i(rf_w),
						   .rf_wd_i(rf_wd),
						   .rf_we_i(rf_we),
						   .is_fwd_a_i(is_fwd_a),
						   .is_fwd_b_i(is_fwd_b),
						   .dat_fwd_a_i(dat_fwd_a),
						   .dat_fwd_b_i(dat_fwd_b),
						   .funct3_o(id_exe_funct3_i),
						   .rs1_o(id_exe_rs1_i),
						   .rs2_o(id_exe_rs2_i),
						   .rd_o(id_exe_rd_i),
						   .rs2_dat_o(id_exe_rs2_dat_i),
						   .rs1_dat_o(id_exe_rs1_dat_i),
						   .alu_op_o(id_exe_alu_op_i),
						   .csr_addr_o(id_exe_csr_addr_i),
						   .dat_a_o(id_exe_dat_a_i),
						   .dat_b_o(id_exe_dat_b_i),
						   .imm_out_o(id_exe_imm_out_i),
						   .is_op_o(id_exe_is_op_i),
						   .is_lui_o(id_exe_is_lui_i),
						   .is_auipc_o(id_exe_is_auipc_i),
						   .is_jal_o(id_exe_is_jal_i),
						   .is_jalr_o(id_exe_is_jalr_i),
						   .is_branch_o(id_exe_is_branch_i),
						   .is_ld_mem_o(id_exe_is_ld_mem_i),
						   .is_st_mem_o(id_exe_is_st_mem_i),
						   .is_misc_mem_o(id_exe_is_misc_mem_i),
						   .is_system_o(id_exe_is_system_i),
						   .e_illegal_inst_o(id_exe_e_illegal_inst_i));

	//---------------------------------------------------------------
	// 						   Stage-EXE

	stage_exe core_stage_exe(.pc_i(id_exe_o[`R_PC]),
							 .imm_i(id_exe_o[`R_IMM_OUT]),
							 .dat_a_i(id_exe_o[`R_DAT_A]),
							 .dat_b_i(id_exe_o[`R_DAT_B]),
							 .alu_op_i(id_exe_o[`R_ALU_OP]),
							 .funct3_i(id_exe_o[`R_FUNCT3]),
							 .is_jal_inst_i(id_exe_o[`R_IS_JAL]),
							 .is_jalr_inst_i(id_exe_o[`R_IS_JALR]),
							 .is_br_inst_i(id_exe_o[`R_IS_BRANCH]),
							 .is_br_j_taken_o(is_br_j_taken),
							 .e_inst_addr_mis_o(exe_mem_e_inst_addr_mis_o),
							 .br_j_addr_o(br_j_addr),
							 .alu_out_o(exe_mem_alu_out_i));

	//---------------------------------------------------------------
	// 						   Stage-MEM

	stage_mem core_stage_mem(.clk_i(clk_i),
							 .rst_i(rst_i),
							 .is_ld_mem_i(exe_mem_o[`R_IS_LD_MEM]),
							 .is_st_mem_i(exe_mem_o[`R_IS_ST_MEM]),
							 .funct3_i(exe_mem_o[`R_FUNCT3]),
							 .mem_data_i(exe_mem_o[`R_RS2_DAT]),
							 .mem_addr_i(exe_mem_o[`R_ALU_OUT]),
							 .mem_data_o(mem_wb_mem_data_i),
							 .wbm_dat_i(dwbm_dat_i),
							 .wbm_ack_i(dwbm_ack_i),
							 .wbm_err_i(dwbm_err_i),
							 .wbm_cyc_o(dwbm_cyc_o),
							 .wbm_stb_o(dwbm_stb_o),
							 .wbm_dat_o(dwbm_dat_o),
							 .wbm_addr_o(dwbm_addr_o),
							 .wbm_we_o(dwbm_we_o),
							 .wbm_sel_o(dwbm_sel_o),
							 .e_ld_addr_mis_o(mem_wb_e_ld_addr_mis_i),
							 .e_st_addr_mis_o(mem_wb_e_st_addr_mis_i),
							 .mem_fwd_dat_o(mem_fwd_dat));

	//---------------------------------------------------------------
	// 						   Stage-WB

	stage_wb core_stage_wb(.clk_i(clk_i),
						   .rst_i(rst_i),
						   .pc_i(mem_wb_o[`R_PC]),
						   .instruction_i(mem_wb_o[`R_INSTRUCTION]),
						   .rs1_i(mem_wb_o[`R_RS1]),
						   .funct3_i(mem_wb_o[`R_FUNCT3]),
						   .alu_d_i(mem_wb_o[`R_ALU_OUT]),
						   .mem_d_i(mem_wb_o[`R_MEM_DATA_O]),
						   .mem_addr_i(mem_wb_o[`R_ALU_OUT]),
						   .csr_addr_i(mem_wb_o[`R_CSR_ADDR]),
						   .csr_data_i(mem_wb_o[`R_ALU_OUT]),
						   .is_op_i(mem_wb_o[`R_IS_OP]),
						   .is_lui_i(mem_wb_o[`R_IS_LUI]),
						   .is_auipc_i(mem_wb_o[`R_IS_AUIPC]),
						   .is_ld_mem_i(mem_wb_o[`R_IS_LD_MEM]),
						   .is_system_i(mem_wb_o[`R_IS_SYSTEM]),
						   .is_jal_i(mem_wb_o[`R_IS_JAL]),
						   .is_jalr_i(mem_wb_o[`R_IS_JALR]),
						   .xint_meip_i(xint_meip_i),
						   .xint_mtip_i(xint_mtip_i),
						   .xint_msip_i(xint_msip_i),
						   .e_illegal_inst_i(mem_wb_o[`R_E_ILLEGAL_INST]),
						   .e_inst_addr_mis_i(mem_wb_o[`R_E_INST_ADDR_MIS]),
						   .e_ld_addr_mis_i(mem_wb_o[`R_E_LD_ADDR_MIS]),
						   .e_st_addr_mis_i(mem_wb_o[`R_E_ST_ADDR_MIS]),
						   .rd_o(rf_w),
						   .rf_wd_o(rf_wd),
						   .we_rf_o(rf_we),
						   .exc_ret_addr_o(exc_ret_addr),
						   .is_exc_taken_o(is_exc_taken));

endmodule
