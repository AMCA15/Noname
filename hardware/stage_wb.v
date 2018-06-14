/*
* Write Back Stage
* Anderson Contreras
*/

module stage_wb (clk_i, rst_i, pc_i, instruction_i, funct3_i, alu_d_i, mem_d_i, mem_addr_i, csr_addr_i, 
                 e_illegal_inst_i, e_inst_addr_mis_i, e_ld_addr_mis_i, e_st_addr_mis_i, rd_o, rf_wd_o, we_rf_o, mtvec_o);

    // Opcodes used for wb
    localparam OP       = 7'b0110011;
    localparam LOAD     = 7'b0000011;
    localparam SYSTEM   = 7'b1110011;

    input clk_i;
    input rst_i;

    input [31:0] pc_i;
    input [31:0] instruction_i;
    input [2:0] funct3_i;
    input [31:0] alu_d_i;
    input [31:0] mem_d_i;
    input [31:0] mem_addr_i;
    input [31:0] csr_addr_i;
    input e_illegal_inst_i;
    input e_inst_addr_mis_i;
    input e_ld_addr_mis_i;
    input e_st_addr_mis_i;

    output [4:0] rd_o;
    output [31:0] rf_wd_o;
    output we_rf_o;
    output [31:0] mtvec_o;



    wire is_csr, csr_we_exc;
    wire [31:0] mcause; 

    reg [31:0] mstatus, mtval, csr_out;


    csr wb_csr (.clk_i(clk_i),
                .rst_i(rst_i),
                .addr_i(csr_addr_i),
                .data_i(csr_data_i),
                .is_csr_i(is_csr),
                .we_exc_i(csr_we_exc),
                .mcause_d_i(mcause),
                .mepc_d_i(pc_i),
                .mtval_d_i(mtval),
                .mstatus_d_i(mstatus),
                .data_out_o(csr_out),
                .mtvec_o(mtvec_o));
    

    // Exception encoder
    always @(*) begin
        case(1'b1)
            e_illegal_inst_i:  mcause = 2;
            e_inst_addr_mis_i: mcause = 0;
            e_ld_addr_mis_i:   mcause = 4;
            e_st_addr_mis_i:   mcause = 06;
        endcase  
        csr_we_exc = e_ld_addr_mis_i | e_inst_addr_mis_i | e_ld_addr_mis_i | e_st_addr_mis_i;
    end


    // Write-Back Mux
    always @(*) begin
        case (1'b1)
            funct3_i && OP:                rf_wd_o = alu_d_i;
            funct3_i && LOAD:              rf_wd_o = mem_d_i;
            (funct3_i && SYSTEM) & is_csr: rf_wd_o = csr_out;
        endcase
        // Check if we need/can write to the registers
        we_rf_o = (((OP || LOAD || (SYSTEM && is_csr))) && !csr_we_exc) ? 1 : 0;
    end

endmodule
