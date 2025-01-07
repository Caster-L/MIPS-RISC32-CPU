`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_hilo_reg (
    input wire                      clk,
    input wire                      rst,
    
    input wire                      we_i,
    input wire[`Reg_Bus]            hi_i,
    input wire[`Reg_Bus]            lo_i,

    output reg[`Reg_Bus]            hi_o,
    output reg[`Reg_Bus]            lo_o
);

    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            hi_o <= `Word_Zero;
            lo_o <= `Word_Zero;
        end else if (we_i == `Write_EN) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end else begin
            hi_o <= hi_o;
            lo_o <= lo_o;
        end
    end

endmodule