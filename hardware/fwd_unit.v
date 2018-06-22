//Forwarding unit

//By 
// Oscar Moreno
// Carlos Sanoja
// Will Chacon
// Luis Ruiz

module fwd_unit(
						input         is_op_i,  
						input         is_mem_i,
						input 		  mem_ack_i,
						input  [4:0]  rs1_i,			 
						input  [4:0]  rs2_i,
						input  [4:0]  EX_rd_i,			 // Sources 
						input  [4:0]  MEM_rd_i,
						input  [31:0] EX_dat_i,
						input  [31:0] MEM_dat_i,
						output 		  is_fwd_a_o,        // Output 1 (Mux control signal)
						output 		  is_fwd_b_o,        // Output 2 (Mux control signal)
						output [31:0] dat_fwd_a_o,
						output [31:0] dat_fwd_b_o,
						output stall
						);


	// Forwarding to RS1/A
	always @(*) begin
		case (1'b1)
			// Execution. (ALU operation)
			is_op_i: begin
			  dat_fwd_a_o = EX_dat_i;
			  is_fwd_a_o = (rs1_i == EX_rd_i) ? 1 : 0;
			end
			// Memory Operation
			is_mem_i && mem_ack_i: begin
			  dat_fwd_a_o = MEM_dat_i;
			  is_fwd_a_o = (rs1_i == EX_rd_i) ? 1 : 0;
			end
			default: is_fwd_a_o = 0;
		endcase
	end

	// Forwarding to RS2/B
	always @(*) begin
		case (1'b1)
			// Execution. (ALU operation)
			is_op_i: begin
			  dat_fwd_b_o = EX_dat_i;
			  is_fwd_b_o = (rs2_i == EX_rd_i) ? 1 : 0;
			end
			// Memory Operation
			is_mem_i && mem_ack_i: begin
			  dat_fwd_b_o = MEM_dat_i;
			  is_fwd_b_o = (rs2_i == EX_rd_i) ? 1 : 0;
			end
			default: is_fwd_b_o = 0;
		endcase
	end
	
endmodule
