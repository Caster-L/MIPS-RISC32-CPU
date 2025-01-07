`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_id_ex(
    input wire                      clk,
    input wire                      rst,
    input wire[`Stall_Bus]          stall,
    
    input wire[`Alu_Op_Bus]         alu_op_i,
    input wire[`Alu_Sel_Bus]        alu_sel_i,
    input wire[`Reg_Bus]            reg1_i,
    input wire[`Reg_Bus]            reg2_i,
    input wire[`Reg_Addr_Bus]       wd_i, 
    input wire                      wreg_i,
    input wire[`Reg_Bus]            id_link_address,
    input wire                      id_is_in_delayslot,
    input wire                      next_inst_in_delayslot_i,
    input wire[`Reg_Bus]            inst_i,

    output reg[`Alu_Op_Bus]         alu_op_o,
    output reg[`Alu_Sel_Bus]        alu_sel_o,
    output reg[`Reg_Bus]            reg1_o,
    output reg[`Reg_Bus]            reg2_o,
    output reg[`Reg_Addr_Bus]       wd_o, 
    output reg                      wreg_o,
    output reg[`Reg_Bus]            ex_link_address,
    output reg                      is_in_delayslot_o,
    output reg                      ex_is_in_delayslot,
    output reg[`Reg_Bus]            inst_o
    );

    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            alu_op_o <= `EXE_NOP_OP;
            alu_sel_o <= `EXE_RES_NOP;
            wd_o <= `NOP_Reg_Addr;
            wreg_o <= `Write_DIS;
            reg1_o <= `Word_Zero;
            reg2_o <= `Word_Zero;
            ex_link_address <= `Word_Zero;
            ex_is_in_delayslot <= `NotInDelaySlot;
            is_in_delayslot_o <= `NotInDelaySlot;
            inst_o <= `Word_Zero;
        end else if (stall[2] == `Stop && stall [3] == `NoStop) begin
            alu_op_o <= `EXE_NOP_OP;
            alu_sel_o <= `EXE_RES_NOP;
            wd_o <= `NOP_Reg_Addr;
            wreg_o <= `Write_DIS;
            reg1_o <= `Word_Zero;
            reg2_o <= `Word_Zero;
            ex_link_address <= `Word_Zero;
            ex_is_in_delayslot <= `NotInDelaySlot;
            inst_o <= `Word_Zero;
            is_in_delayslot_o <= next_inst_in_delayslot_i;
        end else if (stall[2] == `NoStop) begin
            alu_op_o <= alu_op_i;
            alu_sel_o <= alu_sel_i;
            wd_o <= wd_i;
            wreg_o <= wreg_i;
            reg1_o <= reg1_i;
            reg2_o <= reg2_i;
            ex_link_address <= id_link_address;
            ex_is_in_delayslot <= id_is_in_delayslot;
            is_in_delayslot_o <= next_inst_in_delayslot_i;
            inst_o <= inst_i;
        end
    end
endmodule
