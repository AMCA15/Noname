/*
* Write Back Stage
* Anderson Contreras
*/

module stage_wb (clk_i, rst_i, pc_i, instruction_i, rs1_i, funct3_i, alu_d_i, mem_d_i, mem_addr_i, csr_addr_i, csr_data_i,
                 is_op_i, is_lui_i, is_auipc_i, is_ld_mem_i, is_system_i, is_jal_i, is_jalr_i,
                 xint_meip_i, xint_mtip_i, xint_msip_i, e_illegal_inst_i, e_inst_addr_mis_i, e_ld_addr_mis_i, e_st_addr_mis_i,
                 rd_o, rf_wd_o, we_rf_o, exc_ret_addr_o, is_exc_taken_o);

    localparam ECALL    = 12'b000000000000;
    localparam EBREAK   = 12'b000000000001;

    input clk_i;
    input rst_i;

    input [31:0] pc_i;
    input [31:0] instruction_i;
    input [2:0] funct3_i;
    input [4:0] rs1_i;
    input [31:0] alu_d_i;
    input [31:0] mem_d_i;
    input [31:0] mem_addr_i;
    input [11:0] csr_addr_i;
    input [31:0] csr_data_i;

    input is_op_i;
    input is_lui_i;
    input is_auipc_i;
    input is_ld_mem_i;
    input is_system_i;
    input is_jal_i;
    input is_jalr_i;

    input xint_meip_i;
    input xint_mtip_i;
    input xint_msip_i;
    input e_illegal_inst_i;
    input e_inst_addr_mis_i;
    input e_ld_addr_mis_i;
    input e_st_addr_mis_i;

    output [4:0] rd_o;
    output [31:0] rf_wd_o;
    output we_rf_o;
    output [31:0] exc_ret_addr_o;
    output is_exc_taken_o;

    reg [31:0] mcause, mstatus, mtval, csr_out;


    wire [31:0] mie;
    wire [31:0] mip = {xint_meip_i, 3'b0, xint_mtip_i, 3'b0, xint_msip_i, 3'b0};
    wire e_illegal_inst_csr;
    wire we_exc_csr =   (e_illegal_inst_i | e_inst_addr_mis_i | e_ld_addr_mis_i | e_st_addr_mis_i | e_ecall | e_break);
    wire is_csr     =   is_system_i &&  |funct3_i;
    wire e_ecall    =   is_system_i && !|funct3_i && (instruction_i[31:20] == ECALL);
    wire e_break    =   is_system_i && !|funct3_i && (instruction_i[31:20] == EBREAK);
    wire is_xret    =  (is_system_i && !|funct3_i && |{instruction_i[28:27], instruction_i[21]} && instruction_i[21]) ? 1 : 0;
    wire is_int     = ((mie[11] && xint_meip_i) || (mie[7] && xint_mtip_i) || (mie[3] && xint_msip_i)) ? 1 : 0;

    assign is_exc_taken_o = we_exc_csr | e_illegal_inst_csr | is_xret;
    assign rd_o = instruction_i[11:7];


    csr wb_csr (.clk_i(clk_i),
                .rst_i(rst_i),
                .funct3_i(funct3_i),
                .addr_i(csr_addr_i),
                .data_i(csr_data_i),
                .is_csr_i(is_csr),
                .rs1_i(rs1_i),
                .we_exc_i(we_exc_csr),
                .mcause_d_i(mcause),
                .mepc_d_i(pc_i),
                .mtval_d_i(mtval),
                .mstatus_d_i(mstatus),
                .mip_d_i(mip),
                .sel_exc_nret_i(is_xret),
                .is_int_i(is_int),
                .e_illegal_inst_csr_o(e_illegal_inst_csr),
                .data_out_o(csr_out),
                .mie_o(mie),
                .exc_ret_addr_o(exc_ret_addr_o));
    

    // Exception encoder
    always @(*) begin
        /* verilator lint_off CASEINCOMPLETE */
        case(1'b1)
            e_inst_addr_mis_i: begin
                mcause = 0;
                mtval  = pc_i;
            end
            e_illegal_inst_i: begin
                mcause = 2;
                mtval  = instruction_i;
            end
            e_break: begin
                mcause = 3;
                mtval  = 0;
            end
            e_ld_addr_mis_i: begin   
                mcause = 4;
                mtval  = mem_addr_i;
            end
            e_st_addr_mis_i: begin
                mcause = 6;
                mtval  = mem_addr_i;
            end
            e_ecall: begin
                mcause = 11;
                mtval  = mem_addr_i;
            end
            xint_meip_i: begin
                mcause = 0'h8000000B;
            end
            xint_mtip_i: begin
                mcause = 0'h80000007;
            end
            xint_msip_i: begin
                mcause = 0'h80000003;
            end
        endcase
        /* verilator lint_on CASEINCOMPLETE */
    end
    
    // Write-Back Mux
    always @(*) begin
        // Check if we need/can write to the registers
        we_rf_o = ((is_op_i || is_ld_mem_i || is_csr || is_lui_i || is_auipc_i || is_jal_i || is_jalr_i) && !is_exc_taken_o) ? 1 : 0;

        case (1'b1)
            is_ld_mem_i:                    rf_wd_o = mem_d_i;
            is_csr:                         rf_wd_o = csr_out;             
            is_jal_i|is_jalr_i:             rf_wd_o = pc_i + 4;
            is_op_i|is_lui_i|is_auipc_i:    rf_wd_o = alu_d_i;
            default;
        endcase
    end

endmodule
