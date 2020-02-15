// Module: fifo_sync.v
// Author: Joshua Conner
//
// Decription:
//
// Notes:
//

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
    output reg [DATA_WIDTH-1:0] rdDataOut,
    output isEmptyOut,
    output isFullOut);

  reg [DATA_WIDTH-1:0] fifoBuffer [FIFO_DEPTH-1:0];

  integer fifoDataCount;
  integer wrAddr;
  integer rdAddr;

  // Count number of valid data elements in FIFO buffer
  always @ (posedge clkIn)
  begin
    if (rstIn == 1'b1) begin
      fifoDataCount <= 0;
    end
    else begin
      if (rdEnIn == 1'b1 & wrEnIn == 1'b0 & fifoDataCount > 0) begin
        fifoDataCount <= fifoDataCount - 1;
      end
      else if (rdEnIn == 1'b0 & wrEnIn == 1'b1 & fifoDataCount < FIFO_DEPTH) begin
        fifoDataCount <= fifoDataCount + 1;
      end
    end
  end

  always @ (posedge clkIn)
  begin
    if (rstIn == 1'b1) begin
      wrAddr <= 0;
    end
    else if (wrEnIn == 1'b1 & fifoDataCount < FIFO_DEPTH) begin
      fifoBuffer[wrAddr] = wrDataIn;

      if (wrAddr == FIFO_DEPTH-1) begin
        wrAddr = 0;
      end
      else begin
        wrAddr = wrAddr + 1;
      end
    end
  end

  always @ (posedge clkIn)
  begin
    if (rstIn == 1'b1) begin
      rdAddr <= 0;
    end
    else if (rdEnIn == 1'b1 & fifoDataCount > 0) begin
      rdDataOut = fifoBuffer[rdAddr];

      if (rdAddr == FIFO_DEPTH-1) begin
        rdAddr = 0;
      end
      else begin
        rdAddr = rdAddr + 1;
      end
    end
  end

  assign isFullOut  = (fifoDataCount == FIFO_DEPTH) ? 1'b1 : 1'b0;
  assign isEmptyOut = (fifoDataCount == 0) ? 1'b1 : 1'b0;
endmodule