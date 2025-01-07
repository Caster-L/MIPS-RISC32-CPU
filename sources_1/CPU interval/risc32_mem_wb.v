`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_mem_wb (
    input wire                  clk,
    input wire                  rst,
    input wire[`Stall_Bus]      stall,

    input wire[`Reg_Addr_Bus]   wd_i,
    input wire                  wreg_i,
    input wire[`Reg_Bus]        wdata_i,
    input wire[`Reg_Bus]        hi_i,
    input wire[`Reg_Bus]        lo_i,
    input wire                  whilo_i,
    input wire                  cp0_reg_we_i,
    input wire[`Reg_Addr_Bus]   cp0_reg_write_addr_i,
    input wire[`Reg_Bus]        cp0_reg_data_i,
    
    output reg[`Reg_Addr_Bus]   wd_o,
    output reg                  wreg_o,
    output reg[`Reg_Bus]        wdata_o,
    output reg[`Reg_Bus]        hi_o,
    output reg[`Reg_Bus]        lo_o,
    output reg                  whilo_o,
    output reg                  cp0_reg_we_o,
    output reg[`Reg_Addr_Bus]   cp0_reg_write_addr_o,
    output reg[`Reg_Bus]        cp0_reg_data_o
);
    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            wd_o <= `Word_Zero;
            wdata_o <= `Word_Zero;
            wreg_o <= `Write_DIS;
            hi_o <= `Word_Zero;
            lo_o <= `Word_Zero;
            whilo_o <= `Write_DIS;
            cp0_reg_we_o <= `Write_DIS;
            cp0_reg_write_addr_o <= `NOP_Reg_Addr;
            cp0_reg_data_o <= `Word_Zero;
        end else if (stall[4] == `Stop && stall[5] == `NoStop) begin
            wd_o <= `Word_Zero;
            wdata_o <= `Word_Zero;
            wreg_o <= `Write_DIS;
            hi_o <= `Word_Zero;
            lo_o <= `Word_Zero;
            whilo_o <= `Write_DIS;
            cp0_reg_we_o <= `Write_DIS;
            cp0_reg_write_addr_o <= `NOP_Reg_Addr;
            cp0_reg_data_o <= `Word_Zero;
        end else if (stall[4] == `NoStop) begin
            wd_o <= wd_i;
            wdata_o <= wdata_i;
            wreg_o <= wreg_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
            cp0_reg_we_o <= cp0_reg_we_i;
            cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
            cp0_reg_data_o <= cp0_reg_data_i;
        end
    end
endmodule