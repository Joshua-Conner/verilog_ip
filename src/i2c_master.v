module i2c_master
  #(
    parameter SYSTEM_CLK_FREQUENCY = 100000000,
    parameter I2C_CLK_FREQUENCY = 250000,
    parameter DATA_WIDTH = 8)
  (
    input clkIn,
    input rstIn,
    input [DATA_WIDTH-1:0] dataIn,
    output reg [DATA_WIDTH-1:0] dataOut,
    output reg sclOut,
    inout reg sdaOut);

  parameter SCL_HIGH     = 2'b00;
  parameter SCL_HIGH_MID = 2'b01;
  parameter SCL_LOW      = 2'b10;
  parameter SCL_LOW_MID  = 2'b11;

  localparam SCL_CLK_PERIOD_COUNT = SYSTEM_CLK_FREQUENCY / I2C_CLK_FREQUENCY;
  localparam SCL_CLK_DIV_COUNT = SCL_CLK_PERIOD_COUNT / 4;

  reg [1:0] sclState;
  reg sclEn;

  integer sclDivCount;

  // parameter IDLE       = 4'b0000;
  // parameter START_COND = 4'b0001;
  // parameter SEND_ADDR  = 4'b0010;
  // parameter WAIT_ACK   = 4'b0011;
  // parameter TX_DATA    = 4'b0100;
  // parameter RX_DATA    = 4'b0101;
  // parameter TX_ACK     = 4'b0110;
  // parameter RX_ACK     = 4'b0111;
  // parameter STOP_COND  = 4'b1000;

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
      sclEn <= 1'b1;
    end
  end

endmodule