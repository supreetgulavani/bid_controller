/////////////////////////////////////////////////////////////////////
// ECE593 - Fundamentals of Pre-Silicon Validation
//			Bid Controller
//
// Group 16: Supreet Gulavani, Sreeja Boyina
//////////////////////////////////////////////////////////////////////


// module definition
module BIDS22(
    input logic         clk, reset_n, x_bid, x_retract, y_bid, y_retract, z_bid, z_retract, c_start,
    input logic [15:0]  x_bidAmt, y_bidAmt, z_bidAmt,
    input logic [31:0]  c_data,
    input logic [3:0]   c_op,
    output logic        x_ack, x_win, y_ack, y_win, z_ack, z_win, ready, roundOver,
    output logic [1:0]  x_err, y_err, z_err,
    output logic [31:0] x_balance, y_balance, z_balance, maxBid,
    output logic [2:0]  err;
)

// internal registers
logic [3:0] timer;
logic bid_cost;
logic [31:0] key;
logic [2:0] mask;

// reset logic
always_ff @(posedge clk) begin
	if (!reset_n)   c_op <= 4'b0000;
	else begin
        x_ack = 0;
        x_err = 'b01;
        x_win = 0
        y_ack = 0;
        y_err = 'b01;
        y_win = 0;
        z_ack = 0;
        z_err = 'b01;
        z_win = 0;
        timer = 'b1111;
        key = 0;
        mask = 'b111;
        bid_cost = 1;
        c_op <= 4'b0001;
    end
end

// output and next state logic
always_comb begin
    case (c_op) 
        // no op
        4'b0000: begin
           
        end
        // unlock
        4'b0001: begin
            c_start = 0;
            case (c_op)
                // load x value
                4'b0011: begin

                end
                // load y value
                4'b0100: begin

                end
                // load z value
                4'b0101: begin

                end
                // set xyz mask
                4'b0110: begin

                end
                // set timer
                4'b0111: begin

                end
            end
        end
        // lock
        4'b0010: begin
            c_start = 1;

        end
     

end
