module top ();

parameter CLK_PERIOD = 10;
parameter Reset_mode = 0;
parameter Unlocked_mode = 1;
parameter Locked_mode = 2;
parameter RoundActive_mode = 3;
parameter RoundOver_mode = 4;
parameter Timer_mode = 5;

logic         clk, reset_n, X_bid, X_retract, Y_bid, Y_retract, Z_bid, Z_retract, C_start;
logic [15:0]  X_bidAmt, Y_bidAmt, Z_bidAmt;
logic [31:0]  C_data;
logic [3:0]   C_op;
logic        X_ack, X_win, Y_ack, Y_win, Z_ack, Z_win, ready, roundOver;
logic [1:0]  X_err, Y_err, Z_err;
logic [31:0] X_balance, Y_balance, Z_balance, maxBid;
logic [2:0]  err;

bit start;


real    BIDSIGX, BIDSIGY, BIDSIGZ, RETRACTSIGX, RETRACTSIGY, RETRACTSIGZ, BID_AMOUNTX, BID_AMOUNTY, BID_AMOUNTZ, OPCODEC, DATAC, STARTC, STARTCXBIDSIGX,
        STARTCXBIDSIGY, STARTCXBIDSIGZ, STARTCXBIDSIGXYZ, ACKSIGX, ACKSIGY, ACKSIGZ, READYSIG, ROUNDOVERSIG, ERRX, ERRY, ERRZ, ERRSIG, BALANCEX, 
        BALANCEY, BALANCEZ, BIDMAX, WINX, WINY, WINZ, STATE;

// clock gen
always begin: clock_generator
 	#(CLK_PERIOD / 2) clk = ~clk;
end: clock_generator


BIDS22model b1(.*);

covergroup bid_input_signals with function sample(bit X_bid , Y_bid, Z_bid, X_retract, Y_retract, Z_retract, C_start, bit [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt, 
                                                  bit [31:0] C_data, bit [3:0] C_op);
    bidsigX : coverpoint X_bid;
    bidsigY : coverpoint Y_bid;
    bidsigZ : coverpoint Z_bid;
    retractsigX : coverpoint X_retract;
    retractsigY : coverpoint Y_retract;
    retractsigZ : coverpoint Z_retract;
    bid_amountX : coverpoint X_bidAmt {
        bins X0 = { [0:16383] };
        bins X1 = { [16383:32767] };
        bins X2 = { [32767:49151] };
        bins X3 = { [49151:65535] };
    } 
    bid_amountY : coverpoint Y_bidAmt {
        bins Y0 = { [0:16383] };
        bins Y1 = { [16383:32767] };
        bins Y2 = { [32767:49151] };
        bins Y3 = { [49151:65535] };
    } 
    bid_amountZ : coverpoint Z_bidAmt{
        bins Z0 = { [0:16383] };
        bins Z1 = { [16383:32767] };
        bins Z2 = { [32767:49151] };
        bins Z3 = { [49151:65535] };
    } 
    opcodeC : coverpoint C_op {
        bins C0 = { [0:8] };
    }
    dataC : coverpoint C_data{
        bins dC0 = { [0:8] };
        bins dC1 = { [9:4294967292] };
        bins dC2 = { [4294967293:4294967295] };
    }
    startC : coverpoint C_start;
    startCxbidsigX : cross startC, bidsigX;
    startCxbidsigY : cross startC, bidsigY;
    startCxbidsigZ : cross startC, bidsigZ;
    startCxbidsigXYZ : cross startC, bidsigX, bidsigY, bidsigZ;

endgroup

covergroup bid_output_signals with function sample(bit X_ack, Y_ack, Z_ack, X_win, Y_win, Z_win, ready, roundOver, bit [1:0] X_err, Y_err, Z_err,
                                                   bit [31:0] X_balance, Y_balance, Z_balance, maxBid, bit [2:0] err);
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
        bins balanceX0 = { [0:8] };
        bins balanceX1 = { [9:4294967292] };
        bins balanceX2 = { [4294967293:4294967295] };
    }
    balanceY : coverpoint Y_balance {
        bins balanceY0 = { [0:8] };
        bins balanceY1 = { [9:4294967292] };
        bins balanceY2 = { [4294967293:4294967295] };
    }
    balanceZ : coverpoint Z_balance {
        bins balanceZ0 = { [0:8] };
        bins balanceZ1 = { [9:4294967292] };
        bins balanceZ2 = { [4294967293:4294967295] };
    }
    bidmax : coverpoint maxBid {
        bins bidmax0 = { [0:8] };
        bins bidmax1 = { [9:4294967292] };
        bins bidmax2 = { [4294967293:4294967295] };
    }
    winX : coverpoint X_win;
    winY : coverpoint Y_win;
    winZ : coverpoint Z_win;
endgroup

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


