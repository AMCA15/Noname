/*
* CSR
* MANUEL HURTADO
*/

module csr(clk_i, rst_i, funct3_i, addr_i, data_i, is_csr_i, rs1_i, we_exc_i, mcause_d_i, mepc_d_i, mtval_d_i,
           mstatus_d_i, mip_d_i, sel_exc_nret_i, is_int_i, e_illegal_inst_csr_o, data_out_o, mie_o, exc_ret_addr_o);

    // CSR Address
    localparam MISA       = 'h301;
    localparam MEDELEG    = 'h302;
    localparam MIDELEG    = 'h303;
    localparam MVENDORID  = 'hF11;
    localparam MARCHID    = 'hF12;
    localparam MIMPID     = 'hF13;
    localparam MHARTID    = 'hF14;
    localparam MCAUSE     = 'h342;
    localparam MTVAL      = 'h343;
    localparam MSTATUS    = 'h300;
    localparam MTVEC      = 'h305;
    localparam MSCRATCH   = 'h340;
    localparam MEPC       = 'h341;
    localparam MIP        = 'h344;
    localparam MIE        = 'h304;
    localparam MCYCLE     = 'hB00;
    localparam MYCLEH     = 'hB80;
    localparam MINSTRET   = 'hB02;
    localparam MINSTRETH  = 'hB82;
    localparam MCOUNTEREN = 'h306;
    localparam PMPCFG0    = 'h3A0;
    localparam PMPADDR0   = 'h3B0;
    localparam SATP       = 'h180;

    // CSR Instruction
    localparam CSRRW = 2'b01;
    localparam CSRRS = 2'b10;
    localparam CSRRC = 2'b11;


    input clk_i;
    input rst_i;

    input is_csr_i;
    input [4:0] rs1_i;
    input we_exc_i;
    input [2:0] funct3_i;
    input [11:0] addr_i;
    input [31:0] data_i;
    input [31:0] mcause_d_i;
    input [31:0] mepc_d_i;
    input [31:0] mtval_d_i;
    input [31:0] mstatus_d_i;
    input [31:0] mip_d_i;
    input sel_exc_nret_i;
    input is_int_i;
    output e_illegal_inst_csr_o;
    output [31:0] data_out_o;
    output [31:0] mie_o;
    output [31:0] exc_ret_addr_o;

    reg [31:0] misa;
    reg [31:0] medeleg;
    reg [31:0] mideleg;
    reg [31:0] mvendorid;
    reg [31:0] marchid;
    reg [31:0] mimpid;
    reg [31:0] mhartid;
    reg [31:0] mcause;
    reg [31:0] mtval;
    reg [31:0] mstatus;
    reg [31:0] mtvec;
    reg [31:0] mscratch;
    reg [31:0] mepc;
    reg [31:0] mip;
    reg [31:0] mie;
    reg [31:0] mcycle;
    reg [31:0] mycleh;
    reg [31:0] minstret;
    reg [31:0] minstreth;
    reg [31:0] mcounteren;
    reg [31:0] pmpcfg0;
    reg [31:0] pmpaddr0;
    reg [31:0] satp;

    wire is_csrrw = funct3_i[1:0] == CSRRW;
    wire is_csrrs = funct3_i[1:0] == CSRRS;
    wire is_csrrc = funct3_i[1:0] == CSRRC;

    assign exc_ret_addr_o = sel_exc_nret_i ? mepc : mtvec;

    always @(*) begin
        if (rst_i) begin
    	    misa        = 0;
    	    medeleg     = 0;
    	    mideleg     = 0;
            mvendorid   = 0;
            marchid     = 0;
            mimpid      = 0;
            mhartid     = 0;
            mcause      = 0;
            mstatus     = 0;
            mtvec       = 0;
            mscratch    = 0;
            mepc        = 0;
            mip         = 0;
            mie         = 0;
            mcycle      = 0;
            mycleh      = 0;
            minstret    = 0;
            minstreth   = 0;
            mcounteren  = 0;
            pmpcfg0     = 0;
            pmpaddr0    = 0;
            satp        = 0;
        end

        /* verilator lint_off CASEINCOMPLETE */
        // If it's a CSR instruction write the new data in the register
        else if (is_csr_i) begin
            e_illegal_inst_csr_o = 0;
            // Read the old data before write
            case (addr_i)
                MISA       : data_out_o = misa;
                MEDELEG    : data_out_o = medeleg;
                MIDELEG    : data_out_o = mideleg;
                MVENDORID  : data_out_o = mvendorid;
                MARCHID    : data_out_o = marchid;
                MIMPID     : data_out_o = mimpid;
                MHARTID    : data_out_o = mhartid;
                MCAUSE     : data_out_o = mcause;
                MTVAL      : data_out_o = mtval;
                MSTATUS    : data_out_o = mstatus;
                MTVEC      : data_out_o = mtvec;
                MSCRATCH   : data_out_o = mscratch;
                MEPC       : data_out_o = mepc;
                MIP        : data_out_o = mip;
                MIE        : data_out_o = mie;
                MCYCLE     : data_out_o = mcycle;
                MYCLEH     : data_out_o = mycleh;
                MINSTRET   : data_out_o = minstret;
                MINSTRETH  : data_out_o = minstreth;
                MCOUNTEREN : data_out_o = mcounteren;
                PMPCFG0    : data_out_o = pmpcfg0;
                PMPADDR0   : data_out_o = pmpaddr0;
                SATP       : data_out_o = satp;
                default    : e_illegal_inst_csr_o = 1;
            endcase

            if ((!funct3_i[2] && |rs1_i) || (funct3_i[2] && |data_i)) begin
                case (addr_i)
                    MISA       : misa         = is_csrrw ? data_i : (is_csrrs ? misa       | data_i: misa       & ~data_i);
                    MEDELEG    : medeleg      = is_csrrw ? data_i : (is_csrrs ? medeleg    | data_i: medeleg    & ~data_i);
                    MIDELEG    : mideleg      = is_csrrw ? data_i : (is_csrrs ? mideleg    | data_i: mideleg    & ~data_i);
                //  MVENDORID  : mvendorid    = is_csrrw ? data_i : (is_csrrs ? mvendorid  | data_i: mvendorid  & ~data_i);
                //  MARCHID    : marchid      = is_csrrw ? data_i : (is_csrrs ? marchid    | data_i: marchid    & ~data_i);
                //  MIMPID     : mimpid       = is_csrrw ? data_i : (is_csrrs ? mimpid     | data_i: mimpid     & ~data_i);
                //  MHARTID    : mhartid      = is_csrrw ? data_i : (is_csrrs ? mhartid    | data_i: mhartid    & ~data_i);
                    MCAUSE     : mcause       = is_csrrw ? data_i : (is_csrrs ? mcause     | data_i: mcause     & ~data_i);
                    MTVAL      : mtval        = is_csrrw ? data_i : (is_csrrs ? mtval      | data_i: mtval      & ~data_i);
                    MSTATUS    : mstatus      = is_csrrw ? data_i : (is_csrrs ? mstatus    | data_i: mstatus    & ~data_i);
                    MTVEC      : mtvec        = is_csrrw ? data_i : (is_csrrs ? mtvec      | data_i: mtvec      & ~data_i);
                    MSCRATCH   : mscratch     = is_csrrw ? data_i : (is_csrrs ? mscratch   | data_i: mscratch   & ~data_i);
                    MEPC       : mepc         = is_csrrw ? data_i : (is_csrrs ? mepc       | data_i: mepc       & ~data_i);
                //    MIP        : mip          = is_csrrw ? data_i : (is_csrrs ? mip        | data_i: mip        & ~data_i);
                    MIE        : mie          = is_csrrw ? data_i : (is_csrrs ? mie        | data_i: mie        & ~data_i);
                    MCYCLE     : mcycle       = is_csrrw ? data_i : (is_csrrs ? mcycle     | data_i: mcycle     & ~data_i);
                    MYCLEH     : mycleh       = is_csrrw ? data_i : (is_csrrs ? mycleh     | data_i: mycleh     & ~data_i);
                    MINSTRET   : minstret     = is_csrrw ? data_i : (is_csrrs ? minstret   | data_i: minstret   & ~data_i);
                    MINSTRETH  : minstreth    = is_csrrw ? data_i : (is_csrrs ? minstreth  | data_i: minstreth  & ~data_i);
                    MCOUNTEREN : mcounteren   = is_csrrw ? data_i : (is_csrrs ? mcounteren | data_i: mcounteren & ~data_i);
                    PMPCFG0    : pmpcfg0      = is_csrrw ? data_i : (is_csrrs ? pmpcfg0    | data_i: pmpcfg0    & ~data_i);
                    PMPADDR0   : pmpaddr0     = is_csrrw ? data_i : (is_csrrs ? pmpaddr0   | data_i: pmpaddr0   & ~data_i);
                    SATP       : satp         = is_csrrw ? data_i : (is_csrrs ? satp       | data_i: satp       & ~data_i);
                    default;
                endcase
            end
            /* verilator lint_on CASEINCOMPLETE */
        end
        // Update register with the exceptions data
        if (we_exc_i) begin
            mepc    = mepc_d_i;
            mcause  = mcause_d_i;
            mstatus = mstatus_d_i;
            mtval   = mtval_d_i;
        end

        if (is_int_i) begin
            mcause = mcause_d_i;
            mip = mip_d_i;
        end

    end
endmodule
