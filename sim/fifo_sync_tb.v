module fifo_sync_tb
  (
  );

reg clk;
reg rst;

reg fifoWrEn;
reg fifoRdEn;
reg [7:0] dataIn;

wire [7:0] dataOut;

  fifo_sync TEST_FIFO (
    .clkIn(clk),
    .rstIn(rst),
    .wrEnIn(fifoWrEn),
    .rdEnIn(fifoRdEn),
    .wrDataIn(dataIn),
    .rdDataOut(dataOut),
    .isEmptyOut(),
    .isFullOut());

  always
    #5 clk = !clk;

  initial begin
    clk = 1;
    rst = 0;
    fifoRdEn = 0;
    fifoWrEn = 0;
    #10;

    rst = 1;
    #10;

    rst = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hAA;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hBB;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hCC;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hDD;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hEE;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hFF;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hAB;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hBC;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'hCD;
    #10;
    fifoWrEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'h11;
    #10;
    fifoWrEn = 0;
    #10;

    fifoWrEn = 1;
    dataIn   = 8'h22;
    #10;
    fifoWrEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;

    fifoRdEn = 1;
    #10;
    fifoRdEn = 0;
    #10;
  end
endmodule