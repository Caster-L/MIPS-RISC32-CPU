`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module button_debounce (
    input clk,
    input BTN_i,
    input rst,
    output reg BTN_o
    );

    reg [20:0] cnt; // A small counter to debounce
    reg BTN_sync_0, BTN_sync_1; // Synchronized signal
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            BTN_o <= 0;
            cnt <= 0;
            BTN_sync_0 <= 0;
            BTN_sync_1 <= 0;
        end else begin
            BTN_sync_0 <= BTN_i;
            BTN_sync_1 <= BTN_sync_0;
            if (BTN_sync_1 == BTN_o) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
                if (cnt >= `TIME_MIN) begin
                    cnt <= 0;
                    BTN_o <= BTN_sync_1;
                end
            end
        end
    end
endmodule