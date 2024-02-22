// LED PMOD Left->Right LSB->MSB active low

// DT PMOD
//		   |--5--|
//		   0     4 	and Bit 7 selects digit, left digit = 1, right digit = 0
//		   |--1--|
//		   2     6
//		   |--3--|
// Bits are active low
// all the above assumes you have the board upside down so
// the unselectable DOT is at the bottom where it should be
// (all the silk screen is the other way up)
// 
module top( 
            input wire clk50,
			input wire reset,
			output wire led,
			inout wire [7:0] pmodA_io,
			inout wire [7:0] pmodB_io,
			inout wire [7:0] pmodC_io
          );

	reg [37:0] ctr;
	always @(posedge clk50 or posedge reset) begin
		if ( reset ) ctr<=38'd0;
		else ctr<=ctr+38'd1;
	end

	assign pmodC_io = ~ctr[31:24];

	dtpmod_byte B1( .clk( clk50 ), .reset(reset), .enable(1'b1), .byte(ctr[37:30]), .pmod(pmodA_io) );
	dtpmod_byte B2( .clk( clk50 ), .reset(reset), .enable(1'b1), .byte(ctr[29:22]), .pmod(pmodB_io) );

	assign led = ctr[24];

endmodule

module dtpmod_byte( input wire 			clk,
					input wire 			reset,
					input wire 			enable,
					input wire [7:0] 	byte,
					output wire [7:0]	pmod );
	reg [8:0] ctr;
	always @(posedge clk or posedge reset)
		if ( reset ) ctr <= 9'd0;
		else ctr <= ctr + 9'd1;

	function [6:0] decode( input [3:0] inp );
	begin
		case(inp)
		4'h0: decode = 7'b0000010;
		4'h1: decode = 7'b0101111;
		4'h2: decode = 7'b1000001;
		4'h3: decode = 7'b0000101;
		4'h4: decode = 7'b0101100;
		4'h5: decode = 7'b0010100;
		4'h6: decode = 7'b0010000;
		4'h7: decode = 7'b0001111;
		4'h8: decode = 7'b0000000;
		4'h9: decode = 7'b0001100;
		4'hA: decode = 7'b0001000;
		4'hB: decode = 7'b0110000;
		4'hC: decode = 7'b1110001;
		4'hD: decode = 7'b0100001;
		4'hE: decode = 7'b1010000;
		4'hF: decode = 7'b1011000;
        endcase
	end
	endfunction

	wire [6:0] digitA = decode( byte[7:4] );
	wire [6:0] digitB = decode( byte[3:0] );

	assign pmod[7] = ctr[8];
	assign pmod[6:0] = enable ? ( ctr[8] ? digitB : digitA ) : 7'h7F;
endmodule

					
