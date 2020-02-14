-- Module: fifo_sync.v
-- Author: Joshua Conner
--
-- Decription:
--
-- Notes:
--

module fifo_sync 
  #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8)
  (
    input clkIn,
    input rstIn,
    input wrEnIn,
    input rdEnIn,
    input [DATA_WIDTH-1:0] wrDataIn,
    output [DATA_WIDTH-1:0] rdDataOut,
    output isEmptyOut,
    output isFullOut);

  integer fifoDataCount;
  integer wrAddr;
  integer rdAddr;
endmodule