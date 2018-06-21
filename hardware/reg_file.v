/*
* Register File
* Anderson Contreras
*/

//Currently the clk_i and rst_i are only for simulation purposes

module reg_file(clk_i, rst_i, rs1_i, rs2_i, rd_i, rf_wd_i, we_i, rs1_d_o, rs2_d_o);

  input clk_i;
  input rst_i;

  input we_i;
  input  [4:0]  rs1_i, rs2_i, rd_i;
  input  [31:0] rf_wd_i;
  output [31:0] rs1_d_o, rs2_d_o;
  
  reg [31:0] regfile [0:31];

  assign rs1_d_o = |rs1_i ? regfile[rs1_i] : 32'b0;
  assign rs2_d_o = |rs2_i ? regfile[rs2_i] : 32'b0;

  always @(posedge clk_i) begin
    if (we_i) begin
      regfile[rd_i] <= rf_wd_i;
    end
  end
endmodule