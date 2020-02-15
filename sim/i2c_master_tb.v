module i2c_master_tb();
  reg clk;
  reg rst;

  i2c_master TEST (
    .clkIn(clk),
    .rstIn(rst),
    .dataIn(),
    .dataOut(),
    .sclOut(),
    .sdaOut());

  always
    #5 clk = !clk;

  initial begin
      clk = 1;
      rst = 0;
      #10;

      rst = 1;
      #10;
      
      rst = 0;
      #10;
  end
endmodule