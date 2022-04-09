module BIDS22model(clk, reset_n, X_bidAmt, X_bid, X_retract, Y_bidAmt, Y_bid, Y_retract, Z_bidAmt, Z_bid, Z_retract, C_data, C_op, C_start,
  X_ack, X_err, X_balance, X_win, Y_ack, Y_err, Y_balance, Y_win, Z_ack, Z_err, Z_balance, Z_win, ready, err, roundOver, maxBid);

// input ports
input logic clk, reset_n;
input logic [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
input logic X_bid, Y_bid, Z_bid;
input logic X_retract, Y_retract, Z_retract; 
input logic [31:0] C_data;
input logic [3:0] C_op;
input logic C_start;

// output ports
output logic X_ack, Y_ack, Z_ack;
output logic [1:0] X_err, Y_err, Z_err;
output logic [31:0] X_balance, Y_balance, Z_balance;
output logic X_win, Y_win, Z_win;
output logic ready;
output logic [2:0] err;
output logic roundOver;
output logic [31:0] maxBid;

// registers					
logic [31:0] X_value;
logic [31:0] Y_value;
logic [31:0] Z_value;
logic [3:0] timer;
logic [31:0] key;
logic [2:0] mask;
logic [31:0] bid_cost;

// local variables
logic [3:0] counter;
logic [31:0] local_key;
logic [3:0] previous_op;
logic unlock_flag;
logic [31:0] temp_maxbid, tempX_bidcharge, tempY_bidcharge, tempZ_bidcharge, tempX_balance, tempX_totalbid, tempY_balance, tempY_totalbid, tempZ_balance, tempZ_totalbid;
logic [2:0] temp_win;

// FSM states
enum {Reset_mode, Unlocked_mode, Locked_mode, RoundActive_mode, RoundOver_mode} State, NextState;

// opcodes
parameter
  NoOperation = 0,
  Unlock = 1,
  Lock = 2,
  LoadX = 3,
  LoadY = 4,
  LoadZ = 5,
  SetMask = 6,
  SetTimer = 7,
  BidCharge = 8;
/*
st State = Reset_mode;
st NextState = Reset_mode;*/ 

// reset logic
always @(posedge clk)
begin
if (!reset_n)
begin
  $display("reset on");
  State <= Reset_mode;
end
else
  State <= NextState;
end

// nextstate and output logic
always @(X_bidAmt, X_bid, X_retract, Y_bidAmt, Y_bid, Y_retract, Z_bidAmt, Z_bid, Z_retract, C_data, C_op, C_start, State, reset_n)
//always_comb
begin
$display("Entered always");
unique case(State)
  Reset_mode:
	begin
	$display("Entered Reset_mode");
    NextState = Unlocked_mode;
    //set register values
    X_value = 0;
	Y_value = 0;
	Z_value = 0;
    mask = 3'b111;
    timer = 4'b1111;
    key = 0;
    bid_cost = 1;
    //set output values
	{X_ack, Y_ack, Z_ack} = 3'b000;
    {X_err, Y_err, Z_err} = 6'b000000;
    {X_balance, Y_balance, Z_balance} = 0;
    {X_win, Y_win, Z_win} = 3'b000;
    ready = 1'b0;
    err = 3'b000;
    roundOver = 1'b0;
    maxBid = 0;
    end
  Unlocked_mode: 
    begin
    case(C_op)
      NoOperation:
	    begin
		NextState = Unlocked_mode;
        end
	  Unlock:
	    begin
		NextState = Unlocked_mode;
		end
	  Lock:
	    begin
		NextState = Locked_mode;
		key = C_data;
		end
	  LoadX:        
	    begin
        NextState = Unlocked_mode;
		X_value = C_data;
		end
	  LoadY:
	    begin
		NextState = Unlocked_mode;
		Y_value = C_data;
		end
	  LoadZ:        
	    begin
		NextState = Unlocked_mode;
		Z_value = C_data;
		end
	  SetMask:
	    begin
		NextState = Unlocked_mode;
		mask = C_data;
		end	                                  
	  SetTimer:
	    begin
		NextState = Unlocked_mode;
		timer = C_data;
		end
	  BidCharge:
	    begin
		NextState = Unlocked_mode;
		bid_cost = C_data;
		end
	endcase
	//output values
	if(C_start === 1)
	  err = 3'b011; //cannot assert c_start when unlocked
	else
	  if(C_op === Unlock)
	    err = 3'b010; //already unlocked
	  else
	    err = 3'b000; //no error
	{X_ack, Y_ack, Z_ack} = 3'b000;
	if(X_bid)
	  X_err = 2'b01;
	else
	  X_err = 2'b00;
	if(Y_bid)
	  Y_err = 2'b01;
	else
	  Y_err = 2'b00;
	if(Z_bid)
	  Z_err = 2'b01;
	else
	  Z_err = 2'b00;
    X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 3'b000;
    ready = 1'b1;
    roundOver = 1'b0;
    maxBid = 0;
	end
  Locked_mode:
    begin
    if(C_start)
	  begin
      NextState = RoundActive_mode;
	  tempX_balance = X_value;
	  tempY_balance = Y_value;
	  tempZ_balance = Z_value;
	  tempX_totalbid = 0;
	  tempY_totalbid = 0;
	  tempZ_totalbid = 0;
	  tempX_bidcharge = 0;
	  tempY_bidcharge = 0;
	  tempZ_bidcharge = 0;
	  err = 3'b000; //no error
	  end
    else if(C_op === Unlock)
	  if(C_data !== key)
	    begin
		err = 3'b001; //bad key
		repeat (timer - 1)
	      @(posedge clk);
		NextState = Locked_mode;
		end
	  else
	    begin
		NextState = Unlocked_mode;
		err = 3'b000; //no error
		end
    else
	  begin
      NextState = Locked_mode;
	  err = 3'b100; //invalid operation
	  end
	//output values
    {X_ack, Y_ack, Z_ack} = 3'b000;
    if(X_bid)
	  X_err = 2'b01; //round inactive
	else
	  X_err = 2'b00; //no error
	if(Y_bid)
	  Y_err = 2'b01; //round inactive
	else
	  Y_err = 2'b00; //no error
	if(Z_bid)
	  Z_err = 2'b01; //round inactive
	else
	  Z_err = 2'b00; //no error
    X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 3'b000;
    ready = 1'b1;
    roundOver = 1'b0;
    maxBid = 0;
    end
  RoundActive_mode:
    begin
	NextState = RoundOver_mode;
    if(C_start)
      begin
	  // X bid or retract
	  if(X_bid & (!X_retract))
	    begin
	    if(mask[2])
	      begin
		  X_ack = 1'b1;
		  X_err = 2'b00; //no error
		  tempX_bidcharge = tempX_bidcharge + bid_cost;
		  tempX_balance = (tempX_balance - X_bidAmt) - bid_cost;
		  tempX_totalbid = X_bidAmt + tempX_totalbid;
		  end
		else
		  begin
		  X_ack = 1'b0;
		  X_err = 2'b11; //invalid request
		  tempX_balance = 0;
		  tempX_totalbid = 0;
          tempX_bidcharge = 0;		  
		  end
		err = 3'b000; //no error
		end
	  else if((!X_bid) & X_retract)
	    begin
	    if(mask[2])
	      begin
		  X_err = 2'b00; //no error
		  tempX_bidcharge = tempX_bidcharge + bid_cost;
		  tempX_balance = (tempX_balance + X_bidAmt) - bid_cost;
		  tempX_totalbid = tempX_totalbid - X_bidAmt;
		  end
		else
		  begin
		  X_err = 2'b11; //invalid request
		  tempX_balance = 0;
		  tempX_totalbid = 0;
          tempX_bidcharge = 0;		  
		  end
		X_ack = 1'b0;
		err = 3'b000; //no error
		end
	  else
	    begin
		if(mask[2])
		  begin
		  if(X_bid & X_retract)
		    err = 3'b100; //invalid operation
		  else
		    err = 3'b000; //no error
		  X_ack = 1'b0;
		  X_err = 2'b00; //no error
		  tempX_balance = tempX_balance;
		  tempX_totalbid = tempX_totalbid;
		  tempX_bidcharge = tempX_bidcharge;
		  end
		else 
		  begin
		  if(X_bid & X_retract)
		    begin
		    err = 3'b100; //invalid operation
			X_err = 2'b11; //invalid request
			end
		  else
		    begin
		    err = 3'b000; //no error
			X_err = 2'b00; //no error
			end
		  X_ack = 1'b0;
		  tempX_balance = 0;
		  tempX_totalbid = 0;
		  tempX_bidcharge = 0;
		  end 
		end
	  // Y bid or retract
	  if(Y_bid & (!Y_retract))
	    begin
	    if(mask[1])
	      begin
		  Y_ack = 1'b1;
		  Y_err = 2'b00; //no error
		  tempY_bidcharge = tempY_bidcharge + bid_cost;
		  tempY_balance = (tempY_balance - Y_bidAmt) - bid_cost;
		  tempY_totalbid = Y_bidAmt + tempY_totalbid;
		  end
		else
		  begin
		  Y_ack = 1'b0;
		  Y_err = 2'b11; //invalid request
		  tempY_balance = 0;
		  tempY_totalbid = 0;
          tempY_bidcharge = 0;	  
		  end
		err = 3'b000; //no error
		end
	  else if((!Y_bid) & Y_retract)
	    begin
	    if(mask[1])
	      begin
		  Y_err = 2'b00; //no error
		  tempY_bidcharge = tempY_bidcharge + bid_cost;
		  tempY_balance = (tempY_balance + Y_bidAmt) - bid_cost;
		  tempY_totalbid = tempY_totalbid - Y_bidAmt;
		  end
		else
		  begin
		  Y_err = 2'b11; //invalid request
		  tempY_balance = 0;
		  tempY_totalbid = 0;
          tempY_bidcharge = 0;		  
		  end
		Y_ack = 1'b0;
		err = 3'b000; //no error
		end
	  else
	    begin
		if(mask[1])
		  begin
		  if(Y_bid & Y_retract)
		    err = 3'b100; //invalid operation
		  else
		    err = 3'b000; //no error
		  Y_ack = 1'b0;
		  Y_err = 2'b00; //no error
		  tempY_balance = tempY_balance;
		  tempY_totalbid = tempY_totalbid;
		  tempY_bidcharge = tempY_bidcharge;
		  end
		else 
		  begin
		  if(Y_bid & Y_retract)
		    begin
		    err = 3'b100; //invalid operation
			Y_err = 2'b11; //invalid request
			end
		  else
		    begin
		    err = 3'b000; //no error
			Y_err = 2'b00; //no error
			end
		  Y_ack = 1'b0;
		  tempY_balance = 0;
		  tempY_totalbid = 0;
		  tempY_bidcharge = 0;
		  end 
		end
	  // Z bid or retract
	  if(Z_bid & (!Z_retract))
	    begin
	    if(mask[0])
	      begin
		  Z_ack = 1'b1;
		  Z_err = 2'b00; //no error
		  tempZ_bidcharge = tempZ_bidcharge + bid_cost;
		  tempZ_balance = (tempZ_balance - Z_bidAmt) - bid_cost;
		  tempZ_totalbid = Z_bidAmt + tempZ_totalbid;
		  end
		else
		  begin
		  Z_ack = 1'b0;
		  Z_err = 2'b11; //invalid request
		  tempZ_balance = 0;
		  tempZ_totalbid = 0;
		  tempZ_bidcharge = 0;
		  end
		err = 3'b000; //no error
		end
	  else if((!Z_bid) & Z_retract)
	    begin
	    if(mask[0])
	      begin
		  Z_err = 2'b00; //no error
		  tempZ_bidcharge = tempZ_bidcharge + bid_cost;
		  tempZ_balance = (tempZ_balance + Z_bidAmt) - bid_cost;
		  tempZ_totalbid = tempZ_totalbid - Z_bidAmt;
		  end
		else
		  begin
		  Z_err = 2'b11; //invalid request
		  tempZ_balance = 0;
		  tempZ_totalbid = 0;
          tempZ_bidcharge = 0;		  
		  end
		Z_ack = 1'b0;
		err = 3'b000; //no error
		end
	  else
	    begin
		if(mask[0])
		  begin
		  if(Z_bid & Z_retract)
		    err = 3'b100; //invalid operation
		  else
		    err = 3'b000; //no error
		  Z_ack = 1'b0;
		  Z_err = 2'b00; //no error
		  tempZ_balance = tempZ_balance;
		  tempZ_totalbid = tempZ_totalbid;
		  tempZ_bidcharge = tempZ_bidcharge;
		  end
		else 
		  begin
		  if(Z_bid & Z_retract)
		    begin
		    err = 3'b100; //invalid operation
			Z_err = 2'b11; //invalid request
			end
		  else
		    begin
		    err = 3'b000; //no error
			Z_err = 2'b00; //no error
			end
		  Z_ack = 1'b0;
		  tempZ_balance = 0;
		  tempZ_totalbid = 0;
		  tempZ_bidcharge = 0;
		  end 
		end
	  NextState = RoundActive_mode;	
	  end
	else
	  begin
	  NextState = RoundOver_mode;
	  err = 3'b000;
	  X_err = 2'b00;
	  Y_err = 2'b00;
	  Z_err = 2'b00;
	  {X_ack, Y_ack, Z_ack} = 3'b000;
	  end
	X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 3'b000;
    ready = 1'b1;
    roundOver = 1'b0;
    maxBid = 0;
    end
  RoundOver_mode:
    begin
	NextState = RoundOver_mode;
	temp_win = 3'b000;
    if(tempY_totalbid > tempX_totalbid)
	  if(tempY_totalbid > tempZ_totalbid)
	    begin
        temp_maxbid = tempY_totalbid;
		temp_win = 3'b010;
		end
	  else
	    begin
	    temp_maxbid = tempZ_totalbid;
		temp_win = 3'b001;
		end
    else
	  if(tempX_totalbid > tempZ_totalbid)
	    begin
        temp_maxbid = tempX_totalbid;
		temp_win = 3'b100;
		end
	  else
	    begin
	    temp_maxbid = tempZ_totalbid;
		temp_win = 3'b001;
		end
	if(temp_win[2])
	  begin
	  X_value = tempX_balance;
	  end
	else
	  begin
	  X_value = X_value - tempX_bidcharge;
	  end
	if(temp_win[1])
	  Y_value = tempY_balance;
	else
	  Y_value = Y_value - tempY_bidcharge;
	if(temp_win[0])
	  Z_value = tempZ_balance;
	else
	  Z_value = Z_value - tempZ_bidcharge;
	//output values
	{X_err, Y_err, Z_err} = 6'b000000;
	{X_ack, Y_ack, Z_ack} = 3'b000;
    X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    X_win = temp_win[2];
	Y_win = temp_win[1];
	Z_win = temp_win[0];
    ready = 1'b1;
    roundOver = 1'b1;
    maxBid = temp_maxbid;
	if(C_start)
	  begin
	  NextState = RoundActive_mode;
	  err = 3'b000; //no error
	  end
	else
	  begin
	  if(C_op === Unlock)
	    begin
	    if(C_data !== key)
	      begin
		  err = 3'b001; //bad key
		  repeat (timer - 1)
	        @(posedge clk);
		  NextState = Locked_mode;
		  end
	    else
		  begin
		  NextState = Unlocked_mode;
		  err = 3'b000; //no error
		  end
		end
	  else
        begin	  
	    NextState = Locked_mode;
		err = 3'b100; //invalid operation
		end
	  end
    end
endcase
end

endmodule