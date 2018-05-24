/*
*Branch Unit
*It evaluates whether the branch condition is asserted so that the branch is taken
*By Adrián González
*
*This module is supposed to be asyncronous, clock and reset signals are for simulation purposes
*
*/


module branch_unit2 (clk_i, branch_op_i, rst_i, equ_i, lt_i, ltu_i, is_branch_taken_o);
	input clk_i;   
	input rst_i;  

	//Signals provided by the ALU after the condition is evaluated	
	input equ_i;	//Asserted if rs1 = rs2
	input lt_i;		//Asserted if rs1 < rs2
	input ltu_i;	//Asserted if rs1 < rs2 (unsigned)

	input [2:0] branch_op_i; //func3 field. For differentiation between beq,bne,blt,bge,bltu,bgeu
	
	output is_branch_taken_o; 	//Asserted if the condition is satisfied 

	localparam BEQ 	= 3'b000;	//dec 0
	localparam BNE 	= 3'b001;	//dec 1
	localparam BLT 	= 3'b100;	//dec 4
	localparam BGE 	= 3'b101;	//dec 5
	localparam BLTU = 3'b110;	//dec 6
	localparam BGEU = 3'b111;	//dec 7


	always @(*) begin

		case(branch_op_i)

			BEQ : is_branch_taken_o = equ_i ? 1 : 0;
			BNE : is_branch_taken_o = ~equ_i ? 1 : 0;
			BLT : is_branch_taken_o = lt_i ? 1 : 0;
			BGE : is_branch_taken_o = (equ_i && ~lt_i) ? 1 : 0;
			BLTU: is_branch_taken_o = ltu_i ? 1 : 0;
			BGEU: is_branch_taken_o = (equ_i && ~ltu_i) ? 1 : 0;
			default is_branch_taken_o = 0;
		endcase // branch_op_i
	end

endmodule