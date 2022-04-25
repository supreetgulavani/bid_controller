// bfm interface
interface bidcontroller_bfm;

logic         clk, reset_n, X_bid, X_retract, Y_bid, Y_retract, Z_bid, Z_retract, C_start;
logic [15:0]  X_bidAmt, Y_bidAmt, Z_bidAmt;
logic [31:0]  C_data;
logic [3:0]   C_op;
logic        X_ack, X_win, Y_ack, Y_win, Z_ack, Z_win, ready, roundOver;
logic [1:0]  X_err, Y_err, Z_err;
logic [31:0] X_balance, Y_balance, Z_balance, maxBid;
logic [2:0]  err;

// reset task : enable design?
task reset_controller();
    reset_n = 0;
	#5;
	reset_n = 1;
    start = 0;
endtask : reset_controller

// drives different design configurations
// drive unlock: opcodes: randomize c_data, C_op,
task unlock_control();

endtask: unlock_control
// drive lock: rounds: multiple cycles, 

// roundActive roundOver
    
endinterface 