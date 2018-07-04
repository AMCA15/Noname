/*
* CSR
* MANUEL HURTADO
*/

module csr(clk_i, rst_i, funct3_i, addr_i, data_i, is_csr_i, rs1_i, we_exc_i, mcause_d_i, mepc_d_i, mtval_d_i,
            mstatus_d_i, aux_i, data_out_o, mtvec_o);

    // CSR Address
    localparam MISA_ADDR       = 'h301;
    localparam MVENDORID_ADDR  = 'hF11;
    localparam MARCHID_ADDR    = 'hF12;
    localparam MIMPID_ADDR     = 'hF13;
    localparam MHARTID_ADDR    = 'hF14;
    localparam MCAUSE_ADDR     = 'h342;
    localparam MTVAL_ADDR      = 'h343;
    localparam MSTATUS_ADDR    = 'h300;
    localparam MTVEC_ADDR      = 'h305;
    localparam MEPC_ADDR       = 'h341;
    localparam MIP_ADDR        = 'h344;
    localparam MIE_ADDR        = 'h304;
    localparam MCYCLE_ADDR     = 'hB00;
    localparam MYCLEH_ADDR     = 'hB80;
    localparam MINSTRET_ADDR   = 'hB02;
    localparam MINSTRETH_ADDR  = 'hB82;
    localparam MCOUNTEREN_ADDR = 'h306;

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
    input [31:0] mstatus_d_i;
    input [31:0] mtval_d_i;
    input aux_i;
    output reg [31:0] data_out_o;
    output [31:0] mtvec_o;

    reg [31:0] misa;
    reg [31:0] mvendorid;
    reg [31:0] marchid;
    reg [31:0] mimpid;
    reg [31:0] mhartid;
    reg [31:0] mcause;
    reg [31:0] mtval;
    reg [31:0] mstatus;
    reg [31:0] mtvec;
    reg [31:0] mepc;
    reg [31:0] mip;
    reg [31:0] mie;
    reg [31:0] mcycle;
    reg [31:0] mycleh;
    reg [31:0] minstret;
    reg [31:0] minstreth;
    reg [31:0] mcounteren;

    wire is_csrrw = funct3_i[1:0] == CSRRW;
    wire is_csrrs = funct3_i[1:0] == CSRRS;
    wire is_csrrc = funct3_i[1:0] == CSRRC;


    always @(*) begin  
        if(aux_i) 
            mtvec_o <= mepc;
        else      
            mtvec_o <= mtvec;
    end
    
    always @(posedge clk_i) begin
        if (rst_i) begin
    	    misa        <= 0;
            mvendorid   <= 0;
            marchid     <= 0;
            mimpid      <= 0;
            mhartid     <= 0;
            mcause      <= 0;
            mstatus     <= 0;
            mtvec       <= 0;
            mepc        <= 0;
            mip         <= 0;
            mie         <= 0;
            mcycle      <= 0;
            mycleh      <= 0;
            minstret    <= 0;
            minstreth   <= 0;
            mcounteren  <= 0;
        end

        /* verilator lint_off CASEINCOMPLETE */
        // If it's a CSR instruction write the new data in the register
        else if (is_csr_i) begin
            // Read the old data before write
            case (addr_i)
                MISA_ADDR       : data_out_o <= misa;
                MVENDORID_ADDR  : data_out_o <= mvendorid;
                MARCHID_ADDR    : data_out_o <= marchid;
                MIMPID_ADDR     : data_out_o <= mimpid;
                MHARTID_ADDR    : data_out_o <= mhartid;
                MCAUSE_ADDR     : data_out_o <= mcause;
                MTVAL_ADDR      : data_out_o <= mtval;
                MSTATUS_ADDR    : data_out_o <= mstatus;
                MTVEC_ADDR      : data_out_o <= mtvec;
                MEPC_ADDR       : data_out_o <= mepc;
                MIP_ADDR        : data_out_o <= mip;
                MIE_ADDR        : data_out_o <= mie;
                MCYCLE_ADDR     : data_out_o <= mcycle;
                MYCLEH_ADDR     : data_out_o <= mycleh;
                MINSTRET_ADDR   : data_out_o <= minstret;
                MINSTRETH_ADDR  : data_out_o <= minstreth;
                MCOUNTEREN_ADDR : data_out_o <= mcounteren;
            endcase

            if (((!funct3_i[2] && |rs1_i) || (funct3_i[2] && |data_i)) && !is_csrrw) begin
                case (addr_i)
                    MISA_ADDR       : misa         <= is_csrrw ? data_i : (is_csrrs ? misa       | data_i: misa       & ~data_i);
                //  MVENDORID_ADDR  : mvendorid    <= is_csrrw ? data_i : (is_csrrs ? mvendorid  | data_i: mvendorid  & ~data_i);
                //  MARCHID_ADDR    : marchid      <= is_csrrw ? data_i : (is_csrrs ? marchid    | data_i: marchid    & ~data_i);
                //  MIMPID_ADDR     : mimpid       <= is_csrrw ? data_i : (is_csrrs ? mimpid     | data_i: mimpid     & ~data_i);
                //  MHARTID_ADDR    : mhartid      <= is_csrrw ? data_i : (is_csrrs ? mhartid    | data_i: mhartid    & ~data_i);
                    MCAUSE_ADDR     : mcause       <= is_csrrw ? data_i : (is_csrrs ? mcause     | data_i: mcause     & ~data_i);
                    MCAUSE_ADDR     : mtval        <= is_csrrw ? data_i : (is_csrrs ? mtval      | data_i: mtval      & ~data_i);
                    MSTATUS_ADDR    : mstatus      <= is_csrrw ? data_i : (is_csrrs ? mstatus    | data_i: mstatus    & ~data_i);
                    MTVEC_ADDR      : mtvec        <= is_csrrw ? data_i : (is_csrrs ? mtvec      | data_i: mtvec      & ~data_i);
                    MEPC_ADDR       : mepc         <= is_csrrw ? data_i : (is_csrrs ? mepc       | data_i: mepc       & ~data_i);
                    MIP_ADDR        : mip          <= is_csrrw ? data_i : (is_csrrs ? mip        | data_i: mip        & ~data_i);
                    MIE_ADDR        : mie          <= is_csrrw ? data_i : (is_csrrs ? mie        | data_i: mie        & ~data_i);
                    MCYCLE_ADDR     : mcycle       <= is_csrrw ? data_i : (is_csrrs ? mcycle     | data_i: mcycle     & ~data_i);
                    MYCLEH_ADDR     : mycleh       <= is_csrrw ? data_i : (is_csrrs ? mycleh     | data_i: mycleh     & ~data_i);
                    MINSTRET_ADDR   : minstret     <= is_csrrw ? data_i : (is_csrrs ? minstret   | data_i: minstret   & ~data_i);
                    MINSTRETH_ADDR  : minstreth    <= is_csrrw ? data_i : (is_csrrs ? minstreth  | data_i: minstreth  & ~data_i);
                    MCOUNTEREN_ADDR : mcounteren   <= is_csrrw ? data_i : (is_csrrs ? mcounteren | data_i: mcounteren & ~data_i);
                    default;
                endcase
            end
            /* verilator lint_on CASEINCOMPLETE */
        end
        // Update register with the exceptions data
        if (we_exc_i) begin
            mepc    <= mepc_d_i;
            mcause  <= mcause_d_i;
            mstatus <= mstatus_d_i;
            mtval   <= mtval_d_i;
        end
    end
endmodule
