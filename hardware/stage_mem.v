/*
* Memory Stage
* Anderson Contreras
*/

module stage_mem(clk_i, rst_i, is_ld_mem_i, is_st_mem_i, funct3_i, mem_data_i, mem_addr_i, mem_data_o,
                 wbm_dat_i, wbm_ack_i, wbm_err_i, wbm_cyc_o, wbm_stb_o, wbm_dat_o,
                 wbm_addr_o, wbm_we_o, wbm_sel_o, e_ld_addr_mis_o, e_st_addr_mis_o, mem_fwd_dat_o);

    input clk_i;
    input rst_i;

    input is_ld_mem_i;
    input is_st_mem_i;
    input [2:0] funct3_i;
    input [31:0] mem_data_i;
    input [31:0] mem_addr_i;
    output [31:0] mem_data_o;
    output e_ld_addr_mis_o;
    output e_st_addr_mis_o;

    // Wishbone interface
    input wbm_ack_i;
    input wbm_err_i;
    input [31:0] wbm_dat_i;
    output wbm_cyc_o;
    output wbm_stb_o;
    output wbm_we_o;
    output [3:0]  wbm_sel_o;
    output [31:0] wbm_dat_o;
    output [31:0] wbm_addr_o;

    //FWD
    output [31:0] mem_fwd_dat_o;

    wire kill;
    wire [3:0]  st_sel;
    wire [31:0] ld_data_fmt;
    wire is_mem = is_st_mem_i || is_ld_mem_i;

    assign wbm_addr_o = mem_addr_i;
    assign wbm_we_o   = is_st_mem_i;
    assign wbm_sel_o  = st_sel;
    assign kill = e_ld_addr_mis_o || e_st_addr_mis_o || rst_i;
    assign mem_fwd_dat_o = is_ld_mem_i? wbm_dat_i : mem_addr_i;


    lsu_comb exe_lsu_comb (.funct3_i(funct3_i),
                           .is_mem_i(is_mem),
                           .st_data_i(mem_data_i),
                           .ld_data_i(wbm_dat_i),
                           .addr_i(mem_addr_i),
                           .st_data_fmt_o(wbm_dat_o),
                           .ld_data_fmt_o(ld_data_fmt),
                           .st_sel_o(st_sel),
                           .e_ld_addr_mis_o(e_ld_addr_mis_o),
                           .e_st_addr_mis_o(e_st_addr_mis_o));

    wbu exe_wbu (.clk_i(clk_i),
                 .rst_i(kill),
                 .wbm_dat_i(wbm_dat_i),
                 .wbm_ack_i(wbm_ack_i),
                 .wbm_err_i(wbm_err_i),
                 .wbm_re_i(is_ld_mem_i),
                 .wbm_cyc_o(wbm_cyc_o),
                 .wbm_stb_o(wbm_stb_o),
                 .wbm_dat_o(wbm_dat_o),
                 .wbm_addr_o(wbm_addr_o),
                 .wbm_we_o(wbm_we_o),
                 .wbm_sel_o(wbm_sel_o));

    always @(negedge clk_i) begin
        if(wbm_ack_i)
            mem_data_o <= ld_data_fmt;
    end

endmodule
