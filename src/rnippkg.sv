package rnippkg

// random input
class bids_gen;
	rand bit [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
	rand bit 		X_bid, Y_bid, Z_bid;
	rand bit		X_retract, Y_retract, Z_retract; 
	rand bit [31:0] C_data;
	rand bit [3:0] 	C_op;
	rand bit 		C_start;

	// constraints
	constraint isopcode{
		//C_op >= 0;
		//C_op <= 8;
		C_op inside {[0:8]};
	};
/*
	// accept components
	function bid_ip ();
		this.X_bidAmt = X_bidAmt;
		this.Y_bidAmt = Y_bidAmt;
		this.Z_bidAmt = Z_bidAmt;
		this.X_bid = X_bid;
		this.Y_bid = Y_bid;
		this.Z_bid = Z_bid;
		this.X_retract = X_retract;
		this.Y_retract = Y_retract;
		this.Z_retract = Z_retract;
		this.C_data = C_data;
		this.C_start = C_start;
	endfunction : bid_ip
	*/
    
	//prints all the inputs
	function void printbid();
		$display("X_bidAmt:%b\tY_bidAmt:%b\tZ_bidAmt:%b", X_bidAmt, Y_bidAmt, Z_bidAmt); 
		$display("X_bid:%b\tY_bid:%b\tZ_bid:%b", X_bid, Y_bid, Z_bid); 
		$display("X_retract:%b\tY_retract:%b\tZ_retract:%b", X_retract, Y_retract, Z_retract); 
		$display("C_data:%b\tC_start:%b", C_data, C_start); 
	endfunction : printbid

endclass

endpackage
