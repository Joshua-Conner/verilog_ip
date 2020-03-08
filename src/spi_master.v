// Module Name: spi_master.v
// Author     : Joshua Conner
// Description: SPI master interface
// Notes      : 

module spi_master
  # (
    parameter SYSTEM_CLK_FREQ = 100_000_000,
    parameter SCLK_FREQ       = 1_000_000,
    parameter SYSTEM_CLK_PER  = 10,
    parameter MIN_CS_SETUP    = 100,
    parameter MIN_CS_HOLD     = 20,
    parameter MIN_CS_DISABLE  = 20,
    parameter CPOL            = 1'b0,
    parameter CPHA            = 1'b0,
    parameter SPI_DATA_WIDTH  = 8,
    parameter CS_DEVICE_COUNT = 1)
  (
    input  clkIn,
    input  rstIn,
    input  enIn,
    output busyOut,
    input  loadDataIn,
    output validDataOut,
    input  [SPI_DATA_WIDTH-1:0] dataRxIn,
    output [SPI_DATA_WIDTH-1:0] dataTxOut,
    output spiClkOut,
    output [CS_DEVICE_COUNT-1:0] spiCsLowOut,
    output spiMosiOut,
    input  spiMisoIn);

  localparam CS_SETUP_COUNT   = MIN_CS_SETUP   / SYSTEM_CLK_PER;
  localparam CS_HOLD_COUNT    = MIN_CS_HOLD    / SYSTEM_CLK_PER;
  localparam CS_DISABLE_COUNT = MIN_CS_DISABLE / SYSTEM_CLK_PER;

  parameter STATE_WIDTH = 3;

  parameter STATE_IDLE             = 3'b000;
  parameter STATE_CS_H_TO_L        = 3'b001;
  parameter STATE_CS_SETUP_DELAY   = 3'b010;
  parameter STATE_TRANSMIT         = 3'b011;
  parameter STATE_CS_HOLD_DELAY    = 3'b100;
  parameter STATE_CS_L_TO_H        = 3'b101;
  parameter STATE_CS_DISABLE_DELAY = 3'b110;

  reg [STATE_WIDTH-1:0] spiState;

  reg [SPI_DATA_WIDTH-1:0] txData;
  reg [SPI_DATA_WIDTH-1:0] rxData;
  wire txShiftEn; // Shift dataRx out to MOSI
  wire rxShiftEn; // Shift MISO into dataTx
  reg spiClkEnIn;

  wire spiClkLocal;
  wire risingSpiClkEdgePulse;
  wire fallingSpiClkEdgePulse;
  reg spiCsLowLocal;
  reg spiMosiLocal;
  reg validDataLocal;
  reg [SPI_DATA_WIDTH-1:0] dataTxLocal;

  integer csSetupDelayCount;
  integer csHoldDelayCount;
  integer csDisableDelayCount;
  
  integer bitCount; // Number of bits shifted in
  integer byteCount;

  // Local signals to outgoing
  assign spiClkOut    = spiClkLocal;
  assign spiCsLowOut  = spiCsLowLocal;
  assign spiMosiOut   = spiMosiLocal;
  assign validDataOut = validDataLocal;
  assign dataTxOut    = dataTxLocal;

  // Update 
  always @ (posedge clkIn) begin
    if (rstIn == 1'b1) begin
      dataTxLocal = 0;
    end
    else begin
      if (validDataLocal == 1'b1) begin
        dataTxLocal = txData;
      end
    end
  end

  always @ (posedge clkIn) begin
    if (rstIn == 1'b1) begin
      spiState            <= STATE_IDLE;
      spiClkEnIn          <= 1'b0;
      spiCsLowLocal       <= 1'b1;
      spiMosiLocal        <= 1'bZ;
      csSetupDelayCount   <= 0;
      csHoldDelayCount    <= 0;
      csDisableDelayCount <= 0;
      txData              <= 0;
      rxData              <= 0;
      bitCount            <= 0;
      byteCount           <= 0;
      validDataLocal      <= 0;
    end
    else begin
      validDataLocal = 1'b0;

      case (spiState)
        STATE_IDLE :
          begin
            spiCsLowLocal = 1'b1;

            if (enIn == 1'b1) begin
              spiState = STATE_CS_H_TO_L;
            end
          end
        STATE_CS_H_TO_L :
          begin
            spiCsLowLocal = 1'b0;

            spiState = STATE_CS_SETUP_DELAY;
          end
        STATE_CS_SETUP_DELAY :
          begin
            if (csSetupDelayCount == CS_SETUP_COUNT-1) begin
              csSetupDelayCount = 0;

              // Load data on to RX register
              rxData = dataRxIn;
              spiMosiLocal = rxData[SPI_DATA_WIDTH-1];
              
              spiState = STATE_TRANSMIT;
            end
            else begin
              csSetupDelayCount = csSetupDelayCount + 1;
            end
          end
        STATE_TRANSMIT :
          begin
            spiClkEnIn = 1'b1;
            spiMosiLocal = rxData[SPI_DATA_WIDTH-1];

            if (bitCount == 0) begin
              rxData = dataRxIn;
            end

            // Shift MISO into TX register
            if (txShiftEn == 1'b1) begin
              txData = {txData[SPI_DATA_WIDTH-2:0], spiMisoIn};
            end

            // Shift RX register onto MOSI
            if (rxShiftEn == 1'b1) begin
              rxData = {rxData[SPI_DATA_WIDTH-2:0], 1'b0};

              bitCount = bitCount + 1;

              if (bitCount == SPI_DATA_WIDTH) begin
                validDataLocal = 1'b1;
                byteCount      = byteCount + 1;
                bitCount       = 0;
                
                // Exit only after receiving the last bit of current byte
                if (enIn == 1'b0) begin
                  spiClkEnIn = 1'b0;

                  spiState = STATE_CS_HOLD_DELAY;
                end
              end
            end
          end
        STATE_CS_HOLD_DELAY :
          begin
            if (csHoldDelayCount == CS_HOLD_COUNT-1) begin
              csHoldDelayCount = 0;

              spiState = STATE_CS_L_TO_H;
            end
            else begin
              csHoldDelayCount = csHoldDelayCount + 1;
            end
          end
        STATE_CS_L_TO_H :
          begin
            spiCsLowLocal = 1'b1;
            spiMosiLocal  = 1'bZ;

            spiState = STATE_CS_DISABLE_DELAY;
          end
        STATE_CS_DISABLE_DELAY :
          begin
            if (csDisableDelayCount == CS_DISABLE_COUNT-1) begin
              csDisableDelayCount = 0;

              spiState = STATE_IDLE;
            end
            else begin
              csDisableDelayCount = csDisableDelayCount + 1;
            end
          end
        default :
          spiState = STATE_IDLE;
      endcase
    end
  end

  spi_clk_gen # (
    .SYSTEM_CLK_FREQ(SYSTEM_CLK_FREQ),
    .SCLK_FREQ(SCLK_FREQ),
    .CPOL(CPOL),
    .CPHA(CPOL))
   SPI_CLK (
    .clkIn(clkIn),
    .rstIn(rstIn),
    .enIn(spiClkEnIn),
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