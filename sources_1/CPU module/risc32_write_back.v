`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_write_back(
    input wire[`Reg_Addr_Bus]       wd_i,
    input wire                      wreg_i,
    input wire[`Reg_Bus]            wdata_i,
    input wire[`Reg_Bus]            hi_i,
    input wire[`Reg_Bus]            lo_i,
    input wire                      whilo_i,

    output reg[`Reg_Addr_Bus]       wb_wd,
    output reg                      wb_wreg,
    output reg[`Reg_Bus]            wb_wdata,
    output reg[`Reg_Bus]            wb_hi_o,
    output reg[`Reg_Bus]            wb_lo_o,
    output reg                      wb_whilo_o
);

    always @ (*) begin
        wb_wd = wd_i;
        wb_wreg = wreg_i;
        wb_wdata = wdata_i;
        wb_hi_o = hi_i;
        wb_lo_o = lo_i;
        wb_whilo_o = whilo_i;
    end
endmodule