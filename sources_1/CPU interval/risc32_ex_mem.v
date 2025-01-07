`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_ex_mem (
    input wire                  clk,
    input wire                  rst,
    input wire[`Stall_Bus]      stall,
    input wire[`Reg_Addr_Bus]   wd_i,
    input wire                  wreg_i,
    input wire[`Reg_Bus]        wdata_i,
    input wire[`Reg_Bus]        hi_i,
    input wire[`Reg_Bus]        lo_i,
    input wire                  whilo_i,
    input wire[`Alu_Op_Bus]     alu_op_i,
    input wire[`Reg_Bus]        mem_addr_i,
    input wire                  cp0_reg_we_i,
    input wire[`Reg_Addr_Bus]   cp0_reg_write_addr_i,
    input wire[`Reg_Bus]        cp0_reg_data_i,
    input wire[`Reg_Bus]        reg2_i,

    output reg[`Reg_Addr_Bus]   wd_o,
    output reg                  wreg_o,
    output reg[`Reg_Bus]        wdata_o,
    output reg[`Reg_Bus]        hi_o,
    output reg[`Reg_Bus]        lo_o,
    output reg                  whilo_o,
    output reg[`Alu_Op_Bus]     alu_op_o,
    output reg[`Reg_Bus]        mem_addr_o,
    output reg                  cp0_reg_we_o,
    output reg[`Reg_Addr_Bus]   cp0_reg_write_addr_o,
    output reg[`Reg_Bus]        cp0_reg_data_o,
    output reg[`Reg_Bus]        reg2_o
);
    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            wd_o <= `NOP_Reg_Addr;
            wreg_o <= `Write_DIS;
            wdata_o <= `Word_Zero;
            hi_o <= `Word_Zero;
            lo_o <= `Word_Zero;
            whilo_o <= `Write_DIS;
            alu_op_o <= `EXE_NOP_OP;
            mem_addr_o <= `Word_Zero;
            cp0_reg_we_o <= `Write_DIS;
            cp0_reg_write_addr_o <= `NOP_Reg_Addr;
            cp0_reg_data_o <= `Word_Zero;
            reg2_o <= `Word_Zero;
        end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            wd_o <= `NOP_Reg_Addr;
            wreg_o <= `Write_DIS;
            wdata_o <= `Word_Zero;
            hi_o <= `Word_Zero;
            lo_o <= `Word_Zero;
            whilo_o <= `Write_DIS;
            alu_op_o <= `EXE_NOP_OP;
            mem_addr_o <= `Word_Zero;
            cp0_reg_we_o <= `Write_DIS;
            cp0_reg_write_addr_o <= `NOP_Reg_Addr;
            cp0_reg_data_o <= `Word_Zero;
            reg2_o <= `Word_Zero;
        end else if (stall[3] == `NoStop) begin
            wd_o <= wd_i;
            wreg_o <= wreg_i;
            wdata_o <= wdata_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
            alu_op_o <= alu_op_i;
            mem_addr_o <= mem_addr_i;
            cp0_reg_we_o <= cp0_reg_we_i;
            cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
            cp0_reg_data_o <= cp0_reg_data_i;
            reg2_o <= reg2_i;
        end
    end

endmodule