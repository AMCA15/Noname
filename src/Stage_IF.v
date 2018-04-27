/*
* Instruction Fetch Stage
* Anderson Contreras
*/

// Actually only contains the PC register and a 4 bytes adder


module StageIF(clk_i, rst_i, out);
  input clk_i;
  input rst_i;

  reg [31:0] PC = 0;
  output wire [31:0] out;

  assign out = PC;

  always @(posedge clk_i) begin
    if(!rst_i)
      PC += 4;
  end
endmodule
