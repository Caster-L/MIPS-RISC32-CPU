`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_execute(
    input wire[`Alu_Op_Bus]     alu_op_i,
    input wire[`Alu_Sel_Bus]    alu_sel_i,
    input wire[`Reg_Bus]        reg1_i,
    input wire[`Reg_Bus]        reg2_i,
    input wire[`Reg_Addr_Bus]   wd_i,
    input wire                  wreg_i,
    input wire[`Reg_Bus]        hi_i,
    input wire[`Reg_Bus]        lo_i,

    input wire                  wb_whilo_i,
    input wire[`Reg_Bus]        wb_hi_i,
    input wire[`Reg_Bus]        wb_lo_i,

    input wire                  mem_whilo_i,
    input wire[`Reg_Bus]        mem_hi_i,
    input wire[`Reg_Bus]        mem_lo_i,

    input wire                  wb_cp0_reg_we,
    input wire[`Reg_Addr_Bus]   wb_cp0_reg_write_addr,
    input wire[`Reg_Bus]        wb_cp0_reg_data,

    input wire                  mem_cp0_reg_we,
    input wire[`Reg_Addr_Bus]   mem_cp0_reg_write_addr,
    input wire[`Reg_Bus]        mem_cp0_reg_data,

    input wire[`Reg_Bus]        cp0_reg_data_i,

    input wire[`Reg_Bus]        link_address_i,
    input wire                  is_in_delayslot_i,

    input wire[`Reg_Bus]        inst_i,
    
    output reg[`Reg_Addr_Bus]   wd_o,
    output reg                  wreg_o,
    output reg[`Reg_Bus]        wdata_o,

    output reg                  whilo_o,
    output reg[`Reg_Bus]        hi_o,
    output reg[`Reg_Bus]        lo_o,

    output reg                  cp0_reg_we_o,
    output reg[`Reg_Addr_Bus]   cp0_reg_write_addr_o,
    output reg[`Reg_Bus]        cp0_reg_data_o,
    output reg[`Reg_Addr_Bus]   cp0_reg_read_addr_o,

    output wire[`Alu_Op_Bus]    alu_op_o,
    output wire[`Reg_Bus]       mem_addr_o,
    output wire[`Reg_Bus]       reg2_o,

    output wire                 stallreg
);
    reg[`Reg_Bus] logic_out, shift_res, move_res, arithmetic_res;
    reg[`Reg_Bus] HI, LO;

    wire ov_sum; // Store the signal whether the sum is over
    wire reg1_eq_reg2; // reg1 equal to reg2
    wire reg1_lt_reg2; // reg1 less than reg2
    wire[`Reg_Bus] reg2_i_mux, reg1_i_not, result_sum, result_clo, result_clz; // The result of alu
    wire[`Reg_Bus] opdata1_mult, opdata2_mult;
    wire[`Double_Reg_Bus] hilo_temp, mul_res;

    assign stallreg = `NoStop;
    assign alu_op_o = alu_op_i;
    assign mem_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]};
    assign reg2_o = reg2_i;

    // Get HI and LO from hilo or others
    always @ (*) begin
        if (mem_whilo_i == `Write_EN) begin
            HI = mem_hi_i;
            LO = mem_lo_i;
        end else if (wb_whilo_i == `Write_EN) begin
            HI = wb_hi_i;
            LO = wb_lo_i;
        end else begin
            HI = hi_i;
            LO = lo_i;
        end
    end
    
    // ALU Logic
    always @ (*) begin
        case(alu_op_i)
            `EXE_OR_OP: begin
                logic_out = reg1_i | reg2_i;
            end
            `EXE_AND_OP: begin
                logic_out = reg1_i & reg2_i;
            end
            `EXE_XOR_OP: begin
                logic_out = reg1_i ^ reg2_i;
            end
            `EXE_NOR_OP: begin
                logic_out = ~(reg1_i | reg2_i);
            end
            default: begin
                logic_out = `Word_Zero;
            end
        endcase
    end

    // ALU Shift
    always @ (*) begin
        case(alu_op_i)
            `EXE_SLL_OP: begin
                shift_res = reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP: begin
                shift_res = reg2_i >> reg1_i[4:0];
            end
            `EXE_SRA_OP: begin
                shift_res = ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
            end
            default: begin
                shift_res = `Word_Zero;
            end
        endcase
    end

    // ALU Move
    always @ (*) begin
        case(alu_op_i)
            `EXE_MFHI_OP: begin
                move_res = HI;
            end
            `EXE_MFLO_OP: begin
                move_res = LO;
            end
            `EXE_MOVN_OP: begin
                move_res = reg1_i;
            end
            `EXE_MOVZ_OP: begin
                move_res = reg1_i;
            end
            `EXE_MFC0_OP: begin
                cp0_reg_read_addr_o = inst_i[15:11];
                move_res = cp0_reg_data_i;
                if (mem_cp0_reg_we == `Write_EN && mem_cp0_reg_write_addr == inst_i[15:11]) begin
                    move_res = mem_cp0_reg_data;
                end else if (wb_cp0_reg_we == `Write_EN && wb_cp0_reg_write_addr == inst_i[15:11]) begin
                    move_res = wb_cp0_reg_data;
                end
            end
            default: begin
                move_res = `Word_Zero;
            end
        endcase
    end

    // Add and Compare
    assign reg2_i_mux = ((alu_op_i == `EXE_SUB_OP) || (alu_op_i == `EXE_SUBU_OP) || (alu_op_i == `EXE_SLT_OP)) ? (~reg2_i) + 1 : reg2_i;
    assign result_sum = reg1_i + reg2_i_mux;
    assign ov_sum = (~reg1_i[31] && ~reg2_i_mux[31] && result_sum[31]) || (reg1_i[31] && reg2_i_mux[31] && ~result_sum[31]); // Only positive + positive = negative or negative + negative = positive
    assign reg1_lt_reg2 = (alu_op_i == `EXE_SLT_OP) ? ((reg1_i[31] && ~reg2_i[31]) || (~reg1_i[31] && ~reg2_i[31] && result_sum[31]) || (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);
    assign reg1_i_not = ~reg1_i;
    assign result_clz = reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
    assign result_clo = (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;

    assign opdata1_mult = (((alu_op_i == `EXE_MUL_OP) || (alu_op_i == `EXE_MULT_OP)) && reg1_i[31]) ? (~reg1_i + 1) : reg1_i;
    assign opdata2_mult = (((alu_op_i == `EXE_MUL_OP) || (alu_op_i == `EXE_MULT_OP)) && reg2_i[31]) ? (~reg2_i + 1) : reg2_i;

    // Alu Arithmetic
    always @ (*) begin
        case(alu_op_i)
            `EXE_SLT_OP, `EXE_SLTU_OP: begin
                arithmetic_res = reg1_lt_reg2;
            end
            `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                arithmetic_res = result_sum;
            end
            `EXE_SUB_OP, `EXE_SUBU_OP: begin
                arithmetic_res = result_sum;
            end
            `EXE_CLO_OP: begin
                arithmetic_res = result_clo;
            end
            `EXE_CLZ_OP: begin
                arithmetic_res = result_clz;
            end 
            default: begin
                arithmetic_res = `Word_Zero;
            end
        endcase
    end

    // The output of hi and lo
    always @ (*) begin
        if (alu_op_i == `EXE_MTHI_OP) begin
            whilo_o = `Write_EN;
            hi_o = reg1_i;
            lo_o = LO;
        end else if (alu_op_i == `EXE_MTLO_OP) begin
            whilo_o = `Write_EN;
            hi_o = HI;
            lo_o = reg1_i;
        end else begin
            whilo_o = `Write_DIS;
            hi_o = `Word_Zero;
            lo_o = `Word_Zero;
        end
    end

    // Check whether the add and sub is over or not, if so, write disabled
    always @ (*) begin
        if (((alu_op_i == `EXE_ADD_OP) || (alu_op_i == `EXE_ADDI_OP) || (alu_op_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o = `Write_DIS;
        end else begin
            wreg_o = wreg_i;
        end
    end

    // Assign values based on parallel alu results
    always @ (*) begin
        wd_o = wd_i;
        case(alu_sel_i)
            `EXE_RES_LOGIC: begin
                wdata_o = logic_out;
            end
            `EXE_RES_SHIFT: begin
                wdata_o = shift_res;
            end
            `EXE_RES_MOVE: begin
                wdata_o = move_res;
            end
            `EXE_RES_ARITHMETIC: begin
                wdata_o = arithmetic_res;
            end
            `EXE_RES_JUMP_BRANCH: begin
                wdata_o = link_address_i;
            end
            default: begin
                wdata_o = `Word_Zero;
            end
        endcase
    end

    always @ (*) begin
        if (alu_op_i == `EXE_MTC0_OP) begin
            cp0_reg_write_addr_o = inst_i[15:11];
            cp0_reg_we_o = `Write_EN;
            cp0_reg_data_o = reg1_i;
        end else begin
            cp0_reg_write_addr_o = 5'b00000;
            cp0_reg_we_o = `Write_DIS;
            cp0_reg_data_o = `Word_Zero;
        end
    end

endmodule