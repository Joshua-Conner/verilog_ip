// Module Name: spi_master.v
// Author     : Joshua Conner
// Description: SPI master interface
// Notes      : 

module spi_master
  # (
    parameter SYSTEM_CLK_FREQ = 100_000_000,
    parameter SCLK_FREQ = 1_000_000,
    parameter CPOL = 1'b1,
    parameter CPHA = 1'b1,
    parameter SPI_DATA_WIDTH = 8,
    parameter CS_DEVICE_COUNT = 1)
  (
    input  clkIn,
    input  rstIn,
    input  enIn,
    input  [SPI_DATA_WIDTH-1:0] dataRxIn,
    output [SPI_DATA_WIDTH-1:0] dataTxOut,
    output spiClkOut,
    output [CS_DEVICE_COUNT-1:0] spiCsLowOut,
    output spiMosiOut,
    input  spiMisoIn);

  reg [SPI_DATA_WIDTH-1:0] txData;
  reg [SPI_DATA_WIDTH-1:0] rxData;
  wire txShiftEn; // Shift dataRx out to MOSI
  wire rxShiftEn; // Shift MISO into dataTx

  wire spiClkLocal;
  wire spiCsLowLocal;
  wire spiMosiLocal;
  wire risingSpiClkEdgePulse;
  wire fallingSpiClkEdgePulse;

  // Local signals to outgoing
  assign spiClkOut   = spiClkLocal;
  assign spiCsLowOut = spiCsLowLocal;
  assign spiMosiOut  = spiMosiLocal;

  spi_clk_gen # (
    .SYSTEM_CLK_FREQ(SYSTEM_CLK_FREQ),
    .SCLK_FREQ(SCLK_FREQ),
    .CPOL(CPOL),
    .CPHA(CPOL))
   SPI_CLK (
    .clkIn(clkIn),
    .rstIn(rstIn),
    .enIn(enIn),
    .risingSpiClkEdgePulseOut(risingSpiClkEdgePulse),
    .fallingSpiClkEdgePulseOut(fallingSpiClkEdgePulse),
    .spiClkOut(spiClkLocal));

  assign txShiftEn = (CPOL == 1'b0)  ?
                     ((CPHA == 1'b0) ? risingSpiClkEdgePulse  : fallingSpiClkEdgePulse) : 
                     ((CPHA == 1'b0) ? fallingSpiClkEdgePulse : risingSpiClkEdgePulse);
                     
  assign rxShiftEn = (CPOL == 1'b0)  ?
                     ((CPHA == 1'b0) ? fallingSpiClkEdgePulse : risingSpiClkEdgePulse) : 
                     ((CPHA == 1'b0) ? risingSpiClkEdgePulse  : fallingSpiClkEdgePulse);
endmodule