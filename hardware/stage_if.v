/*
* Instruction Fetch Stage
* Anderson Contreras
*/

module stage_if(clk_i, rst_i, br_j_addr_i, exception_addr_i, sel_addr_i, stall_i,
                instruction_o, pc_o, wbm_dat_i, wbm_ack_i, wbm_err_i,
                wbm_cyc_o, wbm_stb_o, wbm_dat_o, wbm_addr_o, wbm_we_o, wbm_sel_o);
  
  parameter [31:0] RESET_ADDR       = 32'h0;

  localparam SECUENTIAL_ADDR = 2'b00;
  localparam BRANCH_ADDR     = 2'b01;
  localparam EXCEPTION_ADDR  = 2'b10;

  input clk_i;
  input rst_i;

  input [31:0] br_j_addr_i;
  input [31:0] exception_addr_i;
  input [1:0] sel_addr_i;
  input stall_i;
  output reg [31:0] instruction_o;
  output reg [31:0] pc_o;

  // Wishbone interface
  input [31:0] wbm_dat_i;
  input wbm_ack_i;
  input wbm_err_i;
  output [31:0] wbm_dat_o;
  output [31:0] wbm_addr_o;
  output [3:0]  wbm_sel_o;
  output wbm_cyc_o;
  output wbm_stb_o;
  output wbm_we_o;
/*----------------------------*/
  wire wbm_re;
  wire [3:0] wbm_sel;


  // Assigns
  assign wbm_re   = 1;
  assign wbm_we_o = 0;
  assign wbm_sel  = 0;
  assign wbm_addr_o = pc_o;


  wbu if_wbu (.clk_i(clk_i),
            .rst_i(rst_i),
            .wbm_dat_i(wbm_dat_i),
            .wbm_ack_i(wbm_ack_i),
            .wbm_err_i(wbm_err_i),
            .wbm_re_i(wbm_re),
            .wbm_dat_o(wbm_dat_o),
            .wbm_addr_o(wbm_addr_o),
            .wbm_sel_o(wbm_sel),
            .wbm_cyc_o(wbm_cyc_o),
            .wbm_stb_o(wbm_stb_o),
            .wbm_we_o(wbm_we_o));

  // PC's
  always @(posedge clk_i) begin
    if (rst_i) begin
      pc_o          = RESET_ADDR - 4;
      instruction_o = `NOP;
    end
    else begin
      case (sel_addr_i)
        SECUENTIAL_ADDR: if (!stall_i && !wbm_cyc_o) pc_o = pc_o + 4;
        BRANCH_ADDR:     pc_o = (!stall_i && !wbm_cyc_o)? br_j_addr_i:br_j_addr_i-4;
        EXCEPTION_ADDR:  pc_o = (!stall_i && !wbm_cyc_o)? exception_addr_i:exception_addr_i-4;
      endcase
    end
  end

  always @(posedge wbm_ack_i) begin
    instruction_o = wbm_ack_i ? wbm_dat_i : instruction_o;
  end

endmodule
