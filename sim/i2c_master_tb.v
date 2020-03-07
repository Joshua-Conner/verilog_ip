module i2c_master_tb();
  reg clk;
  reg rst;
  reg rdCtrl;

  i2c_master TEST (
    .clkIn(clk),
    .rstIn(rst),
    .rdEnIn(rdCtrl),
    .wrEnIn(),
    .rdDataIn(),
    .wrDataOut(),
    .rdFifoEnOut(),
    .wrFifoEnOut(),
    .sclOut(),
    .sdaBi());

  always
    #5 clk = !clk;

  initial begin
      clk = 1;
      rst = 0;
      rdCtrl <= 0;
      #10;

      rst = 1;
      #10;
      
      rst = 0;
      #1000;
      
      rdCtrl <= 1;
      #10;
  end
endmodule