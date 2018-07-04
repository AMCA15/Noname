//Forwarding unit

//By 
// Oscar Moreno
// Carlos Sanoja
// Will Chacon
// Luis Ruiz

module fwd_unit(
						input wire [4:0] EX_rd,
						input wire [4:0] MEM_rd,  
						input wire [4:0] WB_rd, 
						input wire [1:0] EX_inst,  
						input wire [1:0] MEM_inst,
						input wire [31:0] EX_dat,
						input wire [31:0] MEM_dat,
						input wire [31:0] WB_dat,
						input wire mem_ack,
						input wire [4:0] rs1,			 //register source 
						input wire [4:0] rs2,
						output reg is_fwd_a_o,          // Output 1 (Mux control signal)
						output reg is_fwd_b_o,          // Output 2 (Mux control signal)
						output reg [31:0] dat_fwd_a_o,
						output reg [31:0] dat_fwd_b_o,
						output reg stall
						);

	localparam inst_ex = 2'b01;
	localparam inst_mem = 2'b10;
	localparam inst_wb = 2'b00;

	always@(*) begin

			is_fwd_a_o = 0;
			is_fwd_b_o = 0;

		//Execution 
		if(((rs1 == EX_rd) && |rs1) || ((rs2 == EX_rd) && |rs2)) begin
			if (EX_inst == inst_ex) begin
				stall = 0;
				if(|rs1 && (rs1 == EX_rd))begin
					is_fwd_a_o = 1;   //fwd
					dat_fwd_a_o = EX_dat;					
				end
				if(|rs2 && (rs2 == EX_rd))begin
					is_fwd_b_o = 1;
					dat_fwd_b_o = EX_dat;										
				end
			end else 
				stall = 1;
		end 
		// Memory
		if(((rs1 == MEM_rd) && |rs1) || ((rs2 == MEM_rd) && |rs2)) begin
			if (((MEM_inst == inst_mem) && mem_ack) || (MEM_inst == inst_ex)) begin
				stall = 0;
	            if(|rs1 && (rs1 == MEM_rd) && (rs1 != EX_rd))begin
					is_fwd_a_o = 1;   //fwd
					dat_fwd_a_o = MEM_dat;					
				end
				if(|rs2 && (rs2 == MEM_rd) && (rs2 != EX_rd))begin
					is_fwd_b_o = 1;
					dat_fwd_b_o = MEM_dat;										
				end
	       	end else  
				stall = 1;
        end 
		//WB
		if(((rs1 == WB_rd) && |rs1) || ((rs2 == WB_rd ) && |rs2)) begin
				stall = 0;
				if(|rs1 && (rs1 == WB_rd) && (rs1 != EX_rd) && (rs1 != MEM_rd))begin
					is_fwd_a_o = 1;   //fwd
					dat_fwd_a_o = WB_dat;
				end
				if(|rs2 && (rs2 == WB_rd) && (rs2 != EX_rd) && (rs2 != MEM_rd))begin
					is_fwd_b_o = 1;
					dat_fwd_b_o = WB_dat;					
				end
		end 
		
	end

endmodule
