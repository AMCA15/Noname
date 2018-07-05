/*
* Write Back Stage
* Anderson Contreras
*/

module stage_wb (clk_i, rst_i, pc_i, instruction_i, rs1_i, funct3_i, alu_d_i, mem_d_i, mem_addr_i, csr_addr_i, csr_data_i,
                 xint_meip_i, xint_mtip_i, xint_msip_i, e_illegal_inst_i, e_inst_addr_mis_i, e_ld_addr_mis_i, e_st_addr_mis_i,
                 rd_o, rf_wd_o, we_rf_o, mtvec_o, is_exc_taken_o);

    // Opcodes used for wb
    localparam OP       = 7'b0110011;
    localparam OPI      = 7'b0010011;
    localparam LUI      = 7'b0110111;
    localparam AUIPC    = 7'b0010111;
    localparam LOAD     = 7'b0000011;
    localparam SYSTEM   = 7'b1110011;
    localparam JAL      = 7'b1101111;
    localparam JALR     = 7'b1100111;

    //Privileged 
    localparam URET     = 12'b000000000010;
    localparam SRET     = 12'b000100000010;
    localparam MRET     = 12'b001100000010;
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
    output [31:0] mtvec_o;
    output is_exc_taken_o;

    wire [6:0]opcode = instruction_i[6:0];
    wire is_csr   = (opcode == SYSTEM) && |funct3_i; 
    wire is_load  = (opcode == LOAD); 
    wire is_op    = (opcode == OP); 
    wire is_opi   = (opcode == OPI); 
    wire is_lui   = (opcode == LUI); 
    wire is_auipc   = (opcode == AUIPC);  

    reg [31:0] mcause, mstatus, mtval, csr_out;
    wire aux;
    wire [11:0] xret = instruction_i[31:20];


    csr wb_csr (.clk_i(clk_i),
                .rst_i(rst_i),
                .funct3_i(funct3_i),
                .addr_i(csr_addr_i),
                .data_i(csr_data_i),
                .is_csr_i(is_csr),
                .rs1_i(rs1_i),
                .we_exc_i(is_exc_taken_o),
                .mcause_d_i(mcause),
                .mepc_d_i(pc_i),
                .mtval_d_i(mtval),
                .mstatus_d_i(mstatus),
                .aux_i(aux),
                .data_out_o(csr_out),
                .mtvec_o(mtvec_o));
    

    // Exception encoder
    always @(*) begin
        /* verilator lint_off CASEINCOMPLETE */
        case(1'b1)
            e_illegal_inst_i: begin
                mcause = 2;
                mtval  = instruction_i;
            end
            e_inst_addr_mis_i: begin
                mcause = 0;
                mtval  = pc_i;
            end
            e_ld_addr_mis_i: begin   
                mcause = 4;
                mtval  = mem_addr_i;
            end
            e_st_addr_mis_i: begin
                mcause = 06;
                mtval  = mem_addr_i;
            end
        endcase  
        if((opcode == SYSTEM) && (funct3_i == 0)) begin
            case (xret)
                // Me lo intente copiar del Algol :v
                ECALL: begin
                    aux = 1;
                    mcause = 11;    //Machine external interrupt
                    mtval  = 0;
                    end 
                EBREAK: begin
                    aux = 1;
                    mcause = 3;
                    mtval  = pc_i;
                    end 
                default;
            endcase // xret
        end 

        /* verilator lint_on CASEINCOMPLETE */
 
        is_exc_taken_o = e_illegal_inst_i | e_inst_addr_mis_i | e_ld_addr_mis_i | e_st_addr_mis_i | aux;

 
    end
    wire is_xret;
    assign is_xret = (xret == |{MRET,URET,SRET}) ? 1 : 0;
    // Write-Back Mux
    always @(*) begin
        /* verilator lint_off CASEINCOMPLETE */
            rd_o = instruction_i[11:7];
            aux = 0;
        case (opcode)
            OP:                   rf_wd_o = alu_d_i;
            OPI:                  rf_wd_o = alu_d_i;
            LUI:                  rf_wd_o = alu_d_i;
            AUIPC:                rf_wd_o = alu_d_i;
            LOAD:                 rf_wd_o = mem_d_i;
            SYSTEM: begin    
                    if(is_csr)    rf_wd_o <= csr_out;
                    if(is_xret)   aux = 1; //mtvec_o <= mepc; 
                    end             
            JAL:                  rf_wd_o = pc_i + 32'b100;
            JALR:                 rf_wd_o = pc_i + 32'b100;
        endcase
        /* verilator lint_on CASEINCOMPLETE */

        // Check if we need/can write to the registers
        we_rf_o = ((is_op || is_opi || is_load || is_csr || is_lui || is_auipc) && !is_exc_taken_o) ? 1 : 0;
    end

endmodule
