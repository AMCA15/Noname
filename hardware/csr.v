/*
* CSR
* MANUEL HURTADO
*/

//Currently the clk_i and rst_i are only for simulation purposes

module csr(clk_i, rst_i, funct3_i, addr_i, data_i, is_csr_i, we_exc_i, mcause_d_i, mepc_d_i, mtval_d_i,
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

    // CSR Instruction
    localparam CSRRW = 2'b01;
    localparam CSRRS = 2'b10;
    localparam CSRRC = 2'b11;
    
    
    input clk_i;
    input rst_i; 

    input is_csr_i;
    input we_exc_i;
    input [2:0] funct3_i;
    input [31:0] addr_i;
    input [31:0] data_i;
    input [31:0] mcause_d_i;
    input [31:0] mepc_d_i;
    input [31:0] mstatus_d_i;
    input [31:0] mtval_d_i;
    output reg [31:0] data_out_o;
    output [31:0] mtvec_o;
    
   
    reg dat;
    reg [31:0] register[31:0]; 

    assign mtvec_o = register[MTVEC_REG];


    always @(posedge clk_i) begin
        // Read the old data before write
        data_out_o <= register[addr_i];

        // Save the new data in a temporary register
        case (funct3_i[1:0])
            CSRRW: dat <= data_i;
            CSRRS: dat <= register[addr_i] | data_i;
            CSRRC: dat <= register[addr_i] & !data_i;
        endcase

        // If it's a CSR instruction write the new data in the register
        if (is_csr_i) begin   
            case (addr_i) 
                MISA_ADDR       : register[MISA_REG]       <= dat; // 1 misa	            0x301
                MVENDORID_ADDR  : register[MVENDORID_REG]  <= dat; // 2 mvendorid	        0xF11
                MARCHID_ADDR    : register[MARCHID_REG]    <= dat; // 3 marchid		        0xF12
                MIMPID_ADDR     : register[MIMPID_REG]     <= dat; // 4 mimpid 		        0xF13
                MHARTID_ADDR    : register[MHARTID_REG]    <= dat; // 5 mhartid		        0xF14
                MCAUSE_ADDR     : register[MCAUSE_REG]     <= dat; // 6 mcause		        0x342
                MSTATUS_ADDR    : register[MSTATUS_REG]    <= dat; // 7 mtatus		        0x300
                MTVEC_ADDR      : register[MTVEC_REG]      <= dat; // 8 mtvec		        0x305
                MEPC_ADDR       : register[MEPC_REG]       <= dat; // 9 mepc                0x341
                MIP_ADDR        : register[MIP_REG]        <= dat; // 10 mip 		        0x344
                MIE_ADDR        : register[MIE_REG]        <= dat; // 11 mie_ADDR 	        0x304
                MCYCLE_ADDR     : register[MCYCLE_REG]     <= dat; // 12 mcycle_ADDR        0xB00
                MYCLEH_ADDR     : register[MYCLEH_REG]     <= dat; // 13 mycleh_ADDR        0xB80
                MINSTRET_ADDR   : register[MINSTRET_REG]   <= dat; // 14 minstret 	        0xB02
                MINSTRETH_ADDR  : register[MINSTRETH_REG]  <= dat; // 15 minstreth 	        0xB82
                MCOUNTEREN_ADDR : register[MCOUNTEREN_REG] <= dat; // 16 mcounteren         0x306
                default;
            endcase 
        end
        // Update register with the exceptions data
        if (we_exc_i) begin
            register[MEPC_REG]    <= mepc_d_i;
            register[MCAUSE_REG]  <= mcause_d_i;
            register[MSTATUS_REG] <= mstatus_d_i;
        end
    end
endmodule
