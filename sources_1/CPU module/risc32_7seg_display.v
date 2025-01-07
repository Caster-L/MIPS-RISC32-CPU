`timescale 1ns / 1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_7seg_display(
    input wire                          clk,
    input wire                          rst,
    input wire [15:0]                   value,

    output reg [7:0]                    SSEG_CA,
    output reg [3:0]                    SSEG_AN
);
    reg [7:0] seg_o [3:0]; // Rigisters to temporarily hold the segment outputs, '1' means this segment will be displayed
    reg [3:0] digit [3:0]; // Rigisters to temporarily hold the value of digit outputs, from '0' to '9'
    reg [1:0] digit_selected; // Rigister to decide which digit to display
    integer i;

    // Counter to reduce refreshing rate
    reg [`REFRESH_COUNTER_WIDTH - 1:0] refresh_counter; 
 

    // Refresh counter and digit selection to display one to four digits at the same time
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            digit_selected <= 0;
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            digit_selected <= refresh_counter[`REFRESH_COUNTER_WIDTH - 1:`REFRESH_COUNTER_WIDTH - 2];
        end
    end

    // Set segment for each digit
    always @(*) begin 
        digit[0] = value % 10;
        digit[1] = (value / 10) % 10;
        digit[2] = (value / 100) % 10;
        digit[3] = value / 1000;
            
        for (i = 3; i >= 0; i = i - 1) begin
            case(digit[i])
                4'd0: seg_o[i] = `SEG_0;
                4'd1: seg_o[i] = `SEG_1;
                4'd2: seg_o[i] = `SEG_2;
                4'd3: seg_o[i] = `SEG_3;
                4'd4: seg_o[i] = `SEG_4;
                4'd5: seg_o[i] = `SEG_5;
                4'd6: seg_o[i] = `SEG_6;
                4'd7: seg_o[i] = `SEG_7;
                4'd8: seg_o[i] = `SEG_8;
                4'd9: seg_o[i] = `SEG_9;
                default: seg_o[i] = `SEG_BLANK;
            endcase
        end
    end

    // Activate the segments to display every digit
    always @(*) begin
        case(digit_selected)
            2'b00: begin
                SSEG_AN = 4'b1110;
                SSEG_CA = ~seg_o[0];
            end
            2'b01: begin
                SSEG_AN = 4'b1101; 
                SSEG_CA = ~seg_o[1];
            end
            2'b10: begin
                SSEG_AN = 4'b1011; 
                SSEG_CA = ~seg_o[2];
            end
            2'b11: begin
                SSEG_AN = 4'b0111; 
                SSEG_CA = ~seg_o[3];
            end
            default: begin
                SSEG_AN = 4'b1111;
                SSEG_CA = ~`SEG_BLANK;
            end
        endcase
    end
endmodule