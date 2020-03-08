module spi_clk_gen
  # (
    parameter SYSTEM_CLK_FREQ = 100_000_000,
    parameter SCLK_FREQ = 1_000_000,
    parameter CPOL = 1'b0,
    parameter CPHA = 1'b0)
  (
    input  clkIn,
    input  rstIn,
    input  enIn,
    output risingSpiClkEdgePulseOut,
    output fallingSpiClkEdgePulseOut,
    output spiClkOut);

  localparam SPI_PERIOD_COUNT   = SYSTEM_CLK_FREQ / SCLK_FREQ;
  localparam SPI_CLK_HIGH_COUNT = (SPI_PERIOD_COUNT / 2) - 2; // Include extra count for clock transition state
  localparam SPI_CLK_LOW_COUNT  = (SPI_PERIOD_COUNT / 2) - 2; // Include extra count for clock transition state

  parameter STATE_CLK_WIDTH = 2;

  parameter STATE_CLK_LOW    = 2'b00;
  parameter STATE_CLK_L_TO_H = 2'b01;
  parameter STATE_CLK_HIGH   = 2'b10;
  parameter STATE_CLK_H_TO_L = 2'b11;

  reg [STATE_CLK_WIDTH-1:0] spiClkState;
  reg spiClkLocal;
  reg risingSpiClkEdgePulse;
  reg fallingSpiClkEdgePulse;

  integer spiClkPeriodCount;

  assign spiClkOut                 = (enIn == 1'b1) ? ((CPOL == 1'b0) ? spiClkLocal : ~spiClkLocal) : CPOL;
  assign risingSpiClkEdgePulseOut  = (CPOL == 1'b0) ? risingSpiClkEdgePulse : fallingSpiClkEdgePulse;
  assign fallingSpiClkEdgePulseOut = (CPOL == 1'b0) ? fallingSpiClkEdgePulse : risingSpiClkEdgePulse;
  
  always @ (posedge clkIn) begin
    if (rstIn == 1'b1) begin
      spiClkLocal            <= 1'b0;
      spiClkState            <= STATE_CLK_LOW;
      spiClkPeriodCount      <= 0;
      risingSpiClkEdgePulse  <= 1'b0;
      fallingSpiClkEdgePulse <= 1'b0;

    end
    else begin
      risingSpiClkEdgePulse  = 1'b0;
      fallingSpiClkEdgePulse = 1'b0;

      if (enIn == 1'b1) begin
        case (spiClkState)
          STATE_CLK_LOW :
            begin
              spiClkLocal = 1'b0;

              if (spiClkPeriodCount == SPI_CLK_LOW_COUNT) begin
                spiClkState = STATE_CLK_L_TO_H;
              end
              else begin
                spiClkPeriodCount = spiClkPeriodCount + 1;
              end
            end
          STATE_CLK_L_TO_H :
            begin
              risingSpiClkEdgePulse = 1'b1;
              spiClkPeriodCount     = 0;

              spiClkState = STATE_CLK_HIGH;
            end
          STATE_CLK_HIGH :
            begin
              spiClkLocal = 1'b1;

              if (spiClkPeriodCount == SPI_CLK_HIGH_COUNT) begin
                spiClkState = STATE_CLK_H_TO_L;
              end
              else begin
                spiClkPeriodCount = spiClkPeriodCount + 1;
              end
            end
          STATE_CLK_H_TO_L :
            begin
              fallingSpiClkEdgePulse = 1'b1;
              spiClkPeriodCount      = 0;

              spiClkState = STATE_CLK_LOW;
            end
          default :
            spiClkState = STATE_CLK_LOW;
        endcase
      end
      else begin
        spiClkState       = STATE_CLK_LOW;
        spiClkPeriodCount = 0;
      end
    end
  end
endmodule