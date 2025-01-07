`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_memory (
    input wire[`Reg_Addr_Bus]   wd_i,
    input wire                  wreg_i,
    input wire[`Reg_Bus]        wdata_i,
    input wire[`Reg_Bus]        hi_i,
    input wire[`Reg_Bus]        lo_i,
    input wire                  whilo_i,
    input wire[`Alu_Op_Bus]     alu_op_i,
    input wire[`Reg_Bus]        mem_addr_i,
    input wire[`Reg_Bus]        reg2_i,
    input wire[`Reg_Bus]        mem_data_i,
    input wire[`Reg_Bus]        io_data_i,

    input wire                  cp0_reg_we_i,
    input wire[`Reg_Addr_Bus]   cp0_reg_write_addr_i,
    input wire[`Reg_Bus]        cp0_reg_data_i,

    output reg[`Reg_Addr_Bus]   wd_o,
    output reg                  wreg_o,
    output reg[`Reg_Bus]        wdata_o,
    output reg[`Reg_Bus]        hi_o,
    output reg[`Reg_Bus]        lo_o,
    output reg                  whilo_o,
    output reg[`Reg_Bus]        mem_addr_o,
    output reg                  mem_we_o,
    output reg[3:0]             mem_sel_o, // 4 Byte, select which one is valid
    output reg[`Reg_Bus]        mem_data_o,
    output reg                  mem_ce_o,

    output reg                  cp0_reg_we_o,
    output reg[`Reg_Addr_Bus]   cp0_reg_write_addr_o,
    output reg[`Reg_Bus]        cp0_reg_data_o,

    output reg[`Reg_Bus]        io_addr_o,
    output reg                  io_we_o,
    output reg[`Reg_Bus]        io_data_o,
    output reg                  io_ce_o
);

    always @ (*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        wdata_o = wdata_i;
        lo_o = lo_i;
        hi_o = hi_i;
        whilo_o = whilo_i;
        cp0_reg_we_o = cp0_reg_we_i;
        cp0_reg_write_addr_o = cp0_reg_write_addr_i;
        cp0_reg_data_o = cp0_reg_data_i;

        case(alu_op_i)
            `EXE_LB_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `Write_DIS;
                mem_ce_o = `Chip_EN;
                case(mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o = {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                        mem_sel_o = 4'b1000;
                    end
                    2'b01: begin
                        wdata_o = {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                        mem_sel_o = 4'b0100;
                    end
                    2'b10: begin
                        wdata_o = {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                        mem_sel_o = 4'b0010;
                    end
                    2'b11: begin
                        wdata_o = {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                        mem_sel_o = 4'b0001;
                    end
                    default: begin
                        wdata_o = `Word_Zero;
                        mem_sel_o = 4'b1111;
                    end
                endcase
            end
            `EXE_LBU_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `Write_DIS;
                mem_ce_o = `Chip_EN;
                case(mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o = {{24{1'b0}}, mem_data_i[31:24]};
                        mem_sel_o = 4'b1000;
                    end
                    2'b01: begin
                        wdata_o = {{24{1'b0}}, mem_data_i[23:16]};
                        mem_sel_o = 4'b0100;
                    end
                    2'b10: begin
                        wdata_o = {{24{1'b0}}, mem_data_i[15:8]};
                        mem_sel_o = 4'b0010;
                    end
                    2'b11: begin
                        wdata_o = {{24{1'b0}}, mem_data_i[7:0]};
                        mem_sel_o = 4'b0001;
                    end
                    default: begin
                        wdata_o = `Word_Zero;
                        mem_sel_o = 4'b1111;
                    end
                endcase
            end
            `EXE_LH_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `Write_DIS;
                mem_ce_o = `Chip_EN;
                case(mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o = {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                        mem_sel_o = 4'b1100;
                    end
                    2'b10: begin
                        wdata_o = {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                        mem_sel_o = 4'b0011;
                    end
                    default: begin
                        wdata_o = `Word_Zero;
                        mem_sel_o = 4'b1111;
                    end
                endcase
            end
            `EXE_LHU_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `Write_DIS;
                mem_ce_o = `Chip_EN;
                case(mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o = {{16{1'b0}}, mem_data_i[31:16]};
                        mem_sel_o = 4'b1100;
                    end
                    2'b10: begin
                        wdata_o = {{16{1'b0}}, mem_data_i[15:0]};
                        mem_sel_o = 4'b0011;
                    end
                    default: begin
                        wdata_o = `Word_Zero;
                        mem_sel_o = 4'b1111;
                    end
                endcase
            end
            `EXE_LW_OP: begin
                if (mem_addr_i < 32'h0000_f000) begin
                    mem_addr_o = mem_addr_i;
                    mem_we_o = `Write_DIS;
                    mem_ce_o = `Chip_EN;
                    mem_sel_o = 4'b1111;
                    wdata_o = mem_data_i;
                end else begin
                    io_addr_o = mem_addr_i;
                    io_we_o = `Write_DIS;
                    wdata_o = io_data_i;
                    io_ce_o = `Chip_EN;
                end
            end
            `EXE_SB_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `Write_EN;
                mem_ce_o = `Chip_EN;
                mem_data_o = {reg2_i[7:0], reg2_i[7:0], reg2_i[7:0], reg2_i[7:0]};
                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1000;
                    end
                    2'b01: begin
                        mem_sel_o = 4'b0100;
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0010;
                    end
                    2'b11: begin
                        mem_sel_o = 4'b0001;
                    end
                    default: begin
                        mem_sel_o = 4'b0000;
                    end
                endcase
            end
            `EXE_SH_OP: begin
                mem_addr_o = mem_addr_i;
                mem_we_o = `Write_EN;
                mem_ce_o = `Chip_EN;
                mem_data_o = {reg2_i[15:0], reg2_i[15:0]};
                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o = 4'b1100;
                    end
                    2'b10: begin
                        mem_sel_o = 4'b0011;
                    end
                    default: begin
                        mem_sel_o = 4'b0000;
                    end
                endcase
            end
            `EXE_SW_OP: begin
                if (mem_addr_i < 32'h0000_f000) begin
                    mem_addr_o = mem_addr_i;
                    mem_we_o = `Write_EN;
                    mem_data_o = reg2_i;
                    mem_sel_o = 4'b1111;
                    mem_ce_o = `Chip_EN;
                end else begin
                    io_ce_o = `Chip_EN;
                    io_addr_o = mem_addr_i;
                    io_we_o = `Write_EN;
                    io_data_o = reg2_i;
                end
            end
            default: begin
                mem_we_o = `Write_DIS;
                mem_addr_o = `Word_Zero;
                mem_sel_o = 4'b1111;
                mem_ce_o = `Chip_DIS;

                io_ce_o = `Chip_EN;
                io_addr_o = mem_addr_i;
                io_we_o = `Write_DIS;
                io_data_o = reg2_i;
            end
        endcase
    end

endmodule