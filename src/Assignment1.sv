interface BIDSinterface(input logic clk, reset_n);
//define a parameter
logic [31:0] C_data; //Inputs
logic [3:0] C_op;
logic C_start;
logic [15:0] X_bitAmt;
logic X_bid;
logic X_retract;
logic [15:0] Y_bitAmt;
logic Y_bid;
logic Y_retract;
logic [15:0] Z_bitAmt;
logic Z_bid;
logic Z_retract;

logic X_ack;
logic [1:0] X_err;
logic [31:0] X_balance;
logic X_win;
logic Y_ack;
logic [1:0] Y_err;
logic [31:0] Y_balance;
logic Y_win;
logic Z_ack;
logic [1:0] Z_err;
logic [31:0] Z_balance;
logic Z_win;
logic ready;
logic [2:0] err;
logic roundOver;
logic [31:0] maxBid;

modport BIDS22port(input clk, input reset_n, 
					input X_bitAmt,
					input X_bid,
					input X_retract,
					input Y_bitAmt,
					input Y_bid,
					input Y_retract,
					input Z_bitAmt,
					input Z_bid,
					input Z_retract,
					input C_data,
					input C_op,
					input C_start,
					output X_ack,
					output X_err,
					output X_balance,
					output X_win,
					output Y_ack,
					output Y_err,
					output Y_balance,
					output Y_win,
					output Z_ack,
					output Z_err,
					output Z_balance,
					output Z_win,
					output ready,
					output err,
					output roundOver,
					output maxBid);

endinterface

module BIDS22model(BIDSinterface.BIDS22port port);

logic [31:0] X_value;
logic [31:0] Y_value;
logic [31:0] Z_value;
logic [3:0] timer;
logic [31:0] key;
logic [2:0] mask;
logic [31:0] bid_cost;

logic [3:0] counter;
logic [31:0] local_key;

enum {Reset_mode, Unlocked_mode, Locked_mode} State, NextState;
enum {s_NoOperation, s_Unlock, s_UnlockWait, s_Lock, s_LoadX, s_LoadY, s_LoadZ, s_Mask, s_Timer, s_BidCharge} Unlocked_state, Unlocked_nextstate;
//enum {} locked_state, locked_nextstate;

localparam
	NoOperation = 0,
	Unlock = 1,
	Lock = 2,
	LoadX = 3,
	LoadY = 4,
	LoadZ = 5,
	SetMask = 6,
	SetTimer = 7,
	BidCharge = 8;

// reset logic
always @(posedge clk)
begin
if (!reset_n)
begin
  State <= Reset_mode;
  Unlocked_state <= s_Unlock;
end
else
	State <= NextState;
	Unlocked_state <= Unlocked_nextstate;
end

