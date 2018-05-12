/*
* Instruction Fetch Stage
* Anderson Contreras
*/

module stage_if(clk_i, rst_i, branch_addr_i, sel_addr_i, stall_i, mis_addr_exc_o, pc_o);
  input clk_i;
  input rst_i;

  input [31:0] branch_addr_i;
  input sel_addr_i;
  input stall_i;
  output mis_addr_exc_o;
  output [31:0] pc_o;

  reg [31:0] PC = 0;

  assign pc_o = PC;
  assign mis_addr_exc_o = PC[0] | PC[1];

  always @(posedge clk_i) begin
    if(!rst_i & !stall_i)
      PC = (sel_addr_i) ? branch_addr_i : PC + 4;
  end
endmodule
