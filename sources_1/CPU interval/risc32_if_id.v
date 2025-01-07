`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_if_id(
    input wire                  clk,
    input wire                  rst,
    input wire[`Stall_Bus]      stall,
    
    input wire[`Inst_Addr_Bus]  pc_i,
    input wire[`Inst_Bus]       inst_i,

    output reg[`Inst_Addr_Bus]  pc_o,
    output reg[`Inst_Bus]       inst_o             
    );

    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            pc_o <= `Word_Zero;
            inst_o <= `Word_Zero;
        end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
            pc_o <= `Word_Zero;
            inst_o <= `Word_Zero;
        end else if (stall[1] == `NoStop) begin
            pc_o <= pc_i;
            inst_o <= inst_i;
        end
    end

endmodule