// nextstate logic
always_comb
begin
    unique case(State)
    Reset_mode:	   begin
                   NextState = Unlocked_mode;
				   Unlocked_nextstate = s_Unlock;
    	           X_value = 0;
				   Y_value = 0;
				   Z_value = 0;
				   mask = 3'b111;
				   timer = 4'b1111;
				   key = 0;
    	           bid_cost = 1;
    	           end
    Unlocked_mode: begin
    	           unique case(Unlocked_state)
                     s_Unlock:      begin
									                                    case(C_op)
                                     NoOperation:  begin
									                Unlocked_nextstate = s_NoOperation;
													NextState = Unlocked_mode;
													end
	                                  Unlock:       begin
													if(C_data !== key)
													  begin
                                                      Unlocked_nextstate = s_UnlockWait;
													  NextState = Unlocked_mode;
													  counter = timer;
													  end
                                                    else
													  begin
                                                      Unlocked_nextstate = s_Unlock;
													  NextState = Unlocked_mode;
                                                      end													  
													end
	                                  Lock:         begin
									                Unlocked_nextstate = s_Lock;
													NextState = locked_mode;
													key = C_data;
													end
	                                  LoadX:        begin
									                Unlocked_nextstate = s_LoadX;
													NextState = unlocked_mode;
													X_value = C_data;
													end
	                                  LoadY:        begin
									                Unlocked_nextstate = s_LoadY;
													NextState = unlocked_mode;
													Y_value = C_data;
													end
	                                  LoadZ:        begin
									                Unlocked_nextstate = s_LoadZ;
													NextState = unlocked_mode;
													Z_value = C_data;
													end
	                                  SetMask:      begin
									                Unlocked_nextstate = s_Mask;
													NextState = unlocked_mode;
													mask = C_data;
													end	                                  
									  SetTimer:     begin
									                Unlocked_nextstate = s_Timer;
													NextState = unlocked_mode;
													Timer = C_data;
													end
	                                  BidCharge:    begin
									                Unlocked_nextstate = s_BidCharge;
													NextState = unlocked_mode;
													bid_cost = C_data;
													end
                                    endcase

                                    end	
                     s_UnlockWait:  begin
					                if(counter === 0)
									  Unlocked_nextstate = s_Unlock;
									else
									  begin
									  counter = counter - 4'b1; //is this correct???
									  Unlocked_nextstate = s_UnlockWait;
									  end
                                    end
                     s_NoOperation: begin
					                case(C_op)
                                      NoOperation:  Unlocked_nextstate = s_NoOperation;
	                                  Unlock:       begin
													if(C_data !== key)
													  begin
                                                      Unlocked_nextstate = s_UnlockWait;
													  counter = timer;
													  end
                                                    else
                                                      Unlocked_nextstate = s_Unlock;													
													end
	                                  Lock:         begin
									                Unlocked_nextstate = s_Lock;
													key = C_data;
													end
	                                  LoadX:        begin
									                Unlocked_nextstate = s_LoadX;
													X_value = C_data;
													end
	                                  LoadY:        begin
									                Unlocked_nextstate = s_LoadY;
													Y_value = C_data;
													end
	                                  LoadZ:        begin
									                Unlocked_nextstate = s_LoadZ;
													Z_value = C_data;
													end
	                                  SetMask:      begin
									                Unlocked_nextstate = s_Mask;
													mask = C_data;
													end	                                  SetTimer:     Unlocked_nextstate = s_Timer;
	                                  BidCharge:    begin
									                Unlocked_nextstate = s_BidCharge;
													bid_cost = C_data;
													end
                                    endcase
                                    end
                     s_Lock:        begin
                                    case(C_op)
                                      NoOperation:  Unlocked_nextstate = s_NoOperation;
	                                  Unlock:       begin
													if(C_data !== key)
													  begin
                                                      Unlocked_nextstate = s_UnlockWait;
													  counter = timer;
													  end
                                                    else
                                                      Unlocked_nextstate = s_Unlock;													
													end
	                                  Lock:         begin
									                Unlocked_nextstate = s_Lock;
													key = C_data;
													end
	                                  LoadX:        begin
									                Unlocked_nextstate = s_LoadX;
													X_value = C_data;
													end
	                                  LoadY:        begin
									                Unlocked_nextstate = s_LoadY;
													Y_value = C_data;
													end
	                                  LoadZ:        begin
									                Unlocked_nextstate = s_LoadZ;
													Z_value = C_data;
													end
	                                  SetMask:      begin
									                Unlocked_nextstate = s_Mask;
													mask = C_data;
													end	                                  SetTimer:     Unlocked_nextstate = s_Timer;
	                                  BidCharge:    begin
									                Unlocked_nextstate = s_BidCharge;
													bid_cost = C_data;
													end
                                    endcase									
                                    end
                     s_LoadX:
                     s_LoadY:
                     s_LoadZ:
                     s_Mask:
                     s_Timer:
                     s_BidCharge:					 
				   endcase
    	           end
	Locked_mode:   begin
                   
    	           end
    endcase
end

/*
task logic ControlUnit;
  input [3:0] Opcode;
  output enum {u_NoOperation, u_Unlock, u_Lock, u_LoadX, u_LoadY, u_LoadZ, u_Mask, u_Timer, u_BidCharge} u_NextState;
  
  case(Opcode)
  	NoOperation:  u_NextState = u_NoOperation;
	Unlock:       u_NextState = u_Unlock; //do we need to store key here or in next cycle
	Lock:         u_NextState = u_Lock;
	LoadX:        u_NextState = u_LoadX;
	LoadY:        u_NextState = u_LoadY;
	LoadZ:        u_NextState = u_LoadZ;
	SetMask:      u_NextState = u_SetMask;
	SetTimer:     u_NextState = u_Timer;
	BidCharge:    u_NextState = u_BidCharge;
  endcase

endfunction
*/

endmodule
