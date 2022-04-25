package BIDS22pkg;

typedef enum bit[3:0] {NoOperation_op = 4'b000,
  Unlock_op = 4'b0001,
  Lock_op = 4'b0010,
  LoadX_op = 4'b0011,
  LoadY_op = 4'b0100,
  LoadZ_op = 4'b0101,
  SetMask_op = 4'b0110,
  SetTimer_op = 4'b0111,
  BidCharge_op = 4'b1000,
  RoundActive_op = 4'b1001,
  RoundOver_op = 4'b1010} operation_t;
  
endpackage: BIDS22pkg