module top;

BIDS22bfm bfm();
BIDS22tester tester_i (bfm);
BIDS22coverage coverage_i (bfm);

BIDS22model DUV (.clk(bfm.clk), .reset_n(bfm.reset_n), .X_bidAmt(bfm.X_bidAmt),
  .X_bid(bfm.X_bid), .X_retract(bfm.X_retract), .Y_bidAmt(bfm.Y_bidAmt),
  .Y_bid(bfm.Y_bid), .Y_retract(bfm.Y_retract), .Z_bidAmt(bfm.Z_bidAmt),
  .Z_bid(bfm.Z_bid), .Z_retract(bfm.Z_retract), .C_data(bfm.C_data),
  .C_op(bfm.C_op), .C_start(bfm.C_start), .X_ack(bfm.X_ack), .X_err(bfm.X_err),
  .X_balance(bfm.X_balance), .Y_ack(bfm.Y_ack), .Y_err(bfm.Y_err),
  .Y_balance(bfm.Y_balance), .Z_ack(bfm.Z_ack), .Z_err(bfm.Z_err),
  .Z_balance(bfm.Z_balance), .X_win(bfm.X_win), .Y_win(bfm.Y_win), .Z_win(bfm.Z_win),
  .ready(bfm.ready), .err(bfm.err), .roundOver(bfm.roundOver), .maxBid(bfm.maxBid));

endmodule: top
  
  