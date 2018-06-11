/*
* CSR
* MANUEL HURTADO
*/

//Currently the clk_i and rst_i are only for simulation purposes

module csr(clk_i, rst_i, address_i, data_i, we_i, we_exc_i, mcause_d_i, mepc_d_i, mtval_d_i,
            mstatus_d_i, data_out_o, mtvec_o);
    
    // CSR Address
    localparam MISA_ADDR       = 'h301;
    localparam MVENDORID_ADDR  = 'hF11;
    localparam MARCHID_ADDR    = 'hF12;
    localparam MIMPID_ADDR     = 'hF13;
    localparam MHARTID_ADDR    = 'hF14;
    localparam MCAUSE_ADDR     = 'h342;
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

    // CSR location in register
    localparam MISA_REG       = 0;
    localparam MVENDORID_REG  = 1;
    localparam MARCHID_REG    = 2;
    localparam MIMPID_REG     = 3;
    localparam MHARTID_REG    = 4;
    localparam MCAUSE_REG     = 5;
    localparam MSTATUS_REG    = 6;
    localparam MTVEC_REG      = 7;
    localparam MEPC_REG       = 8;
    localparam MIP_REG        = 9;
    localparam MIE_REG        = 10;
    localparam MCYCLE_REG     = 11;
    localparam MYCLEH_REG     = 12;
    localparam MINSTRET_REG   = 13;
    localparam MINSTRETH_REG  = 14;
    localparam MCOUNTEREN_REG = 15;
    
    
    input clk_i;
    input rst_i; 

    input we_i;
    input we_exc_i;
    input [31:0] address_i;
    input [31:0] data_i;
    input [31:0] mcause_d_i;
    input [31:0] mepc_d_i;
    input [31:0] mstatus_d_i;
    input [31:0] mtval_d_i;
    output [31:0] data_out_o;
    output [31:0] mtvec_o;
    
   
    reg [31:0] register[31:0]; 


    assign mtvec_o    = register[MTVEC_REG];
    assign data_out_o = register[address_i];


    always @(posedge clk_i) begin
        if (we_i) begin   
            case (address_i) 
                MISA_ADDR       : register[MISA_REG]       <= data_i; // 1 misa			 0x301
                MVENDORID_ADDR  : register[MVENDORID_REG]  <= data_i; // 2 mvendorid	 0xF11
                MARCHID_ADDR    : register[MARCHID_REG]    <= data_i; // 3 marchid		 0xF12
                MIMPID_ADDR     : register[MIMPID_REG]     <= data_i; // 4 mimpid 		 0xF13
                MHARTID_ADDR    : register[MHARTID_REG]    <= data_i; // 5 mhartid		 0xF14
                MCAUSE_ADDR     : register[MCAUSE_REG]     <= data_i; // 6 mcause		 0x342
                MSTATUS_ADDR    : register[MSTATUS_REG]    <= data_i; // 7 mtatus		 0x300
                MTVEC_ADDR      : register[MTVEC_REG]      <= data_i; // 8 mtvec		 0x305
                MEPC_ADDR       : register[MEPC_REG]       <= data_i; // 9 mepc			 0x341
                MIP_ADDR        : register[MIP_REG]        <= data_i; // 10 mip 		 0x344
                MIE_ADDR        : register[MIE_REG]        <= data_i; // 11 mie_ADDR 	 0x304
                MCYCLE_ADDR     : register[MCYCLE_REG]     <= data_i; // 12 mcycle_ADDR  0xB00
                MYCLEH_ADDR     : register[MYCLEH_REG]     <= data_i; // 13 mycleh_ADDR  0xB80
                MINSTRET_ADDR   : register[MINSTRET_REG]   <= data_i; // 14 minstret 	 0xB02
                MINSTRETH_ADDR  : register[MINSTRETH_REG]  <= data_i; // 15 minstreth 	 0xB82
                MCOUNTEREN_ADDR : register[MCOUNTEREN_REG] <= data_i; // 16 mcounteren   0x306
                default;
            endcase 
        end

        if (we_exc_i) begin
            register[MEPC_REG]    <= mepc_d_i;
            register[MCAUSE_REG]  <= mcause_d_i;
            register[MSTATUS_REG] <= mstatus_d_i;
        end
    end
endmodule
