/*
* Instruction Decode Stage
* Anderson Contreras
*/

module stage_id(clk_i, instruction_i, pc_i, rd_i, rf_wd_i, rf_we_i, is_fwd_a_i, is_fwd_b_i, dat_fwd_a_i, dat_fwd_b_i,
                funct3_o, rs1_o, rs2_o, rd_o, rs2_dat_o, alu_op_o, csr_addr_o, dat_a_o, dat_b_o, imm_out_o, is_op_o, is_lui_o, is_auipc_o, is_jal_o, is_jalr_o, is_branch_o,
                is_ld_mem_o, is_st_mem_o, is_misc_mem_o, is_system_o, e_illegal_inst_o);
    
    // Mux control for ALU's inputs
    localparam SEL_REG  = 2'b00;
    localparam SEL_IMM  = 2'b01;
    localparam SEL_PC   = 2'b10;
    localparam SEL_ZERO = 2'b11;
    
    input clk_i;

    input [31:0] instruction_i;
    input [31:0] pc_i;
    input [31:0] rf_wd_i;
    input [4:0]  rd_i;
    input rf_we_i;
    input is_fwd_a_i;
    input is_fwd_b_i;
    input [31:0] dat_fwd_a_i;
    input [31:0] dat_fwd_b_i;
    output [2:0]  funct3_o;
    output [4:0]  rs1_o;
    output [4:0]  rs2_o;
    output [4:0]  rd_o;
    output [31:0] rs2_dat_o;
    output [3:0]  alu_op_o;
    output [11:0] csr_addr_o;
    output [31:0] dat_a_o;
    output [31:0] dat_b_o;
    output [31:0] imm_out_o;
    output is_op_o;
    output is_lui_o;
    output is_auipc_o;
    output is_jal_o;
    output is_jalr_o;
    output is_branch_o;
    output is_ld_mem_o;
    output is_st_mem_o;
    output is_misc_mem_o;
    output is_system_o;
    output e_illegal_inst_o;

    
    wire [2:0]  imm_op;
    wire [31:0] imm_out;
    wire [1:0]  sel_dat_a;
    wire [1:0]  sel_dat_b;
    wire [31:0]  shamt;
    wire [31:0]  shamt_fwd;
    wire is_shift;
    wire [31:0] rs1_dat;
    wire [31:0] rs2_dat;

    assign rs2_dat_o = is_fwd_b_i ? dat_fwd_b_i : rs2_dat;
    assign imm_out_o = imm_out;
    assign shamt     = rs2_dat_o & 32'h1F;
    assign shamt_fwd = dat_fwd_b_i & 32'h1F;
    assign is_shift = (instruction_i[6:0] == 7'b0110011) && ((funct3_o == 0'b001) || (funct3_o == 0'b101));

    decoder id_decoder(.instruction_i(instruction_i),
                       .funct3_o(funct3_o),
                       .rs1_o(rs1_o),
                       .rs2_o(rs2_o),
                       .rd_o(rd_o),
                       .imm_op_o(imm_op),
                       .sel_dat_a_o(sel_dat_a),
                       .sel_dat_b_o(sel_dat_b),
                       .alu_op_o(alu_op_o),
                       .csr_addr_o(csr_addr_o),
                       .is_op_o(is_op_o),
                       .is_lui_o(is_lui_o),
                       .is_auipc_o(is_auipc_o),
                       .is_jal_o(is_jal_o),
                       .is_jalr_o(is_jalr_o),
                       .is_branch_o(is_branch_o),
                       .is_ld_mem_o(is_ld_mem_o),
                       .is_st_mem_o(is_st_mem_o),
                       .is_misc_mem_o(is_misc_mem_o),
                       .is_system_o(is_system_o),
                       .e_illegal_inst_o(e_illegal_inst_o));

    reg_file id_reg_file(.clk_i(clk_i),
                         .rs1_i(rs1_o),
                         .rs2_i(rs2_o),
                         .rd_i(rd_i),
                         .rf_wd_i(rf_wd_i),
                         .we_i(rf_we_i),
                         .rs1_d_o(rs1_dat),
                         .rs2_d_o(rs2_dat));

    imm_gen id_imm_gen(.instruction_i(instruction_i),
                       .imm_op_i(imm_op),
                       .imm_o(imm_out));


    always @(*) begin
        /* verilator lint_off CASEINCOMPLETE */
        // Mux for ALU inputs
        case (sel_dat_a)
            SEL_REG:  dat_a_o = is_fwd_a_i ? dat_fwd_a_i : rs1_dat;
            SEL_IMM:  dat_a_o = imm_out;
            SEL_PC:   dat_a_o = pc_i;
            SEL_ZERO: dat_a_o = 0;
        endcase

        case (sel_dat_b)
            SEL_REG:  dat_b_o =  is_fwd_b_i ? (is_shift ? shamt_fwd : dat_fwd_b_i) : (is_shift ? shamt : rs2_dat);
            SEL_IMM:  dat_b_o = imm_out;
            SEL_PC:   dat_b_o = pc_i;
            SEL_ZERO: dat_b_o = 0;
        endcase
        /* verilator lint_on CASEINCOMPLETE */
    end
endmodule
