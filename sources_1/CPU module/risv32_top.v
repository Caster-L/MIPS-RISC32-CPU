`timescale 1ns / 1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_top(
    input wire          clk,
    input wire[15:0]    sw,
    input wire[4:0]     btn,
    output wire[15:0]   led,
    output wire[3:0]    SSEG_AN,
    output wire[7:0]    SSEG_CA
    );

    wire rst;

    wire[`Inst_Addr_Bus] inst_addr;
    wire[`Inst_Bus] inst;
    wire rom_ce;
    wire mem_we_i, io_we_i;
    wire[`Reg_Bus] mem_addr_i, io_addr_i;
    wire[`Reg_Bus] mem_data_i, io_data_i;
    wire[`Reg_Bus] mem_data_o, io_data_o;
    wire[3:0] mem_sel_i;
    wire mem_ce_i, io_ce_i;
    wire[15:0] seg;
    wire[4:0] BTN;

    wire[5:0] int_i;
    wire timer_int_o;

    assign int_i = 6'b0;
    assign rst = sw[15];

    // Debounce the button
    button_debounce btn0 (
        .clk(clk),
        .rst(rst),
        .BTN_i(btn[0]),
        .BTN_o(BTN[0])  
    );
    button_debounce btn1 (
        .clk(clk),
        .rst(rst),
        .BTN_i(btn[1]),
        .BTN_o(BTN[1])  
    );
    button_debounce btn2 (
        .clk(clk),
        .rst(rst),
        .BTN_i(btn[2]),
        .BTN_o(BTN[2])  
    );
    button_debounce btn3 (
        .clk(clk),
        .rst(rst),
        .BTN_i(btn[3]),
        .BTN_o(BTN[3])  
    );
    button_debounce btn4 (
        .clk(clk),
        .rst(rst),
        .BTN_i(btn[4]),
        .BTN_o(BTN[4])  
    );

    risc32_cpu CPU (
        .clk(clk),
        .rst(rst),

        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        .ram_data_i(mem_data_o),
        .ram_data_o(mem_data_i),
        .ram_ce_o(mem_ce_i),
        .ram_we_o(mem_we_i),
        .ram_addr_o(mem_addr_i),
        .ram_sel_o(mem_sel_i),
        
        .io_data_i(io_data_o),
        .io_data_o(io_data_i),
        .io_ce_o(io_ce_i),
        .io_we_o(io_we_i),
        .io_addr_o(io_addr_i),
        .int_i(int_i),
        .timer_int_o(timer_int_o)
    );

    // Read Only Memory
    risc32_inst_rom inst_rom (
        .ce_i(rom_ce),
        .addr_i(inst_addr),
        .inst_o(inst)
    );

    // Random Access Memory
    risc32_data_ram data_ram (
        .clk(clk),
        .rst(rst),
        .ce_i(mem_ce_i),
        .we_i(mem_we_i),
        .addr_i(mem_addr_i),
        .sel_i(mem_sel_i),
        .data_i(mem_data_i),
        .data_o(mem_data_o)
    );

    // The input and output from FPGA
    risc32_io io (
        .clk(clk),
        .rst(rst),
        .we_i(io_we_i),
        .addr_i(io_addr_i),
        .data_i(io_data_i),
        .data_o(io_data_o),
        .ce_i(io_ce_i),
        .sw(sw),
        .led(led),
        .seg(seg),
        .btn(BTN)
    );

    risc32_7seg_display seg_display (
        .clk(clk),
        .rst(rst),
        .value(seg),
        .SSEG_CA(SSEG_CA),
        .SSEG_AN(SSEG_AN)
    );

endmodule
