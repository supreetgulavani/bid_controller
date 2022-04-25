interface BIDS22bfm;

import BIDS22pkg::*;

// inputs
logic clk, reset_n;
logic [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
logic X_bid, Y_bid, Z_bid;
logic X_retract, Y_retract, Z_retract; 
logic [31:0] C_data;
logic [3:0] C_op;
logic C_start;

// outputs
wire X_ack, Y_ack, Z_ack;
wire [1:0] X_err, Y_err, Z_err;
wire [31:0] X_balance, Y_balance, Z_balance;
wire X_win, Y_win, Z_win;
wire ready;
wire [2:0] err;
wire roundOver;
wire [31:0] maxBid;

//operation_t op_set;
bit [31:0] localKey;

//set clock
initial begin
  clk = 0;
  forever begin
	#10;
	clk = ~clk;
  end
end

//task for reset
task reset_BIDmodel();
  reset_n = 1'b0;
  @(negedge clk);
  @(negedge clk);
  reset_n = 1'b1;
  localKey = 0;
endtask: reset_BIDmodel

//task for setting initial conditions for going to Unlock Mode
task unlock_BIDmodel();
  reset_n = 1'b0;
  @(negedge clk);
  @(negedge clk);
  reset_n = 1'b1;
  localKey = 0;
  C_op = 4'b0000; //Unlock
endtask: unlock_BIDmodel

/*task for operations defined in operation_t 
  --> sets conditions and data for each operation*/
task send_op(input bit [15:0] tXbidAmt, tYbidAmt, tZbidAmt,
  input bit tXbid, tYbid, tZbid,
  input bit tXretract, tYretract, tZretract,
  input bit [31:0] tCdata,
  input bit tCstart,
  input operation_t tOp,
  output bit tXack, tYack, tZack,
  output bit [1:0] tXerr, tYerr, tZerr,
  output bit [31:0] tXbalance, tYbalance, tZbalance,
  output bit tXwin, tYwin, tZwin,
  output bit tready,
  output bit [2:0] terr,
  output bit troundOver,
  output bit [31:0] tmaxBid);


  if(tOp == Unlock_op) begin           //Unlock-operation initial conditions
    @(negedge clk);
    C_data = localKey;
	C_start = 0;
	C_op = tOp; //Unlock
  end
  else if(tOp == Lock_op) begin        //Lock-operation initial conditions
    @(negedge clk);
	C_data = tCdata;
	localKey = tCdata;
	C_op = tOp; //Lock
  end
  else if(tOp == RoundActive_op) begin //RoundActive-operation initial conditions
    @(negedge clk);
	C_op = 4'b0010; //Lock
	@(negedge clk);
	C_start = 1;
	@(negedge clk);
	X_bidAmt = tXbidAmt;
	Y_bidAmt = tYbidAmt;
	Z_bidAmt = tZbidAmt;
	if(tXbid == 0)
	  X_retract = tXretract;
	else
      X_bid = tXbid;
    if(tYbid == 0)
	  Y_retract = tYretract;
	else
      Y_bid = tYbid;
    if(tZbid == 0)
	  Z_retract = tZretract;
	else
      Z_bid = tZbid;	  
  end
  else if(tOp == RoundOver_op) begin  //RoundOver-operation initial conditions
    do
	  @(negedge clk);
	while(roundOver == 0);
	C_start = tCstart;
	C_op = tOp;
  end
  else begin                          //Other operations initial conditions
    @(negedge clk);
    C_op = tOp;
	C_start = 0;
	C_data = tCdata;
  end
  
endtask: send_op

endinterface: BIDS22bfm
