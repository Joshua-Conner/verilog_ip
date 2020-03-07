module i2c_master
  #(
    parameter SYSTEM_CLK_FREQUENCY = 100000000,
    parameter I2C_CLK_FREQUENCY = 250000,
    parameter DATA_WIDTH = 8)
  (
    input clkIn,
    input rstIn,
    input rdEnIn,
    input wrEnIn,
    input [DATA_WIDTH-1:0] rdDataIn,

    output reg [DATA_WIDTH-1:0] wrDataOut,
    output reg rdFifoEnOut,
    output reg wrFifoEnOut,
    output reg sclOut,

    inout sdaBi);

  parameter SCL_HIGH     = 2'b00;
  parameter SCL_HIGH_MID = 2'b01;
  parameter SCL_LOW      = 2'b10;
  parameter SCL_LOW_MID  = 2'b11;

  localparam SCL_CLK_PERIOD_COUNT = SYSTEM_CLK_FREQUENCY / I2C_CLK_FREQUENCY;
  localparam SCL_CLK_DIV_COUNT = SCL_CLK_PERIOD_COUNT / 4;

  reg [1:0] sclState;

  integer sclDivCount;

  parameter IDLE       = 4'b0000;
  parameter START_COND = 4'b0001;
  parameter SEND_ADDR  = 4'b0010;
  parameter WAIT_ACK   = 4'b0011;
  parameter TX_DATA    = 4'b0100;
  parameter RX_DATA    = 4'b0101;
  parameter TX_ACK     = 4'b0110;
  parameter RX_ACK     = 4'b0111;
  parameter STOP_COND  = 4'b1000;

  reg [3:0] i2cState;
  reg sclEn;
  reg sdaR;
  reg rdSdaEnLow;

  always @ (posedge clkIn) begin
    if (rstIn == 1'b1) begin
      sclState    <= SCL_HIGH;
      sclDivCount <= 0;
      sclOut      <= 1'b1;
    end
    else begin
      case (sclState)
        SCL_HIGH :
          begin
            sclOut <= 1'b1;

            if (sclEn == 1'b1) begin
              if (sclDivCount == SCL_CLK_DIV_COUNT-1) begin
                sclDivCount <= 0;

                sclState <= SCL_HIGH_MID;
              end
              else begin
                sclDivCount <= sclDivCount + 1;
              end
            end
            else begin
              sclDivCount <= 0;

              sclState <= SCL_HIGH;
            end
          end
        // Read incoming data halfway through high clock pulse
        SCL_HIGH_MID :
          begin
            sclOut <= 1'b1;
            
            if (sclEn == 1'b1) begin
              if (sclDivCount == SCL_CLK_DIV_COUNT-1) begin
                sclDivCount <= 0;

                sclState <= SCL_LOW;
              end
              else begin
                sclDivCount <= sclDivCount + 1;
              end
            end
            else begin
              sclDivCount <= 0;

              sclState <= SCL_HIGH;
            end
          end
        SCL_LOW :
          begin
            sclOut <= 1'b0;
            
            if (sclEn == 1'b1) begin
              if (sclDivCount == SCL_CLK_DIV_COUNT-1) begin
                sclDivCount <= 0;

                sclState <= SCL_LOW_MID;
              end
              else begin
                sclDivCount <= sclDivCount + 1;
              end
            end
            else begin
              sclDivCount <= 0;

              sclState <= SCL_HIGH;
            end
          end
        // Update outgoing data halfway through low clock pulse
        SCL_LOW_MID :
          begin
            sclOut <= 1'b0;
            
            if (sclEn == 1'b1) begin
              if (sclDivCount == SCL_CLK_DIV_COUNT-1) begin
                sclDivCount <= 0;

                sclState <= SCL_HIGH;
              end
              else begin
                sclDivCount <= sclDivCount + 1;
              end
            end
            else begin
              sclDivCount <= 0;

              sclState <= SCL_HIGH;
            end
          end
      endcase
    end
  end

  always @ (posedge clkIn) begin
    if (rstIn == 1'b1) begin
      i2cState <= IDLE;
      sclEn <= 1'b0;
      sdaR  <= 1'b1;
      rdSdaEnLow <= 1'b1;
    end
    else begin
      case (i2cState)
        IDLE :
          begin
            sclEn <= 1'b0;
            rdSdaEnLow <= 1'b1;
            
            if (rdEnIn == 1'b1 || wrEnIn == 1'b1) begin
              i2cState <= START_COND;
            end
          end
        START_COND :
          begin
            rdSdaEnLow = 1'b1;
            sdaR  = 1'b0;
            sclEn = 1'b1; 
          end
        // SEND_ADDR :
        // WAIT_ACK :
        // TX_DATA :
        // RX_DATA :
        // TX_ACK :
        // RX_ACK :
        // STOP_COND :
      endcase
    end
  end

  assign sdaBi = (rdSdaEnLow == 1'b1) ? sdaR : 1'bz;
endmodule