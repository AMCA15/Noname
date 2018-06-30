/*
* LSU unidad combinatoria
* Classic Implementation:
* Luis Ruiz
*/

module lsu_comb(funct3_i, st_data_i, ld_data_i, addr_i, st_data_fmt_o, ld_data_fmt_o, st_sel_o,
                e_ld_addr_mis_o, e_st_addr_mis_o);

	localparam LB  = 3'b000;
	localparam LH  = 3'b001;
	localparam LW  = 3'b010;
	localparam LBU = 3'b100;
	localparam LHU = 3'b101;
	localparam SB  = 3'b000;
	localparam SH  = 3'b001;
	localparam SW  = 3'b010;


	input [2:0]   funct3_i;
	input [31:0]  st_data_i;
	input [31:0]  ld_data_i;
	input [31:0]  addr_i;
	output [31:0] st_data_fmt_o;
	output [31:0] ld_data_fmt_o;
	output [3:0] st_sel_o;
	output e_ld_addr_mis_o;
	output e_st_addr_mis_o;


	always @(*) begin
		/* verilator lint_off CASEINCOMPLETE */
		case (funct3_i)
			LB:  begin
                case (addr_i[1:0])
                    2'b00: ld_data_fmt_o = $signed(ld_data_i[7:0]);
                    2'b01: ld_data_fmt_o = $signed(ld_data_i[15:8]);
                    2'b10: ld_data_fmt_o = $signed(ld_data_i[23:16]);
                    2'b11: ld_data_fmt_o = $signed(ld_data_i[31:24]);
                endcase
			end
			LBU: begin
                case (addr_i[1:0])
                    2'b00: ld_data_fmt_o = ld_data_i[7:0];
                    2'b01: ld_data_fmt_o = ld_data_i[15:8];
                    2'b10: ld_data_fmt_o = ld_data_i[23:16];
                    2'b11: ld_data_fmt_o = ld_data_i[31:24];
                endcase
			end
			LH:  begin
				e_ld_addr_mis_o = addr_i[0] ? 1 : 0;
                case (addr_i[1])
                    1'b0: ld_data_fmt_o = $signed(ld_data_i[15:0]);
                    1'b1: ld_data_fmt_o = $signed(ld_data_i[31:16]);
                endcase
			end
			LHU: begin
				e_ld_addr_mis_o = addr_i[0] ? 1 : 0;
                case (addr_i[1])
                    1'b0: ld_data_fmt_o = ld_data_i[15:0];
                    1'b1: ld_data_fmt_o = ld_data_i[31:16];
                endcase
			end
			LW:  begin
				e_ld_addr_mis_o = |addr_i[1:0] ? 1 : 0;
				ld_data_fmt_o = ld_data_i;
			end
		endcase
		/* verilator lint_on CASEINCOMPLETE */
	end

	always @(*) begin
		/* verilator lint_off CASEINCOMPLETE */
		case (funct3_i)
			SB: begin
        	    st_data_fmt_o = {4{st_data_i[7:0]}};
        	    st_sel_o = 4'b0001 << addr_i[1:0];
			end
			SH: begin
				e_st_addr_mis_o = addr_i[0] ? 1 : 0;
        	    st_data_fmt_o = {2{st_data_i[15:0]}};
        	    st_sel_o = addr_i[1] ? 4'b1100 : 4'b0011;
			end
			SW: begin
				e_st_addr_mis_o = |addr_i[1:0] ? 1 : 0;
        	    st_data_fmt_o = st_data_i;
        	    st_sel_o = 4'b1111;
			end
		endcase
		/* verilator lint_on CASEINCOMPLETE */
	end
endmodule