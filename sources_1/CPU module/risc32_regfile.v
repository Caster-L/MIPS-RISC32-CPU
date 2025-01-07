`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_regfile(
    input wire                  clk,
    input wire                  rst,

    input wire                  we_i,
    input wire[`Reg_Addr_Bus]   waddr_i,
    input wire[`Reg_Bus]        wdata_i,

    input wire                  re1_i,
    input wire[`Reg_Addr_Bus]   raddr1_i,
    output reg[`Reg_Bus]        rdata1_o,

    input wire                  re2_i,
    input wire[`Reg_Addr_Bus]   raddr2_i,
    output reg[`Reg_Bus]        rdata2_o
);
    reg[`Reg_Bus] regs[0:`Reg_Num - 1];

    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            regs[0] <= `Word_Zero;  regs[1] <= `Word_Zero;  regs[2] <= `Word_Zero;  regs[3] <= `Word_Zero;  regs[4] <= `Word_Zero;  regs[5] <= `Word_Zero;  regs[6] <= `Word_Zero;  regs[7] <= `Word_Zero;
            regs[8] <= `Word_Zero;  regs[9] <= `Word_Zero;  regs[10] <= `Word_Zero; regs[11] <= `Word_Zero; regs[12] <= `Word_Zero; regs[13] <= `Word_Zero; regs[14] <= `Word_Zero; regs[15] <= `Word_Zero;
            regs[16] <= `Word_Zero; regs[17] <= `Word_Zero; regs[18] <= `Word_Zero; regs[19] <= `Word_Zero; regs[20] <= `Word_Zero; regs[21] <= `Word_Zero; regs[22] <= `Word_Zero; regs[23] <= `Word_Zero;
            regs[24] <= `Word_Zero; regs[25] <= `Word_Zero; regs[26] <= `Word_Zero; regs[27] <= `Word_Zero; regs[28] <= `Word_Zero; regs[29] <= `Word_Zero; regs[30] <= `Word_Zero; regs[31] <= `Word_Zero;
        end else begin
            if ((we_i == `Write_EN) && (waddr_i != `Reg_Num_Log2'h0)) begin
                regs[waddr_i] <= wdata_i;
            end
        end
    end

    always @ (*) begin
        if (raddr1_i == `Reg_Num_Log2'h0) begin
            rdata1_o = `Word_Zero;
        end else if ((raddr1_i == waddr_i) && (we_i == `Write_EN) && (re1_i == `Read_EN)) begin
            rdata1_o = wdata_i;
        end else if (re1_i == `Read_EN) begin
            rdata1_o = regs[raddr1_i];
        end else begin
            rdata1_o = `Word_Zero;
        end
    end

    always @ (*) begin
        if (raddr2_i == `Reg_Num_Log2'h0) begin
            rdata2_o = `Word_Zero;
        end else if ((raddr2_i == waddr_i) && (we_i == `Write_EN) && (re2_i == `Read_EN)) begin
            rdata2_o = wdata_i;
        end else if (re2_i == `Read_EN) begin
            rdata2_o = regs[raddr2_i];
        end else begin
            rdata2_o = `Word_Zero;
        end
    end
endmodule