// random inputs generation and get_coverage
bids_gen bidg = new;
bid_input_signals bis = new;
bid_output_signals bos = new;
state_check sc = new;



// gets coverage 
task gen_coverage();
    // input coverage
    bis.sample(X_bid , Y_bid, Z_bid, X_retract, Y_retract, Z_retract, C_start, X_bidAmt, Y_bidAmt, Z_bidAmt, C_data, C_op);
    bos.sample(X_ack, Y_ack, Z_ack, X_win, Y_win, Z_win, ready, roundOver, X_err, Y_err, Z_err, X_balance, Y_balance, Z_balance, maxBid, err);
	
	BIDSIGX =  bis.bidsigX.get_coverage();
    BIDSIGY =  bis.bidsigY.get_coverage();
    BIDSIGZ =  bis.bidsigZ.get_coverage();
    RETRACTSIGX =  bis.retractsigX.get_coverage();
    RETRACTSIGY =  bis.retractsigY.get_coverage();
    RETRACTSIGZ =  bis.retractsigZ.get_coverage();
    BID_AMOUNTX =  bis.bid_amountX.get_coverage();
    BID_AMOUNTY =  bis.bid_amountY.get_coverage();
    BID_AMOUNTZ =  bis.bid_amountZ.get_coverage();
    OPCODEC = bis.opcodeC.get_coverage();
    DATAC = bis.dataC.get_coverage();
    STARTC = bis.startC.get_coverage();
    STARTCXBIDSIGX = bis.startCxbidsigX.get_coverage();
    STARTCXBIDSIGY = bis.startCxbidsigY.get_coverage();
    STARTCXBIDSIGZ = bis.startCxbidsigZ.get_coverage();
    STARTCXBIDSIGXYZ = bis.startCxbidsigXYZ.get_coverage();

    // output coverage
    ACKSIGX = bos.acksigX.get_coverage();
    ACKSIGY = bos.acksigY.get_coverage();
    ACKSIGZ = bos.acksigZ.get_coverage();
    READYSIG = bos.readysig.get_coverage();
    ROUNDOVERSIG  = bos.roundOversig.get_coverage();
    ERRX = bos.errX.get_coverage();
    ERRY = bos.errY.get_coverage();
    ERRZ = bos.errZ.get_coverage();
    ERRSIG = bos.errsig.get_coverage();
    BALANCEX =  bos.balanceX.get_coverage();
    BALANCEY = bos.balanceY.get_coverage();
    BALANCEZ = bos.balanceZ.get_coverage();
    BIDMAX = bos.bidmax.get_coverage();
    WINX =  bos.winX.get_coverage();
    WINY =  bos.winY.get_coverage();
    WINZ =  bos.winZ.get_coverage();
	
    // state coverage
    STATE = sc.fsm_cov.get_coverage();
	
	
    while (1);
  /*while ((BIDSIGX < 100.0) || (BIDSIGY < 100.0) || (BIDSIGZ < 100.0) || (RETRACTSIGX < 100.0) || (RETRACTSIGY < 100.0) || (RETRACTSIGZ < 100.0) || 
	    (BID_AMOUNTX < 100.0) || (BID_AMOUNTY < 100.0) || (BID_AMOUNTZ < 100.0) || (OPCODEC < 100.0) || (STARTC < 100.0) || (STARTCXBIDSIGX < 100.0) ||
        (STARTCXBIDSIGY  < 100.0) || (STARTCXBIDSIGZ < 100.0) || (STARTCXBIDSIGXYZ < 100.0) || (ACKSIGX < 100.0) || (ACKSIGY < 100.0) || (ACKSIGZ < 100.0) || 
		(READYSIG < 100.0) || (ROUNDOVERSIG < 100.0) || (ERRX < 100.0) || (ERRY < 100.0) || (ERRZ < 100.0) || (ERRSIG < 100.0) || (WINX < 100.0) || (WINY < 100.0) ||
		(WINZ < 100.0) || (STATE < 50.0));*/
		//BALANCEX, BALANCEY, BALANCEZ, BIDMAX
        
endtask : gen_coverage


initial begin
	
	if($test$plusargs("correctopcode")) bidg.isopcode.constraint_mode(1);
   // assert(bidg.randomize());
	
    X_bidAmt = bidg.X_bidAmt;
    Y_bidAmt = bidg.Y_bidAmt;
    Z_bidAmt = bidg.Z_bidAmt;
    X_bid = bidg.X_bid;
    Y_bid = bidg.Y_bid;
    Z_bid = bidg.Z_bid;
	X_retract = bidg.X_retract;     
    Y_retract = bidg.Y_retract;
    Z_retract = bidg.Z_retract; 
	C_data = bidg.C_data;
    C_op = bidg.C_op;
    C_start = bidg.C_start;
	
	bidg.printbid();
    

    if($test$plusargs("getcoverage")) gen_coverage();


end

endmodule
