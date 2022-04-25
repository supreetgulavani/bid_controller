module BIDS22coverage(BIDS22bfm bfm);

import BIDS22pkg::*;

bit clk, reset_n;
bit X_bid, X_retract, Y_bid, Y_retract, Z_bid, Z_retract, C_start;
bit [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
bit [31:0] C_data;
bit [3:0] C_op;
bit X_ack, X_win, Y_ack, Y_win, Z_ack, Z_win, ready, roundOver;
bit [1:0] X_err, Y_err, Z_err;
bit [31:0] X_balance, Y_balance, Z_balance, maxBid;
bit [2:0] err;

covergroup bid_input_signals;
    bidsigX : coverpoint X_bid;
    bidsigY : coverpoint Y_bid;
    bidsigZ : coverpoint Z_bid;
    retractsigX : coverpoint X_retract;
    retractsigY : coverpoint Y_retract;
    retractsigZ : coverpoint Z_retract;
    bid_amountX : coverpoint X_bidAmt {
	    option.at_least = 1;
        bins X0 = {'h0000};
        bins X1 = {['h0001:'hFFFE]};
        bins X2 = {'hFFFF};
    } 
    bid_amountY : coverpoint Y_bidAmt {
	    option.at_least = 1;
        bins Y0 = {'h0000};
        bins Y1 = {['h0001:'hFFFE]};
        bins Y2 = {'hFFFF};
    } 
    bid_amountZ : coverpoint Z_bidAmt{
	    option.at_least = 1;
        bins Z0 = {'h0000};
        bins Z1 = {['h0001:'hFFFE]};
        bins Z2 = {'hFFFF};
    } 
    opcodeC : coverpoint C_op {
	    option.at_least = 1;
        bins C0 = {[0:8]};
    }
    dataC : coverpoint C_data{
	    option.at_least = 1;
        bins dC0 = {'h00000000};
        bins dC1 = {['h00000001:'hFFFFFFFE]};
        bins dC2 = {'hFFFFFFFF};
    }
    startC : coverpoint C_start;
    startCxbidsigX : cross startC, bidsigX;
    startCxbidsigY : cross startC, bidsigY;
    startCxbidsigZ : cross startC, bidsigZ;
    startCxbidsigXYZ : cross startC, bidsigX, bidsigY, bidsigZ;

endgroup

covergroup bid_output_signals;
    acksigX : coverpoint X_ack;
    acksigY : coverpoint Y_ack;
    acksigZ : coverpoint Z_ack;
    readysig : coverpoint ready;
    roundOversig : coverpoint roundOver;
    errX : coverpoint X_err;
    errY : coverpoint Y_err;
    errZ : coverpoint Z_err;
    errsig : coverpoint err {
        bins err0 = { [0:5] };
    }
    balanceX : coverpoint X_balance {
	    option.at_least = 1;
        bins balanceX0 = {'h00000000};
        bins balanceX1 = {['h00000001:'hFFFFFFFE]};
        bins balanceX2 = {'hFFFFFFFF};
    }
    balanceY : coverpoint Y_balance {
	    option.at_least = 1;
        bins balanceY0 = {'h00000000};
        bins balanceY1 = {['h00000001:'hFFFFFFFE]};
        bins balanceY2 = {'hFFFFFFFF};
    }
    balanceZ : coverpoint Z_balance {
	    option.at_least = 1;
        bins balanceZ0 = {'h00000000};
        bins balanceZ1 = {['h00000001:'hFFFFFFFE]};
        bins balanceZ2 = {'hFFFFFFFF};
    }
    bidmax : coverpoint maxBid {
	    option.at_least = 1;
        bins bidmax0 = {'h00000000};
        bins bidmax1 = {['h00000001:'hFFFFFFFE]};
        bins bidmax2 = {'hFFFFFFFF};
    }
    winX : coverpoint X_win;
    winY : coverpoint Y_win;
    winZ : coverpoint Z_win;
endgroup

bid_input_signals input_signals;
bid_output_signals output_signals;

initial begin: coverage_block
  
  input_signals = new();
  output_signals = new();
  
  forever begin: sampling_block
    @(posedge bfm.clk);
    X_bid = bfm.X_bid;
	X_retract = bfm.X_retract;
    Y_bid = bfm.Y_bid;
	Y_retract = bfm.Y_retract;
    Z_bid = bfm.Z_bid;
	Z_retract = bfm.Z_retract;
	C_start = bfm.C_start;
    X_bidAmt = bfm.X_bidAmt;
	Y_bidAmt = bfm.Y_bidAmt;
	Z_bidAmt = bfm.Z_bidAmt;
    C_data = bfm.C_data;
    C_op = bfm.C_op;
    X_ack = bfm.X_ack;
	X_win = bfm.X_win;
    Y_ack = bfm.Y_ack;
	Y_win = bfm.Y_win;
    Z_ack = bfm.Z_ack;
	Z_win = bfm.Z_win;
    ready = bfm.ready;
	roundOver = bfm.roundOver;
    X_err = bfm.X_err;
    Y_err = bfm.Y_err;
    Z_err = bfm.Z_err;
    X_balance = bfm.X_balance;
	Y_balance = bfm.Y_balance;
	Z_balance = bfm.Z_balance;
	maxBid = bfm.maxBid;
    err = bfm.err;
	
	input_signals.sample();
	output_signals.sample();
	
  end: sampling_block
end: coverage_block

endmodule: BIDS22coverage
/*
covergroup state_check @(posedge clk);
    option.at_least = 1;
    fsm_cov : coverpoint b1.State {
        bins s0 = (Reset_mode => Unlocked_mode);
        bins s1 = (Unlocked_mode => Locked_mode);
        bins s2 = (Locked_mode => RoundActive_mode);
        bins s3 = (RoundActive_mode => RoundOver_mode);
        bins s4 = (RoundOver_mode => Locked_mode);
        bins s5 = (RoundOver_mode => Unlocked_mode);
        bins s6 = (RoundOver_mode => RoundActive_mode);
        bins s7 = (RoundOver_mode => Timer_mode);
        bins s8 = (Locked_mode => Unlocked_mode);
        bins s9 = (Locked_mode => Timer_mode);
        bins s10 = (Timer_mode => Locked_mode);
        bins s11 = (Timer_mode => Unlocked_mode);
        bins s12 = (Unlocked_mode => Unlocked_mode);
        bins s13 = (Locked_mode => Locked_mode);
        bins s14 = (RoundActive_mode => RoundActive_mode);
        bins s15 = (Timer_mode => Timer_mode);
    }
endgroup
*/
