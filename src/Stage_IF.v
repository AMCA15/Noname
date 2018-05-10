/*
* Instruction Fetch Stage
* Anderson Contreras
*/

// Actually only contains the PC register and a 4 bytes adder


module StageIF(clk_i, rst_i, branch_addr, sel_addr, stall, mis_addr_exc, out);
  input clk_i;
  input rst_i;

  input [31:0] branch_addr;
  input sel_addr;
  input stall;
  output mis_addr_exc;
  output [31:0] out;

  reg [31:0] PC = 0;

  assign out = PC;
  assign mis_addr_exc = PC[0] | PC[1];

  always @(posedge clk_i) begin
    if(!rst_i & !stall)
      PC = (sel_addr) ? branch_addr : PC + 4;
  end
endmodule
