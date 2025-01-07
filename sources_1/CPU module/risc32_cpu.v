`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_cpu(
    input wire                  clk,
    input wire                  rst,
    input wire[`Reg_Bus]        rom_data_i,
    output wire[`Reg_Bus]       rom_addr_o,

    input wire[`Reg_Bus]        ram_data_i,
    input wire[`Reg_Bus]        io_data_i,

    input wire[5:0]             int_i,

    output wire[`Reg_Bus]       ram_addr_o,
    output wire[`Reg_Bus]       ram_data_o,
    output wire[3:0]            ram_sel_o,
    output wire                 ram_we_o,

    output wire[`Reg_Bus]       io_addr_o,
    output wire[`Reg_Bus]       io_data_o,
    output wire                 io_we_o,
    output wire                 io_ce_o,

    output wire                 ram_ce_o,
    output wire                 rom_ce_o,
    output wire                 timer_int_o
);
    // Connect IF and ID
    wire[`Inst_Addr_Bus]        pc;
    wire[`Inst_Addr_Bus]        id_pc_i;
    wire[`Inst_Bus]             id_inst_i;
    // Connect ID and EX
    wire[`Alu_Op_Bus]           id_alu_op_o;
    wire[`Alu_Sel_Bus]          id_alu_sel_o;
    wire[`Reg_Bus]              id_reg1_o;
    wire[`Reg_Bus]              id_reg2_o;
    wire                        id_wreg_o;
    wire[`Reg_Addr_Bus]         id_wd_o;
    wire                        id_is_in_delayslot_o;
    wire[`Reg_Bus]              id_link_address_o;
    wire                        id_next_inst_in_delayslot_o;
    wire[`Reg_Bus]              id_inst_o;

    wire[`Alu_Op_Bus]           ex_alu_op_i;
    wire[`Alu_Sel_Bus]          ex_alu_sel_i;
    wire[`Reg_Bus]              ex_reg1_i;
    wire[`Reg_Bus]              ex_reg2_i;
    wire                        ex_wreg_i;
    wire[`Reg_Addr_Bus]         ex_wd_i;
    wire[`Reg_Bus]              ex_lo_i;
    wire[`Reg_Bus]              ex_hi_i;
    wire                        ex_whilo_i;
    wire                        ex_is_in_delayslot_i;
    wire[`Reg_Bus]              ex_link_address_i;
    wire                        ex_next_inst_in_delayslot_i;
    wire[`Reg_Bus]              ex_inst_i;

    // Connect ID and Regfile
    wire                        reg1_read;
    wire                        reg2_read;
    wire[`Reg_Bus]              reg1_data;
    wire[`Reg_Bus]              reg2_data;
    wire[`Reg_Addr_Bus]         reg1_addr;
    wire[`Reg_Addr_Bus]         reg2_addr;

    // Connect EX and MEM
    wire                        ex_wreg_o;
    wire[`Reg_Bus]              ex_wdata_o;
    wire[`Reg_Addr_Bus]         ex_wd_o;
    wire[`Reg_Bus]              ex_lo_o;
    wire[`Reg_Bus]              ex_hi_o;
    wire                        ex_whilo_o;
    wire[`Alu_Op_Bus]           ex_alu_op_o;
    wire[`Reg_Bus]              ex_mem_addr_o;
    wire[`Reg_Bus]              ex_reg2_o;

    wire[`Reg_Bus]              ex_cp0_reg_data_o;
    wire[`Reg_Addr_Bus]         ex_cp0_reg_write_addr_o;
    wire                        ex_cp0_reg_we_o;

    wire                        mem_wreg_i;
    wire[`Reg_Bus]              mem_wdata_i;
    wire[`Reg_Addr_Bus]         mem_wd_i;
    wire                        mem_whilo_i;
    wire[`Reg_Bus]              mem_lo_i;
    wire[`Reg_Bus]              mem_hi_i;
    wire[`Alu_Op_Bus]           mem_alu_op_i;
    wire[`Reg_Bus]              mem_mem_addr_i;
    wire[`Reg_Bus]              mem_reg2_i;
    wire[`Reg_Bus]              mem_cp0_reg_data_i;
    wire[`Reg_Addr_Bus]         mem_cp0_reg_write_addr_i;
    wire                        mem_cp0_reg_we_i;
    
    // Connect MEM and WB
    wire                        mem_wreg_o;
    wire[`Reg_Bus]              mem_wdata_o;
    wire[`Reg_Addr_Bus]         mem_wd_o;
    wire                        mem_whilo_o;
    wire[`Reg_Bus]              mem_lo_o;
    wire[`Reg_Bus]              mem_hi_o;

    // Connect EX and CP0
    wire[`Reg_Addr_Bus]         ex_cp0_reg_read_addr_o;
    wire[`Reg_Bus]              cp0_cp0_reg_data_o;
    wire[`Reg_Addr_Bus]         cp0_cp0_reg_read_addr_i;
    wire[`Reg_Bus]              ex_cp0_reg_data_i;

    // Connect MEM and CP0
    wire[`Reg_Bus]              mem_cp0_reg_data_o;
    wire[`Reg_Addr_Bus]         mem_cp0_reg_write_addr_o;
    wire                        mem_cp0_reg_we_o;
    wire[`Reg_Bus]              cp0_cp0_reg_data_i;
    wire[`Reg_Addr_Bus]         cp0_cp0_reg_write_addr_i;
    wire                        cp0_cp0_reg_we_i;

    // Conncet WB and Regfile
    wire[`Reg_Addr_Bus]         wb_wd_i;
    wire                        wb_wreg_i;
    wire[`Reg_Bus]              wb_wdata_i;
    wire                        wb_whilo_i;
    wire[`Reg_Bus]              wb_lo_i;
    wire[`Reg_Bus]              wb_hi_i;

    wire[`Reg_Addr_Bus]         wb_wd;
    wire                        wb_wreg;
    wire[`Reg_Bus]              wb_wdata;
    wire                        wb_whilo;
    wire[`Reg_Bus]              wb_lo;
    wire[`Reg_Bus]              wb_hi;

    // Ctrl Module
    wire[`Stall_Bus]            stall;
    wire                        stallreg_from_id, stallreg_from_ex;


    // Other
    wire                        is_in_delayslot;
    wire                        branch_flag;
    wire[`Reg_Bus]              branch_target_address;

    risc32_program_counter pc_reg (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .pc_o(pc),
        .ce_o(rom_ce_o),
        .branch_flag_i(branch_flag),
        .branch_target_address_i(branch_target_address)
    );

    assign rom_addr_o = pc;

    risc32_ctrl ctrl (
        .rst(rst),
        .stallreg_from_ex(stallreg_from_ex),
        .stallreg_from_id(stallreg_from_id),
        .stall(stall)
    );

    risc32_if_id if_id (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .pc_i(pc),
        .inst_i(rom_data_i),
        .pc_o(id_pc_i),
        .inst_o(id_inst_i)
    );

    risc32_inst_decode id (
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
        .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
        .ex_wreg_i(ex_wreg_o),
        .ex_wd_i(ex_wd_o),
        .ex_wdata_i(ex_wdata_o),
        .mem_wreg_i(mem_wreg_o),
        .mem_wd_i(mem_wd_o),
        .mem_wdata_i(mem_wdata_o),
        .alu_op_o(id_alu_op_o),
        .alu_sel_o(id_alu_sel_o),
        .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o),
        .stallreg(stallreg_from_id),
        .is_in_delayslot_i(is_in_delayslot),
        .branch_flag_o(branch_flag),
        .branch_target_address_o(branch_target_address),
        .next_inst_in_delayslot_o(id_next_inst_in_delayslot_o),
        .link_addr_o(id_link_address_o),
        .is_in_delayslot_o(id_is_in_delayslot_o),
        .inst_o(id_inst_o),
        .ex_alu_op_i(ex_alu_op_o)
    );

    risc32_regfile regfile(
        .clk(clk),
        .rst(rst),
        .we_i(wb_wreg),
        .waddr_i(wb_wd),
        .wdata_i(wb_wdata),
        .re1_i(reg1_read), .re2_i(reg2_read),
        .raddr1_i(reg1_addr), .raddr2_i(reg2_addr),
        .rdata1_o(reg1_data), .rdata2_o(reg2_data)
    );

    risc32_hilo_reg hilo_reg (
        .clk(clk),
        .rst(rst),
        .we_i(wb_whilo),
        .lo_i(wb_lo),
        .hi_i(wb_hi),
        .lo_o(ex_lo_i),
        .hi_o(ex_hi_i)
    );

    risc32_id_ex id_ex (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .alu_op_i(id_alu_op_o),
        .alu_sel_i(id_alu_sel_o),
        .reg1_i(id_reg1_o),
        .reg2_i(id_reg2_o),
        .wd_i(id_wd_o),
        .wreg_i(id_wreg_o),
        .alu_op_o(ex_alu_op_i),
        .alu_sel_o(ex_alu_sel_i),
        .reg1_o(ex_reg1_i),
        .reg2_o(ex_reg2_i),
        .wd_o(ex_wd_i),
        .wreg_o(ex_wreg_i),
        .id_link_address(id_link_address_o),
        .id_is_in_delayslot(id_is_in_delayslot_o),
        .next_inst_in_delayslot_i(id_next_inst_in_delayslot_o),
        .ex_link_address(ex_link_address_i),
        .is_in_delayslot_o(is_in_delayslot),
        .ex_is_in_delayslot(ex_is_in_delayslot_i),
        .inst_i(id_inst_o),
        .inst_o(ex_inst_i)
    );

    risc32_execute ex (
        .alu_op_i(ex_alu_op_i),
        .alu_sel_i(ex_alu_sel_i),
        .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),
        .lo_i(ex_lo_i),
        .hi_i(ex_hi_i),
        .mem_whilo_i(mem_whilo_o),
        .mem_lo_i(mem_lo_o),
        .mem_hi_i(mem_hi_o),
        .wb_whilo_i(wb_whilo),
        .wb_hi_i(wb_hi),
        .wb_lo_i(wb_lo),
        .cp0_reg_data_i(ex_cp0_reg_data_i),
        .wb_cp0_reg_data(cp0_cp0_reg_data_i),
        .wb_cp0_reg_write_addr(cp0_cp0_reg_write_addr_i),
        .wb_cp0_reg_we(cp0_cp0_reg_we_i),
        .mem_cp0_reg_data(mem_cp0_reg_data_o),
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
        .mem_cp0_reg_we(mem_cp0_reg_we_o),
        .whilo_o(ex_whilo_o),
        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .stallreg(stallreg_from_ex),
        .link_address_i(ex_link_address_i),
        .is_in_delayslot_i(ex_is_in_delayslot_i),
        .inst_i(ex_inst_i),
        .alu_op_o(ex_alu_op_o),
        .mem_addr_o(ex_mem_addr_o),
        .reg2_o(ex_reg2_o),
        .cp0_reg_data_o(ex_cp0_reg_data_o),
        .cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
        .cp0_reg_we_o(ex_cp0_reg_we_o),
        .cp0_reg_read_addr_o(ex_cp0_reg_read_addr_o)

    );

    risc32_ex_mem ex_mem (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .wd_i(ex_wd_o),
        .wreg_i(ex_wreg_o),
        .wdata_i(ex_wdata_o),
        .hi_i(ex_hi_o),
        .lo_i(ex_lo_o),
        .whilo_i(ex_whilo_o),
        .cp0_reg_data_i(ex_cp0_reg_data_o),
        .cp0_reg_write_addr_i(ex_cp0_reg_write_addr_o),
        .cp0_reg_we_i(ex_cp0_reg_we_o),
        .wd_o(mem_wd_i),
        .wreg_o(mem_wreg_i),
        .wdata_o(mem_wdata_i),
        .hi_o(mem_hi_i),
        .lo_o(mem_lo_i),
        .whilo_o(mem_whilo_i),
        .alu_op_i(ex_alu_op_o),
        .mem_addr_i(ex_mem_addr_o),
        .reg2_i(ex_reg2_o),
        .alu_op_o(mem_alu_op_i),
        .reg2_o(mem_reg2_i),
        .mem_addr_o(mem_mem_addr_i),
        .cp0_reg_data_o(mem_cp0_reg_data_i),
        .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_i),
        .cp0_reg_we_o(mem_cp0_reg_we_i)
    );

    risc32_memory mem (
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),
        .hi_i(mem_hi_i),
        .lo_i(mem_lo_i),
        .whilo_i(mem_whilo_i),
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o),
        .whilo_o(mem_whilo_o),
        .alu_op_i(mem_alu_op_i),
        .mem_addr_i(mem_mem_addr_i),
        .reg2_i(mem_reg2_i),
        .mem_data_i(ram_data_i),
        .mem_addr_o(ram_addr_o),
        .mem_we_o(ram_we_o),
        .mem_sel_o(ram_sel_o),
        .mem_data_o(ram_data_o),
        .mem_ce_o(ram_ce_o),
        .io_data_i(io_data_i),
        .io_addr_o(io_addr_o),
        .io_we_o(io_we_o),
        .io_data_o(io_data_o),
        .io_ce_o(io_ce_o),
        .cp0_reg_data_i(mem_cp0_reg_data_i),
        .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
        .cp0_reg_we_i(mem_cp0_reg_we_i),
        .cp0_reg_data_o(mem_cp0_reg_data_o),
        .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
        .cp0_reg_we_o(mem_cp0_reg_we_o)
    );

    risc32_mem_wb mem_wb (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .wd_i(mem_wd_o),
        .wreg_i(mem_wreg_o),
        .wdata_i(mem_wdata_o),
        .cp0_reg_data_i(mem_cp0_reg_data_o),
        .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_o),
        .cp0_reg_we_i(mem_cp0_reg_we_o),
        .hi_i(mem_hi_o),
        .lo_i(mem_lo_o),
        .whilo_i(mem_whilo_o),
        .wd_o(wb_wd_i),
        .wreg_o(wb_wreg_i),
        .wdata_o(wb_wdata_i),
        .hi_o(wb_hi_i),
        .lo_o(wb_lo_i),
        .whilo_o(wb_whilo_i),
        .cp0_reg_data_o(cp0_cp0_reg_data_i),
        .cp0_reg_write_addr_o(cp0_cp0_reg_write_addr_i),
        .cp0_reg_we_o(cp0_cp0_reg_we_i)
    );

    risc32_write_back wb (
        .wd_i(wb_wd_i),
        .wreg_i(wb_wreg_i),
        .wdata_i(wb_wdata_i),
        .hi_i(wb_hi_i),
        .lo_i(wb_lo_i),
        .whilo_i(wb_whilo_i),
        .wb_wd(wb_wd),
        .wb_wreg(wb_wreg),
        .wb_wdata(wb_wdata),
        .wb_hi_o(wb_hi),
        .wb_lo_o(wb_lo),
        .wb_whilo_o(wb_whilo)
    );

     risc32_cp0_reg cp0 (
        .clk(clk),
        .rst(rst),
        .int_i(int_i),
        .raddr_i(ex_cp0_reg_read_addr_i),
        .data_i(cp0_cp0_reg_data_i),
        .waddr_i(cp0_cp0_reg_write_addr_i),
        .we_i(cp0_cp0_reg_we_i),
        .data_o(cp0_cp0_reg_data_o),
        .timer_int_o(timer_int_o)
    );


    
endmodule