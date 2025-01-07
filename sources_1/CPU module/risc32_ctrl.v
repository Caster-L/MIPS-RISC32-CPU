`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_ctrl (
    input wire                      rst,
    input wire                      stallreg_from_ex,
    input wire                      stallreg_from_id,

    output reg[`Stall_Bus]          stall // stall[0]: PC, stall[1]: ir, stall[2]: id, stall[3]: ex, stall[4]: mem, stall[5]: wb
);

    always @ (*) begin
        if (rst == `Rst_EN) begin
            stall = 6'b000000;
        end else if (stallreg_from_ex == `Stop) begin
            stall = 6'b001111; // Stop PC, ir, id, ex, but continue mem and wb
        end else if (stallreg_from_id == `Stop) begin
            stall = 6'b000111; // Stop PC, ir, id, but continue ex, mem and wb
        end else begin
            stall = 6'b000000;
        end
    end

endmodule