`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_io (
    input wire                      clk,
    input wire                      rst,
    input wire                      ce_i,
    input wire                      we_i,
    input wire[`Data_Addr_Bus]      addr_i,
    input wire[`Data_Bus]           data_i,
    input wire[15:0]                sw,
    input wire[4:0]                 btn,

    output reg[15:0]                seg,
    output reg[`Data_Bus]           data_o,
    output reg[15:0]                led
);

    reg ce_i_sync, we_i_sync;
    reg [`Data_Addr_Bus] addr_i_sync;
    reg [`Data_Bus] data_i_sync;

    always @(posedge clk or posedge rst) begin
        if (rst == `Rst_EN) begin
            ce_i_sync <= `Chip_DIS;
            we_i_sync <= `Write_DIS;
            addr_i_sync <= `Word_Zero;
            data_i_sync <= `Word_Zero;
        end else begin
            ce_i_sync <= ce_i;
            we_i_sync <= we_i;
            addr_i_sync <= addr_i;
            data_i_sync <= data_i;
        end
    end

    // Output
    always @(posedge clk or posedge rst) begin
        if (rst == `Rst_EN) begin
            led <= 16'h0000;
            seg <= 16'h0000;
        end else begin
            led <= led;
            seg <= seg;
            if (ce_i_sync == `Chip_EN && we_i_sync == `Write_EN) begin
                if (addr_i_sync == `LED) begin
                    led <= data_i_sync[15:0];
                end else if (addr_i_sync == `SEG) begin
                    seg <= data_i_sync[15:0];
                end
            end
        end
    end

    // Input
    always @(*) begin
        if (rst == `Rst_EN) begin
            data_o = `Word_Zero;
        end else begin
            if (ce_i == `Chip_EN) begin
                if (we_i == `Write_DIS) begin
                    if (addr_i == `SWITCH) begin
                        data_o = {16'b0, sw};
                    end else if (addr_i == `BTN) begin
                        data_o = {27'b0, btn};
                    end else begin
                        data_o = `Word_Zero;
                    end
                end else begin
                    data_o = `Word_Zero;
                end
            end else begin
                data_o = `Word_Zero;
            end
        end
    end
endmodule