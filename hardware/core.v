/*
* Core
* Anderson Contreras
*/


// TODO:
// -Add forwarding

module core (clk_i, rst_i, iwbm_ack_i, iwbm_err_i, iwbm_dat_i, iwbm_cyc_o, iwbm_stb_o, iwbm_addr_o,
			 dwbm_ack_i, dwbm_err_i, dwbm_dat_i, dwbm_we_o, dwbm_cyc_o, dwbm_stb_o, dwbm_sel_o, dwbm_addr_o, dwbm_dat_o,
			 xint_meip_i, xint_mtip_i, xint_msip_i);

	parameter HART_ID;
	parameter RESET_ADDR;
	parameter ENABLE_COUNTERS;
	parameter ENABLE_M_ISA;
	parameter UCONTROL;

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
	output [2:0] dwbm_sel_o;
	output [31:0] dwbm_addr_o;
	output [31:0] dwbm_dat_o;
	// Interrupts
	input xint_meip_i;
	input xint_mtip_i;
	input xint_msip_i;

	//***************************************************************//
	// 						   Registers							 //
	//***************************************************************//

	// TODO: 
	// - Encode the fields of the registers, this implementation
	//   is easier for update the registers but we need to be very
	//   careful with the encoding to not mismatch the fields between stages
	// - Encode the nop instruction in each register
	
	//----------------------   IF/ID   ------------------------------
	wire if_id_stall;
	wire if_id_flush;
	wire [63:0] if_id_i = {if_id_instruction_i, if_id_pc_i};
	reg [63:0] if_id_o;

	//----------------------   ID/EXE  ------------------------------
	wire id_exe_stall;
	wire id_exe_flush;
	wire [185:0] id_exe_i = {id_exe_funct3_i, id_exe_rd_i, id_exe_alu_op_i, id_exe_csr_addr_i, id_exe_dat_a_i, id_exe_dat_b_i, id_exe_is_lui_i, id_exe_is_auipc_i,
							 id_exe_is_jal_i, id_exe_is_jalr_i, id_exe_is_branch_i,	id_exe_is_mem_i, id_exe_we_mem_i, id_exe_is_misc_mem_i, id_exe_is_mem_i,
							 id_exe_e_illegal_inst_i, if_id_o};
	reg [185:0] id_exe_o;

	//----------------------   EXE/MEM  -----------------------------
	wire exe_mem_stall;
	wire exe_mem_flush;
	wire [300:0] exe_mem_i;

	reg [300:0] exe_mem_o;

	//----------------------   MEM/WB  ------------------------------
	wire mem_wb_stall;
	wire mem_wb_flush;
	wire [400:0] mem_wb_i;
	reg [400:0] mem_wb_o;

	
	// Register behaviors
	always @(posedge clk_i) begin
		// IF/ID
		if (!if_id_stall)
			if_id_o <= if_id_i;
		else if (if_id_flush)
			if_id_o <= 63'b0;
		// ID/EXE
		if (!id_exe_stall)
			if_id_o <= if_id_i;
		else if (id_exe_flush)
			if_id_o <= 185'b0;
		// EXE/MEM
		if (!exe_mem_stall)
			if_id_o <= if_id_i;
		else if (exe_mem_flush)
			if_id_o <= 300'b0;
		// MEM/WB
		if (!mem_wb_stall)
			if_id_o <= if_id_i;
		else if (mem_wb_flush)
			if_id_o <= 400'b0;
	end




	//***************************************************************//
	// 						     Stages 							 //
	//***************************************************************//
	
	// TODO
	// - Add Stage-MEM and Stage-WB
	
	// - Include all the wire for the connections between register
	//---------------------------------------------------------------
	// 						    Stage-IF

	wire [31:0] if_br_j_addr;
	wire [31:0] if_exception_addr;
	wire [1:0] if_sel_addr;
	wire [31:0] if_id_instruction_i;
	wire [31:0] if_id_pc_i;

	/* verilator lint_off PINMISSING */
	stage_if core_stage_if(.clk_i(clk_i),
						   .rst_i(rst_i),
						   .br_j_addr_i(if_br_j_addr),
						   .exception_addr_i(if_exception_addr),
						   .sel_addr_i(if_sel_addr),
						   .stall_i(if_id_stall),
						   .instruction_o(if_id_instruction_i),
						   .pc_o(if_id_pc_i),
						   .wbm_ack_i(iwbm_ack_i),
						   .wbm_cyc_o(iwbm_cyc_o),
						   .wbm_stb_o(iwbm_stb_o),
						   .wbm_addr_o(iwbm_addr_o));
	/* verilator lint_on PINMISSING */




	//---------------------------------------------------------------
	// 						   Stage-ID

	wire [4:0] rf_w;
	wire [31:0] rf_wd;
	wire rf_we;
	wire is_fwd_a;
	wire is_fwd_b;
	wire [31:0] dat_fwd_a;
	wire [31:0] dat_fwd_b;
	wire [2:0] id_exe_funct3_i;
	wire [4:0] id_exe_rd_i;
	wire [3:0] id_exe_alu_op_i;
	wire [31:0] id_exe_csr_addr_i;
	wire [31:0] id_exe_dat_a_i;
	wire [31:0] id_exe_dat_b_i;
	wire id_exe_is_lui_i;
	wire id_exe_is_auipc_i;
	wire id_exe_is_jal_i;
	wire id_exe_is_jalr_i;
	wire id_exe_is_branch_i;
    wire id_exe_is_mem_i;
	wire id_exe_we_mem_i;
	wire id_exe_is_misc_mem_i;
	wire id_exe_is_system_i;
	wire id_exe_e_illegal_inst_i;

	stage_id core_stage_id(.clk_i(clk_i),
						   .rst_i(rst_i),
						   .instruction_i(if_id_o[63:32]),
						   .pc_i(if_id_o[31:0]),
						   .rd_i(rf_w),
						   .rf_wd_i(rf_wd),
						   .rf_we_i(rf_we),
						   .is_fwd_a_i(is_fwd_a),
						   .is_fwd_b_i(is_fwd_b),
						   .dat_fwd_a_i(dat_fwd_a),
						   .dat_fwd_b_i(dat_fwd_b),
						   .funct3_o(id_exe_funct3_i),
						   .rd_o(id_exe_rd_i),
						   .alu_op_o(id_exe_alu_op_i),
						   .csr_addr_o(id_exe_csr_addr_i),
						   .dat_a_o(id_exe_dat_a_i),
						   .dat_b_o(id_exe_dat_b_i),
						   .is_lui_o(id_exe_is_lui_i),
						   .is_auipc_o(id_exe_is_auipc_i),
						   .is_jal_o(id_exe_is_jal_i),
						   .is_jalr_o(id_exe_is_jalr_i),
						   .is_branch_o(id_exe_is_branch_i),
						   .is_mem_o(id_exe_is_mem_i),
						   .we_mem_o(id_exe_we_mem_i),
						   .is_misc_mem_o(id_exe_is_misc_mem_i),
						   .is_system_o(id_exe_is_system_i),
						   .e_illegal_inst_o(id_exe_e_illegal_inst_i));




	//---------------------------------------------------------------
	// 						   Stage-EXE

	stage_exe core_stage_exe(.clk_i(clk_i),
							 .rst_i(rst_i),
							 .pc_i(id_exe_o[31:0]),
							 .imm_i(),
							 .dat_a_i(),
							 .dat_b_i(),
							 .alu_op_i(),
							 .funct3_i(id_exe_o[185]),
							 .is_jal_inst_i(),
							 .is_jalr_inst_i(),
							 .is_br_inst_i(),
							 .is_br_j_taken_o(),
							 .e_inst_addr_mis_o(),
							 .br_j_addr_o(),
							 .alu_out_o());

	//---------------------------------------------------------------
	// 						   Stage-MEM

	stage_mem core_stage_mem(.clk_i(clk_i),
							 .rst_i(rst_i),
							 .is_mem_i(),
							 .we_mem_i(),
							 .funct3_i(),
							 .mem_data_i(),
							 .mem_addr_i(),
							 .mem_data_o(),
							 .wbm_dat_i(dwbm_dat_i),
							 .wbm_ack_i(dwbm_ack_i),
							 .wbm_err_i(dwbm_err_i),
							 .wbm_re_i(),
							 .wbm_cyc_o(dwbm_cyc_o),
							 .wbm_stb_o(dwbm_stb_o),
							 .wbm_dat_o(dwbm_dat_o),
							 .wbm_addr_o(dwbm_addr_o),
							 .wbm_we_o(dwbm_we_o),
							 .wbm_sel_o(dwbm_sel_o),
							 .e_ld_addr_mis_o(),
							 .e_st_addr_mis_o());

	//---------------------------------------------------------------
	// 						   Stage-WB




endmodule
