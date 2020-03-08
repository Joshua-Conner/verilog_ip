module spi_master_tb ();
  reg clk;
  reg rst;

  reg en;
  reg spiMiso;
  reg [7:0] rxData;

  // spi_master TEST (
  //   .clkIn(clk),
  //   .rstIn(rst),
  //   .enIn(en),
  //   .dataRxIn(rxData),
  //   .dataTxOut(),
  //   .spiClkOut(),
  //   .spiCsLowOut(),
  //   .spiMosiOut(),
  //   .spiMisoIn(spiMiso));

  adxl362_control TEST (
    .clkIn(clk),
    .rstIn(rst),
    .spiClkOut(),
    .spiCsLowOut(),
    .spiMosiOut(),
    .spiMisoIn(spiMiso));

  task automatic generate_mosi;
    begin
      forever begin
        spiMiso <= $random % 2;
        #1000;
      end
    end
  endtask

  task automatic spiTest;
    begin
      clk <= 0;
      rst <= 0;
      en  <= 0;
      spiMiso <= 1'bZ;
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
      rxData <= 8'h55;
      spiMiso <= 1'b1;
      #8000;

      rst <= 0;
      en  <= 1;
      rxData <= 8'hEE;
      spiMiso <= 1'b1;
      #8000;

      rst <= 0;
      en  <= 1;
      rxData <= 8'h02;
      spiMiso <= 1'b1;
      #8000;

      rst <= 0;
      en  <= 1;
      rxData <= 8'h39;
      spiMiso <= 1'b1;
      #8000;

      rst <= 0;
      en  <= 0;
    end
  endtask

  always
    #5 clk = !clk;

  initial begin
    $srandom(10);

    fork
      #1 spiTest();
      #1 generate_mosi();
    join
  end
endmodule