`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_program_counter (
    input wire                  clk,
    input wire                  rst,
    input wire[`Stall_Bus]      stall,

    input wire                  branch_flag_i,
    input wire[`Reg_Bus]        branch_target_address_i,

    output reg[`Inst_Addr_Bus]  pc_o,   // Program Counter
    output reg                  ce_o    // Chip Enable Signal
);

    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            ce_o <= `Chip_DIS;
        end else begin
            ce_o <= `Chip_EN;
        end
    end

    always @ (posedge clk) begin
        if (ce_o == `Chip_DIS) begin
            pc_o <= `Word_Zero;
        end else if (stall[0] == `NoStop) begin
            if (branch_flag_i == `Branch) begin
                pc_o <= branch_target_address_i;
            end else begin
                pc_o <= pc_o + 4'h4; // An instruction occupies 32bit (4 * 8bit)
            end
        end else begin
            pc_o <= pc_o;
        end
    end
    
endmodule