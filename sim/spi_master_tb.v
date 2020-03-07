module spi_master_tb ();
  reg clk;
  reg rst;

  reg en;

  spi_master TEST (
    .clkIn(clk),
    .rstIn(rst),
    .enIn(en),
    .dataRxIn(),
    .dataTxOut(),
    .spiClkOut(),
    .spiCsLowOut(),
    .spiMosiOut(),
    .spiMisoIn());

  always
    #5 clk = !clk;

  initial begin
    clk <= 0;
    rst <= 0;
    en  <= 0;
    #10;

    rst <= 1;
    en  <= 0;
    #10;

    rst <= 0;
    en  <= 0;
    #10;

    #1000;

    rst <= 0;
    en  <= 1;
    #10;
  end
endmodule