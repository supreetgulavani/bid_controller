package bid_generator
// Class for random input
class bids_gen;
	rand bit [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
	rand bit 		X_bid, Y_bid, Z_bid;
	rand bit		X_retract, Y_retract, Z_retract; 
	rand bit [31:0] C_data;
	rand bit [3:0] 	C_op;
	rand bit 		C_start;

	// constraints
	constraint isopcode{
		C_op inside {[0:8]};
	};
    
	//prints all the inputs
	function void printbid();
		$display("X_bidAmt:%b\tY_bidAmt:%b\tZ_bidAmt:%b", X_bidAmt, Y_bidAmt, Z_bidAmt); 
		$display("X_bid:%b\tY_bid:%b\tZ_bid:%b", X_bid, Y_bid, Z_bid); 
		$display("X_retract:%b\tY_retract:%b\tZ_retract:%b", X_retract, Y_retract, Z_retract); 
		$display("C_data:%b\tC_start:%b", C_data, C_start); 
	endfunction

endclass
endpackage