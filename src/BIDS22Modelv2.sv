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
logic [31:0] timer;
logic [31:0] key;
logic [2:0] mask;
logic [31:0] bid_cost;

// local variables
logic [31:0] counter;
logic [2:0] bid, retract, ack;
logic [1:0] temp_err [2:0];
logic [31:0] temp_maxbid;
logic [31:0] temp_bidcharge [2:0];
logic [31:0] temp_balance [2:0];
logic [31:0] temp_totalbid [2:0];
logic [31:0] bidAmt [2:0];
logic [2:0] temp_win;

// FSM states
enum {Reset_mode, Unlocked_mode, Locked_mode, RoundActive_mode, RoundOver_mode, Timer_mode} State, NextState;

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

assign X_ack = ack[2];
assign Y_ack = ack[1];
assign Z_ack = ack[0];
assign X_err = temp_err[2];
assign Y_err = temp_err[1];
assign Z_err = temp_err[0];
assign bid[2] = X_bid;
assign bid[1] = Y_bid;
assign bid[0] = Z_bid;
assign retract[2] = X_retract;
assign retract[1] = Y_retract;
assign retract[0] = Z_retract;
assign bidAmt[2] = X_bidAmt;
assign bidAmt[1] = Y_bidAmt;
assign bidAmt[0] = Z_bidAmt;	  

// reset logic
always_ff @(posedge clk)
begin
if (!reset_n)
begin
  $display("reset on");
  State <= Reset_mode;
end
else
  State <= NextState;
end

// nextstate 
always_comb
begin
unique case(State)
  Reset_mode:
	begin
    NextState = Unlocked_mode;
    end
  Unlocked_mode: 
    begin
	if(C_op === Lock)
	  NextState = Locked_mode;
	else
	  NextState = Unlocked_mode;
	end
  Locked_mode:
    begin
    if(C_start)
	  begin
      NextState = RoundActive_mode;
	  end
    else if(C_op === Unlock)
	  begin
	  if(C_data !== key)
	    begin
		counter = timer - 1;
		NextState = Timer_mode;
		end
	  else
	    begin
		NextState = Unlocked_mode;
		end
	  end
    else
	  begin
      NextState = Locked_mode;
	  end
    end
  RoundActive_mode:
    begin
    if(C_start)
	  NextState = RoundActive_mode;	
	else
	  NextState = RoundOver_mode;
    end
  RoundOver_mode:
    begin
	if(C_start)
	  NextState = RoundActive_mode;
	else
	  begin
	  if(C_op === Unlock)
	    begin
	    if(C_data !== key)
	      begin
		  counter = timer -1;
		  NextState = Timer_mode;
		  end
	    else
		  NextState = Unlocked_mode;
		end
	  else	  
	    NextState = Locked_mode;
	  end
    end
  Timer_mode:
    begin
	  if(counter == 0)
	    begin
	    counter = timer - 1;
	    NextState = Locked_mode;
		end
	  else
	    begin
	    counter = counter - 1;
		NextState = Timer_mode;
		end
	end
  default:
    begin
    NextState = Unlocked_mode;
	end
endcase
end

