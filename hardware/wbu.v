/*
* Wishbone Module B4
* Classic Implementation:
* Luis Ruiz
*/

module wbu(clk_i, rst_i, wbm_dat_i, wbm_ack_i, wbm_err_i, wbm_re_i,
            wbm_cyc_o, wbm_stb_o, wbm_dat_o, wbm_addr_o, wbm_we_o, wbm_sel_o);

	input wire clk_i;
	input wire rst_i;

	//Maquina de estados
	localparam wbu_state_idle = 0;
	localparam wbu_state_tran = 1;

	reg wbu_state;


	// Comunicacion con el bus
	input wire wbm_ack_i;
	input wire wbm_err_i;
	input wire wbm_re_i;
	input wire [31:0] wbm_dat_i;
	output reg wbm_we_o;
	output reg wbm_cyc_o;
	output reg wbm_stb_o;
	output reg [3:0] wbm_sel_o;
	output reg [31:0] wbm_dat_o;
	output reg [31:0] wbm_addr_o;


	always @(posedge clk_i) begin
		if (rst_i) begin
			wbm_cyc_o <= 0;
			wbm_stb_o <= 0;
			wbu_state <= wbu_state_idle;
		end else begin
			case(wbu_state)
				wbu_state_idle: begin
					if(wbm_we_o ^ wbm_re_i) begin
						wbm_cyc_o <= 1;
						wbm_stb_o <= 1;
						wbu_state <= wbu_state_tran;
					end
				end
				wbu_state_tran: begin
					if(wbm_ack_i || wbm_err_i) begin
						wbm_cyc_o <= 0;
						wbm_stb_o <= 0;
						wbu_state <= wbu_state_idle;
					end
				end
				default:begin
					wbu_state <= wbu_state_idle;
				end
			endcase
		end

	end
endmodule