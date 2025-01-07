`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_cp0_reg (
    input wire                      clk,
    input wire                      rst,
    input wire                      we_i,
    input wire[`Reg_Addr_Bus]      waddr_i,
    input wire[`Reg_Addr_Bus]      raddr_i,
    input wire[`Reg_Bus]           data_i,
    input wire[5:0]                 int_i,
    output reg[`Reg_Bus]           data_o,
    output reg[`Reg_Bus]           count_o,
    output reg[`Reg_Bus]           compare_o,
    output reg[`Reg_Bus]           status_o,
    output reg[`Reg_Bus]           cause_o,
    output reg[`Reg_Bus]           epc_o,
    output reg[`Reg_Bus]           config_o,
    output reg[`Reg_Bus]           prid_o,
    output reg                     timer_int_o
);
    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            count_o <= `Word_Zero;
            compare_o <= `Word_Zero;
            status_o <= 32'h10000000;
            cause_o <= `Word_Zero;
            epc_o <= `Word_Zero;
            config_o <= 32'h00008000;
            prid_o <= 32'h008c0102;
            timer_int_o <=`InterruptNotAssert;
        end else begin
            count_o <= count_o + 1;
            cause_o[15:10] <= int_i;
            if (compare_o != `Word_Zero && count_o == compare_o) begin
                timer_int_o <= `InterruptAssert;
            end
            if (we_i == `Write_EN) begin
                case (waddr_i)
                    `CP0_REG_COUNT:begin
                        count_o <= data_i;
                    end
                    `CP0_REG_COMPARE:begin
                        compare_o <= data_i;
                        timer_int_o <= `InterruptNotAssert;
                    end
                    `CP0_REG_STATUS:begin
                        status_o <= data_i;
                    end
                    `CP0_REG_EPC:begin
                        epc_o <= data_i;
                    end
                    `CP0_REG_CAUSE:     begin
                        cause_o[9:8] <= data_i[9:8];
                        cause_o[23] <= data_i[23];
                        cause_o[22] <= data_i[22];
                    end
                endcase
            end
        end
    end
    
    always @ (*) begin
        case (raddr_i)
            `CP0_REG_COUNT:     begin
                data_o <= count_o;
            end
            `CP0_REG_COMPARE:   begin
                data_o <= compare_o;
            end
            `CP0_REG_STATUS:    begin
                data_o <= status_o;
            end
            `CP0_REG_CAUSE:     begin
                data_o <= cause_o;
            end
            `CP0_REG_EPC:       begin
                data_o <= epc_o;
            end
            `CP0_REG_PrId:      begin
                data_o <= prid_o;
            end
            `CP0_REG_CONFIG:    begin
                data_o <= config_o;
            end
            default:            begin
                data_o <= `Word_Zero;
            end
        endcase
    end
endmodule