// output logic
always_comb
begin
{ack[2], ack[1], ack[0]} = 0;
{temp_err[2], temp_err[1], temp_err[0]} = 0;
{X_balance, Y_balance, Z_balance} = 0;
{X_win, Y_win, Z_win} = 0;
ready = 0;
err = 0;
roundOver = 0;
maxBid = 0;
unique case(State)
  Reset_mode:
	begin
	// registers
	X_value = 0;
	Y_value = 0;
	Z_value = 0;
    mask = 3'b111;
    timer = 4'b1111;
    key = 0;
    bid_cost = 1;
	// outputs
    {ack[2], ack[1], ack[0]} = 0;
    {temp_err[2], temp_err[1], temp_err[0]} = 0;
    {X_balance, Y_balance, Z_balance} = 0;
    {X_win, Y_win, Z_win} = 0;
    ready = 0;
    err = 0;
    roundOver = 0;
    maxBid = 0;
    end
  Unlocked_mode: 
    begin
	    case(C_op)
	  Lock:
	    begin
		key = C_data;
		end
	  LoadX:        
	    begin
		X_value = C_data;
		end
	  LoadY:
	    begin
		Y_value = C_data;
		end
	  LoadZ:        
	    begin
		Z_value = C_data;
		end
	  SetMask:
	    begin
		mask = C_data;
		end	                                  
	  SetTimer:
	    begin
		timer = C_data;
		end
	  BidCharge:
	    begin
		bid_cost = C_data;
		end
	  default:
	    $display("Other Opcode");
	endcase
	if(C_start === 1)
	  err = 3'b011; //cannot assert c_start when unlocked
	else
	  begin
	  if(C_op === Unlock)
	    err = 3'b010; //already unlocked
	  else
	    err = 3'b000; //no error
	  end
    {ack[2], ack[1], ack[0]} = 0;
    if(X_bid)
	  temp_err[2] = 2'b01; //round inactive
	else
	  temp_err[2] = 2'b00; //no error
	if(Y_bid)
	  temp_err[1] = 2'b01; //round inactive
	else
	  temp_err[1] = 2'b00; //no error
	if(Z_bid)
	  temp_err[0] = 2'b01; //round inactive
	else
	  temp_err[0] = 2'b00; //no error
    X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 0;
    ready = 1;
    roundOver = 0;
    maxBid = 0;
	end
  Locked_mode:
    begin
    if(C_start)
	  begin
	  temp_balance[2] = X_value;
	  temp_balance[1] = Y_value;
	  temp_balance[0] = Z_value;
	  temp_totalbid[2] = 0;
	  temp_totalbid[1] = 0;
	  temp_totalbid[0] = 0;
	  temp_bidcharge[2] = 0;
	  temp_bidcharge[1] = 0;
	  temp_bidcharge[0] = 0;
	  err = 3'b000; //no error
	  end
    else if(C_op === Unlock)
	  if(C_data !== key)
	    begin
		err = 3'b001; //bad key
		end
	  else
	    begin
		err = 3'b000; //no error
		end
    else if(C_op === Lock)
	  begin
	  err = 3'b000; //no error
	  end
	else
	  begin
	  err = 3'b100; //invalid operation
	  end
	//output values
    {ack[2], ack[1], ack[0]} = 0;
    if(X_bid)
	  temp_err[2] = 2'b01; //round inactive
	else
	  temp_err[2] = 2'b00; //no error
	if(Y_bid)
	  temp_err[1] = 2'b01; //round inactive
	else
	  temp_err[1] = 2'b00; //no error
	if(Z_bid)
	  temp_err[0] = 2'b01; //round inactive
	else
	  temp_err[0] = 2'b00; //no error
    X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 0;
    ready = 1;
    roundOver = 0;
    maxBid = 0;
    end
  RoundActive_mode:
    begin
    if(C_start)
	  begin
	  for(int i = 2; i >= 0; i--)
	    begin
		$display("******Inside RoundActive_mode FOR loop******");
	    if((bid[i] === 1) & (retract[i] !== 1))
	      begin
		  $display("******Inside bid and !retract block******");
	      if(mask[i])
	        begin
			$display("******Inside bid and !retract block - No mask******");
		    ack[i] = 1'b1;
		    temp_err[i] = 2'b00; //no error
		    temp_bidcharge[i] = temp_bidcharge[i] + bid_cost;
		    temp_balance[i] = (temp_balance[i] - bidAmt[i]) - bid_cost;
		    temp_totalbid[i] = bidAmt[i] + temp_totalbid[i];
		   end
		  else
		    begin
			$display("******Inside bid and !retract block - Mask set******");
		    ack[i] = 1'b0;
		    temp_err[i] = 2'b11; //invalid request
		    temp_balance[i] = 0;
		    temp_totalbid[i] = 0;
            temp_bidcharge[i] = 0;		  
		    end
		  if(C_op !== Lock)
		    begin
		    err = 3'b100; //invalid operation
		    end
		  else
			begin
		    err = 3'b000; //no error
		    end
		  end
	    else if((bid[i] !== 1) & (retract[i] === 1))
	      begin
		  $display("******Inside !bid and retract block******");
	      if(mask[i])
	        begin
			$display("******Inside !bid and retract block - No mask******");
		    temp_err[i] = 2'b00; //no error
		    temp_bidcharge[i] = temp_bidcharge[i];
		    temp_balance[i] = (temp_balance[i] + bidAmt[i]);
		    temp_totalbid[i] = temp_totalbid[i] - bidAmt[i];
		    end
		  else
		    begin
			$display("******Inside !bid and retract block - Mask set******");
		    temp_err[i] = 2'b11; //invalid request
		    temp_balance[i] = 0;
		    temp_totalbid[i] = 0;
            temp_bidcharge[i] = 0;		  
		    end
		  ack[i] = 1'b0;
		  if(C_op !== Lock)
		    begin
		    err = 3'b100; //invalid operation
		    end
		  else
			begin
		    err = 3'b000; //no error
		    end
		  end
	    else
	      begin
		  $display("******Inside !bid and !retract OR bid and retract block******");
		  if(C_op !== Lock)
		    begin
		    err = 3'b100; //invalid operation
		    end
	      else
			begin
		    err = 3'b000; //no error
		    end
		  ack[i] = 1'b0;
		  temp_err[i] = 2'b00; //no error
		  temp_balance[i] = temp_balance[i];
		  temp_totalbid[i] = temp_totalbid[i];
		  temp_bidcharge[i] = temp_bidcharge[i];
		  end
	    end
	  end
	else
	  begin
	  err = 3'b000;
	  temp_err[2] = 2'b00;
	  temp_err[1] = 2'b00;
	  temp_err[0] = 2'b00;
	  {ack[2], ack[1], ack[0]} = 0;
	  end
	X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 0;
    ready = 1;
    roundOver = 0;
    if(temp_totalbid[1] > temp_totalbid[2])
	  begin
	  if(temp_totalbid[1] > temp_totalbid[0])
        temp_maxbid = temp_totalbid[1];
	  else if(temp_totalbid[1] < temp_totalbid[0])
	    temp_maxbid = temp_totalbid[0];
	  else
		temp_maxbid = temp_totalbid[1];
	  end
    else if(temp_totalbid[1] < temp_totalbid[2])
	  begin
	  if(temp_totalbid[2] > temp_totalbid[0])
        temp_maxbid = temp_totalbid[2];
	  else if(temp_totalbid[2] < temp_totalbid[0])
	    temp_maxbid = temp_totalbid[0];
	  else
	    temp_maxbid = temp_totalbid[2];
	  end
	else
	  begin
	  if(temp_totalbid[1] > temp_totalbid[0])
		temp_maxbid = temp_totalbid[1];
      else if(temp_totalbid[1] < temp_totalbid[0])
		temp_maxbid = temp_totalbid[0];
      else
		temp_maxbid = temp_totalbid[1];
      end
	maxBid = temp_maxbid;
    end
  RoundOver_mode:
    begin
	temp_win = 3'b000;
    if(temp_totalbid[1] > temp_totalbid[2])
	  begin
	  if(temp_totalbid[1] > temp_totalbid[0])
	    begin
        temp_maxbid = temp_totalbid[1];
		temp_win = 3'b010;
		end
	  else if(temp_totalbid[1] < temp_totalbid[0])
	    begin
	    temp_maxbid = temp_totalbid[0];
		temp_win = 3'b001;
		end
	  else
	    begin
		temp_maxbid = temp_totalbid[1];
		temp_win = 3'b000;
		end
	  end
    else if(temp_totalbid[1] < temp_totalbid[2])
	  begin
	  if(temp_totalbid[2] > temp_totalbid[0])
	    begin
        temp_maxbid = temp_totalbid[2];
		temp_win = 3'b100;
		end
	  else if(temp_totalbid[2] < temp_totalbid[0])
	    begin
	    temp_maxbid = temp_totalbid[0];
		temp_win = 3'b001;
		end
	  else
	    begin
	    temp_maxbid = temp_totalbid[2];
		temp_win = 3'b000;		
		end
	  end
	else
	  begin
	  if(temp_totalbid[1] > temp_totalbid[0])
		begin
		temp_maxbid = temp_totalbid[1];
		temp_win = 3'b000;
		end
      else if(temp_totalbid[1] < temp_totalbid[0])
		begin
		temp_maxbid = temp_totalbid[0];
		temp_win = 3'b001;
		end
      else
		begin
		temp_maxbid = temp_totalbid[1];
		temp_win = 3'b000;
		end
      end	  
	if(temp_win[2])
	  X_value = temp_balance[2];
	else
	  X_value = X_value - temp_bidcharge[2];
	if(temp_win[1])
	  Y_value = temp_balance[1];
	else
	  Y_value = Y_value - temp_bidcharge[1];
	if(temp_win[0])
	  Z_value = temp_balance[0];
	else
	  Z_value = Z_value - temp_bidcharge[0];
	//output values
	{ack[2], ack[1], ack[0]} = 0;
    {temp_err[2], temp_err[1], temp_err[0]} = 0;
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
	  if(temp_win === 0)
	    begin
	    err = 3'b101; //duplicate valid bids made
		end
	  else if(C_op !== Lock)
	    begin
		err = 3'b100; //invalid operation
		end
	  else
	    begin
		err = 3'b000; //no error
		end
	  end
	else
	  begin
	  if(C_op === Unlock)
	    begin
	    if(C_data !== key)
	      begin
		  err = 3'b001; //bad key
		  end
	    else
		  begin
		  if(temp_win === 0)
	        begin
	        err = 3'b101; //duplicate valid bids made
		    end
	      else
	        begin
		    err = 3'b000; //no error
		    end
		  end
		end
	  else if(C_op === Lock)
	    begin
		if(temp_win === 0)
	      begin
	      err = 3'b101; //duplicate valid bids made
		  end
	    else
	      begin
		  err = 3'b000; //no error
		  end
		end
	  else
        begin
		err = 3'b100; //invalid operation
		end
	  end
    end
  Timer_mode:
    begin
	X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 0;
    ready = 1;
    roundOver = 0;
    maxBid = 0;
	err = 0;
	{ack[2], ack[1], ack[0]} = 0;
    {temp_err[2], temp_err[1], temp_err[0]} = 0;
	end
  default:
    begin
    X_balance = X_value;
    Y_balance = Y_value;
    Z_balance = Z_value;
    {X_win, Y_win, Z_win} = 0;
    ready = 1;
    roundOver = 0;
    maxBid = 0;
	err = 0;
	{ack[2], ack[1], ack[0]} = 0;
    {temp_err[2], temp_err[1], temp_err[0]} = 0;
	end
endcase   
end

endmodule