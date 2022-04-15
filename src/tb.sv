import package rnippkg::*
    
module top ();

parameter CLK_PERIOD = 10;

logic         clk, reset_n, X_bid, X_retract, Y_bid, Y_retract, Z_bid, Z_retract, C_start,
logic [15:0]  X_bidAmt, Y_bidAmt, Z_bidAmt,
logic [31:0]  C_data,
logic [3:0]   C_op,
logic        X_ack, X_win, Y_ack, Y_win, Z_ack, Z_win, ready, roundOver,
logic [1:0]  X_err, Y_err, Z_err,
logic [31:0] X_balance, Y_balance, Z_balance, maxBid,
logic [2:0]  err;

// internal registers
logic [31:0] X_value;
logic [31:0] Y_value;
logic [31:0] Z_value;
logic [3:0] timer;
logic [31:0] key;
logic [2:0] mask;
logic [31:0] bid_cost;

logic [3:0] counter;
logic [31:0] local_key;

always begin: clock_generator
 	#(CLK_PERIOD / 2) clk = ~clk;
end: clock_generator

initial begin
	reset_n = 0;
	#5;
	reset_n = 1;
end

covergroup bid_retract_signals with function bids(bit X_bid , Y_bid, Z_bid, X_retract, Y_retract, Z_retract);
    bidsig: coverpoint X_bid, Y_bid, Z_bid;
    retractsig: coverpoint X_retract, Y_retract, Z_retract;
    bid_amount : coverpoint 


endgroup
/*
inital begin
    repeat (1) @(negedge clk);
    C_op = 3;
    C_data = 20;
    repeat (1) @(negedge clk);
    C_op = 4;
    C_data = 15;
    repeat (1) @(negedge clk);
    C_op = 5;
    C_data = 5;
    repeat (1) @(negedge clk);
    C_op = 8;
    C_data = 1;
    repeat (1) @(negedge clk);
    C_op = 2;
    C_data = 42;
    repeat (1) @(negedge clk);
    C_start = 1;
    repeat (1) @(negedge clk);
    X_bid = 1;
    X_bidAmt = 5;
    repeat (1) @(negedge clk);
    Y_bid = 1;
    Y_bidAmt = 2;
    repeat (1) @(negedge clk);
    Z_bid = 1;
    Z_bidAmt = 2;
    repeat (1) @(negedge clk);
    C_start = 0;
end
*/
endmodule