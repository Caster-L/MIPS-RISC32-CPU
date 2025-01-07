`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_data_ram(
    input wire                      clk,
    input wire                      rst,
    input wire                      ce_i,
    input wire                      we_i,
    input wire[`Data_Addr_Bus]      addr_i,
    input wire[3:0]                 sel_i,
    input wire[`Data_Bus]           data_i,

    output reg[`Data_Bus]           data_o
);
    reg[`Byte_Width] data_mem0[0:127];
    reg[`Byte_Width] data_mem1[0:127];
    reg[`Byte_Width] data_mem2[0:127];
    reg[`Byte_Width] data_mem3[0:127];

    // Combine data_mem0, data_mem1, data_mem2, data_mem3 to benefit the Simulation
    wire [31:0] data_mem_combined [0:127];
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: loop_wire
            assign data_mem_combined[i] = {data_mem3[i], data_mem2[i], data_mem1[i], data_mem0[i]};
        end
    endgenerate

    // Instantiate ILA IP core and connect each data_mem_combined element to a probe
    // ila_0 ila_inst (
    //     .clk(clk), // Clock input for the ILA
    //     .probe0(data_mem_combined[0]),
    //     .probe1(data_mem_combined[1]),
    //     .probe2(data_mem_combined[2]),
    //     .probe3(data_mem_combined[3]),
    //     .probe4(data_mem_combined[4]),
    //     .probe5(data_mem_combined[5]),
    //     .probe6(data_mem_combined[6]),
    //     .probe7(data_mem_combined[7]),
    //     .probe8(data_mem_combined[8]),
    //     .probe9(data_mem_combined[9]),
    //     .probe10(data_mem_combined[10]),
    //     .probe11(data_mem_combined[11]),
    //     .probe12(data_mem_combined[12]),
    //     .probe13(data_mem_combined[13]),
    //     .probe14(data_mem_combined[14]),
    //     .probe15(data_mem_combined[15]),
    //     .probe16(data_mem_combined[16]),
    //     .probe17(data_mem_combined[17]),
    //     .probe18(data_mem_combined[18]),
    //     .probe19(data_mem_combined[19]),
    //     .probe20(data_mem_combined[20]),
    //     .probe21(data_mem_combined[21]),
    //     .probe22(data_mem_combined[22]),
    //     .probe23(data_mem_combined[23]),
    //     .probe24(data_mem_combined[24]),
    //     .probe25(data_mem_combined[25]),
    //     .probe26(data_mem_combined[26]),
    //     .probe27(data_mem_combined[27]),
    //     .probe28(data_mem_combined[28]),
    //     .probe29(data_mem_combined[29]),
    //     .probe30(data_mem_combined[30]),
    //     .probe31(data_mem_combined[31])
    // );

    // Write operation
    integer j;
    always @ (posedge clk, posedge rst) begin
        if (rst == `Rst_EN) begin
            for (j = 0; j <= 127; j = j + 1) begin
                data_mem0[j] <= 8'h0;
                data_mem1[j] <= 8'h0;
                data_mem2[j] <= 8'h0;
                data_mem3[j] <= 8'h0;
            end
        end else begin
            if (ce_i == `Chip_DIS) begin
                // Chip disabled, no operation
            end else if (we_i == `Write_EN) begin
                if (sel_i[3] == 1'b1) begin
                    data_mem3[addr_i[`Data_Mem_Num_Log2 + 1 : 2]] <= data_i[31:24];
                end
                if (sel_i[2] == 1'b1) begin
                    data_mem2[addr_i[`Data_Mem_Num_Log2 + 1 : 2]] <= data_i[23:16];
                end
                if (sel_i[1] == 1'b1) begin
                    data_mem1[addr_i[`Data_Mem_Num_Log2 + 1 : 2]] <= data_i[15:8];
                end
                if (sel_i[0] == 1'b1) begin
                    data_mem0[addr_i[`Data_Mem_Num_Log2 + 1 : 2]] <= data_i[7:0];
                end
            end
        end
    end

    // Read operation
    always @ (*) begin
        if (ce_i == `Chip_DIS) begin
            data_o = `Word_Zero;
        end else if (we_i == `Write_DIS) begin
            data_o = {data_mem3[addr_i[`Data_Mem_Num_Log2 + 1 : 2]],
                       data_mem2[addr_i[`Data_Mem_Num_Log2 + 1 : 2]],
                       data_mem1[addr_i[`Data_Mem_Num_Log2 + 1 : 2]],
                       data_mem0[addr_i[`Data_Mem_Num_Log2 + 1 : 2]]};
        end else begin
            data_o = `Word_Zero;
        end
    end
endmodule