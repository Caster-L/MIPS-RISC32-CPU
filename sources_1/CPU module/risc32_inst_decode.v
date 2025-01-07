`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_inst_decode (
    input wire[`Inst_Addr_Bus]      pc_i,
    input wire[`Inst_Bus]           inst_i,

    input wire                      is_in_delayslot_i,

    input wire[`Reg_Bus]            reg1_data_i,
    input wire[`Reg_Bus]            reg2_data_i,

    input wire                      ex_wreg_i,
    input wire[`Reg_Addr_Bus]       ex_wd_i,
    input wire[`Reg_Bus]            ex_wdata_i,
    input wire[`Alu_Op_Bus]         ex_alu_op_i,

    input wire                      mem_wreg_i,
    input wire[`Reg_Addr_Bus]       mem_wd_i,
    input wire[`Reg_Bus]            mem_wdata_i,
    
    output reg                      reg1_read_o,
    output reg                      reg2_read_o,
    output reg[`Reg_Addr_Bus]       reg1_addr_o,
    output reg[`Reg_Addr_Bus]       reg2_addr_o,
    output reg[`Alu_Op_Bus]         alu_op_o,
    output reg[`Alu_Sel_Bus]        alu_sel_o,
    output reg[`Reg_Bus]            reg1_o,
    output reg[`Reg_Bus]            reg2_o,
    output reg[`Reg_Addr_Bus]       wd_o, // Write Destination Register Address Output
    output reg                      wreg_o, // Write Register Enable Output

    output reg                      next_inst_in_delayslot_o,
    output reg                      branch_flag_o,
    output reg[`Reg_Bus]            branch_target_address_o,
    output reg[`Reg_Bus]            link_addr_o,
    output wire                     is_in_delayslot_o,

    output wire[`Reg_Bus]           inst_o,

    output wire                     stallreg
);

    wire [5:0] op1 = inst_i[31:26];
    wire [4:0] op2 = inst_i[10:6]; // R instruction "sa"
    wire [5:0] op3 = inst_i[5:0]; // R instruction "func"
    wire [4:0] op4 = inst_i[20:16]; // R instruction or I instruction "rt"

    reg[`Reg_Bus] imm; // Immediate Number
    reg inst_valid;

    wire[`Reg_Bus]  pc_plus_4, pc_plus_8;
    wire[`Reg_Bus]  imm_sll2_signedext;

    reg stallreg_for_reg1_load, stallreg_for_reg2_load;
    wire pre_inst_is_load;

    assign pre_inst_is_load = (ex_alu_op_i == `EXE_LB_OP) || (ex_alu_op_i == `EXE_LBU_OP) || (ex_alu_op_i == `EXE_LH_OP)
                           || (ex_alu_op_i == `EXE_LHU_OP) || (ex_alu_op_i == `EXE_LW_OP);


    assign stallreg = stallreg_for_reg1_load | stallreg_for_reg2_load;

    assign pc_plus_4 = pc_i + 4;
    assign pc_plus_8 = pc_i + 8;
    assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};

    assign is_in_delayslot_o = is_in_delayslot_i;

    assign inst_o = inst_i;

    always @ (*) begin

        reg1_addr_o = inst_i[25:21];
        reg2_addr_o = inst_i[20:16];

        case(op1)
            `EXE_SPECIAL: begin
                case(op2)
                    5'b00000: begin
                        case(op3)
                            `EXE_OR: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_OR_OP;
                                alu_sel_o = `EXE_RES_LOGIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_AND: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_AND_OP;
                                alu_sel_o = `EXE_RES_LOGIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_XOR: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_XOR_OP;
                                alu_sel_o = `EXE_RES_LOGIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_NOR: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_NOR_OP;
                                alu_sel_o = `EXE_RES_LOGIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_SLLV: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_SLL_OP;
                                alu_sel_o = `EXE_RES_SHIFT;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_SRLV: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_SRL_OP;
                                alu_sel_o = `EXE_RES_SHIFT;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_SRAV: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_SRA_OP;
                                alu_sel_o = `EXE_RES_SHIFT;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_MFHI: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MFHI_OP;
                                alu_sel_o = `EXE_RES_MOVE;
                                reg1_read_o = `Read_DIS;
                                reg2_read_o = `Read_DIS;
                                imm = `Word_Zero;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_MFLO: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MFLO_OP;
                                alu_sel_o = `EXE_RES_MOVE;
                                reg1_read_o = `Read_DIS;
                                reg2_read_o = `Read_DIS;
                                imm = `Word_Zero;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_MTHI: begin
                                wreg_o = `Write_DIS;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MTHI_OP;
                                alu_sel_o = `EXE_RES_MOVE;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_DIS;
                                imm = `Word_Zero;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_MTLO: begin
                                wreg_o = `Write_DIS;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MTLO_OP;
                                alu_sel_o = `EXE_RES_MOVE;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_DIS;
                                imm = `Word_Zero;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_MOVN: begin
                                wreg_o = `Write_DIS;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MOVN_OP;
                                alu_sel_o = `EXE_RES_MOVE;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                                if (reg2_o != `Word_Zero) begin
                                    wreg_o = `Write_EN;
                                end else begin
                                    wreg_o = `Write_DIS;
                                end
                            end
                            `EXE_MOVZ: begin
                                wreg_o = `Write_DIS;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MOVZ_OP;
                                alu_sel_o = `EXE_RES_MOVE;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                                if (reg2_o == `Word_Zero) begin
                                    wreg_o = `Write_EN;
                                end else begin
                                    wreg_o = `Write_DIS;
                                end
                            end
                            `EXE_SLT: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_SLT_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_SLTU: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_SLTU_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_ADD: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_ADD_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_ADDU: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_ADDU_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_SUB: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_SUB_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_SUBU: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_SUBU_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_MULT: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MULT_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_MULTU: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_MULTU_OP;
                                alu_sel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_EN;
                                inst_valid = `Inst_Valid;
                                branch_flag_o = `NotBranch;
                            end
                            `EXE_JR: begin
                                wreg_o = `Write_DIS;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_JR_OP;
                                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_DIS;
                                link_addr_o = `Word_Zero;
                                branch_target_address_o = reg1_o;
                                branch_flag_o = `Branch;
                                next_inst_in_delayslot_o = `InDelaySlot;
                                inst_valid = `Inst_Valid;
                            end
                            `EXE_JALR: begin
                                wreg_o = `Write_EN;
                                wd_o = inst_i[15:11];
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_JALR_OP;
                                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                                reg1_read_o = `Read_EN;
                                reg2_read_o = `Read_DIS;
                                link_addr_o = pc_plus_8;
                                branch_target_address_o = reg1_o;
                                branch_flag_o = `Branch;
                                next_inst_in_delayslot_o = `InDelaySlot;
                                inst_valid = `Inst_Valid;
                            end
                            `EXE_SYNC: begin
                                wreg_o = `Write_DIS;
                                wd_o = `NOP_Reg_Addr;
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                alu_op_o = `EXE_NOP_OP;
                                alu_sel_o = `EXE_RES_NOP;
                                reg1_read_o = `Read_DIS;
                                reg2_read_o = `Read_EN;
                                imm = `Word_Zero;
                                inst_valid = `Inst_Valid;
                            end
                            default: begin
                                wreg_o = `Write_DIS;
                                alu_op_o = `EXE_NOP_OP;
                                alu_sel_o = `EXE_RES_NOP;
                                reg1_read_o = `Read_DIS;
                                reg2_read_o = `Read_DIS;
                                reg1_addr_o = inst_i[25:21];
                                reg2_addr_o = inst_i[20:16];
                                wd_o = inst_i[15:11];
                                inst_valid = `Inst_Invalid;
                                imm = imm;
                                wd_o = wd_o;
                            end
                        endcase
                    end
                    default: begin
                        if (inst_i[31:21] == 11'h0) begin
                            case(op3)
                                `EXE_SLL: begin
                                    wreg_o = `Write_EN;
                                    alu_op_o = `EXE_SLL_OP;
                                    alu_sel_o = `EXE_RES_SHIFT;
                                    reg1_read_o = `Read_DIS;
                                    reg2_read_o = `Read_EN;
                                    reg1_addr_o = inst_i[25:21];
                                    reg2_addr_o = inst_i[20:16];
                                    imm[4:0] = inst_i[10:6];
                                    wd_o = inst_i[15:11];
                                    inst_valid = `Inst_Valid;
                                    branch_flag_o = `NotBranch;
                                end
                                `EXE_SRL: begin
                                    wreg_o = `Write_EN;
                                    alu_op_o = `EXE_SRL_OP;
                                    alu_sel_o = `EXE_RES_SHIFT;
                                    reg1_read_o = `Read_DIS;
                                    reg2_read_o = `Read_EN;
                                    reg1_addr_o = inst_i[25:21];
                                    reg2_addr_o = inst_i[20:16];
                                    imm[4:0] = inst_i[10:6];
                                    wd_o = inst_i[15:11];
                                    inst_valid = `Inst_Valid;
                                    branch_flag_o = `NotBranch;
                                end
                                `EXE_SRA: begin
                                    wreg_o = `Write_EN;
                                    alu_op_o = `EXE_SRA_OP;
                                    alu_sel_o = `EXE_RES_SHIFT;
                                    reg1_read_o = `Read_DIS;
                                    reg2_read_o = `Read_EN;
                                    reg1_addr_o = inst_i[25:21];
                                    reg2_addr_o = inst_i[20:16];
                                    imm[4:0] = inst_i[10:6];
                                    wd_o = inst_i[15:11];
                                    inst_valid = `Inst_Valid;
                                    branch_flag_o = `NotBranch;
                                end
                                default: begin
                                    wreg_o = `Write_DIS;
                                    alu_op_o = `EXE_NOP_OP;
                                    alu_sel_o = `EXE_RES_NOP;
                                    reg1_read_o = `Read_DIS;
                                    reg2_read_o = `Read_DIS;
                                    inst_valid = `Inst_Invalid;
                                    imm = `Word_Zero;
                                    wd_o = `NOP_Reg_Addr;
                                    branch_flag_o = `NotBranch;
                                end
                            endcase
                        end else begin
                            wreg_o = `Write_DIS;
                            alu_op_o = `EXE_NOP_OP;
                            alu_sel_o = `EXE_RES_NOP;
                            reg1_read_o = `Read_DIS;
                            reg2_read_o = `Read_DIS;
                            inst_valid = `Inst_Invalid;
                            imm = `Word_Zero;
                            wd_o = `NOP_Reg_Addr;
                            branch_flag_o = `NotBranch;
                        end


                    end
                endcase
            end
            `EXE_ORI: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_OR_OP;
                alu_sel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {16'h0, inst_i[15:0]};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_ANDI: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_AND_OP;
                alu_sel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {16'h0, inst_i[15:0]};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_XORI: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_XOR_OP;
                alu_sel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {16'h0, inst_i[15:0]};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_LUI: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_XOR_OP;
                alu_sel_o = `EXE_RES_LOGIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {inst_i[15:0], 16'h0};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_SLTI: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_SLT_OP;
                alu_sel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_SLTIU: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_SLTU_OP;
                alu_sel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_ADDI: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_ADDI_OP;
                alu_sel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_ADDIU: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_ADDIU_OP;
                alu_sel_o = `EXE_RES_ARITHMETIC;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_PREF: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_NOP_OP;
                alu_sel_o = `EXE_RES_NOP;
                reg1_read_o = `Read_DIS;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                imm = `Word_Zero;
                wd_o = `NOP_Reg_Addr;
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_J: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_J_OP;
                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                reg1_read_o = `Read_DIS;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = inst_i[20:16];
                link_addr_o = `Word_Zero;
                next_inst_in_delayslot_o = `InDelaySlot;
                branch_flag_o = `Branch;
                branch_target_address_o = {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                inst_valid = `Inst_Valid;
            end
            `EXE_JAL: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_JAL_OP;
                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                reg1_read_o = `Read_DIS;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = `Reg_Num_Log2'b11111;
                link_addr_o = pc_plus_8;
                next_inst_in_delayslot_o = `InDelaySlot;
                branch_target_address_o = {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                branch_flag_o = `Branch;
                inst_valid = `Inst_Valid;
            end
            `EXE_BEQ: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_BEQ_OP;
                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_EN;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = inst_i[15:11];
                link_addr_o = `Word_Zero;
                inst_valid = `Inst_Valid;
                if (reg1_o == reg2_o) begin
                    branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                    next_inst_in_delayslot_o = `InDelaySlot;
                    branch_flag_o = `Branch;
                end else begin
                    branch_target_address_o = `Word_Zero;
                    next_inst_in_delayslot_o = `NotInDelaySlot;
                    branch_flag_o = `NotBranch;
                end
            end
            `EXE_BGTZ: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_BGTZ_OP;
                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = `Reg_Num_Log2'b11111;
                link_addr_o = `Word_Zero;
                inst_valid = `Inst_Valid;
                if (reg1_o != `Word_Zero && reg1_o[31] == 1'b0) begin
                    branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                    next_inst_in_delayslot_o = `InDelaySlot;
                    branch_flag_o = `Branch;
                end else begin
                    branch_target_address_o = `Word_Zero;
                    next_inst_in_delayslot_o = `NotInDelaySlot;
                    branch_flag_o = `NotBranch;
                end
            end
            `EXE_BLEZ: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_BGTZ_OP;
                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = `Reg_Num_Log2'b11111;
                link_addr_o = `Word_Zero;
                inst_valid = `Inst_Valid;
                if (reg1_o != `Word_Zero && reg1_o[31] == 1'b1) begin
                    branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                    next_inst_in_delayslot_o = `InDelaySlot;
                    branch_flag_o = `Branch;
                end else begin
                    branch_target_address_o = `Word_Zero;
                    next_inst_in_delayslot_o = `NotInDelaySlot;
                    branch_flag_o = `NotBranch;
                end
            end
            `EXE_BNE: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_BGTZ_OP;
                alu_sel_o = `EXE_RES_JUMP_BRANCH;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_EN;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = `Reg_Num_Log2'b11111;
                link_addr_o = `Word_Zero;
                inst_valid = `Inst_Valid;
                if (reg1_o != reg2_o) begin
                    branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                    next_inst_in_delayslot_o = `InDelaySlot;
                    branch_flag_o = `Branch;
                end else begin
                    branch_target_address_o = `Word_Zero;
                    next_inst_in_delayslot_o = `NotInDelaySlot;
                    branch_flag_o = `NotBranch;
                end
            end
            `EXE_LB: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_LB_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_LBU: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_LBU_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_LH: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_LH_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_LHU: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_LHU_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_LW: begin
                wreg_o = `Write_EN;
                alu_op_o = `EXE_LW_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_DIS;
                reg1_addr_o = inst_i[25:21];
                wd_o = inst_i[20:16];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_SB: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_SB_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_EN;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = inst_i[15:11];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_SH: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_SH_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_EN;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = inst_i[15:11];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_SW: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_SW_OP;
                alu_sel_o = `EXE_RES_LOAD_STORE;
                reg1_read_o = `Read_EN;
                reg2_read_o = `Read_EN;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                wd_o = inst_i[15:11];
                inst_valid = `Inst_Valid;
                branch_flag_o = `NotBranch;
            end
            `EXE_SPECIAL2_INST: begin
                case(op3)
                    `EXE_CLZ: begin
                        wreg_o = `Write_EN;
                        alu_op_o = `EXE_CLZ_OP;
                        alu_sel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Read_EN;
                        reg2_read_o = `Read_DIS;
                        reg1_addr_o = inst_i[25:21];
                        reg2_addr_o = inst_i[20:16];
                        imm = `Word_Zero;
                        wd_o = inst_i[20:16];
                        inst_valid = `Inst_Valid;
                        branch_flag_o = `NotBranch;
                    end
                    `EXE_CLO: begin
                        wreg_o = `Write_EN;
                        alu_op_o = `EXE_CLO_OP;
                        alu_sel_o = `EXE_RES_ARITHMETIC;
                        reg1_read_o = `Read_EN;
                        reg2_read_o = `Read_DIS;
                        reg1_addr_o = inst_i[25:21];
                        reg2_addr_o = inst_i[20:16];
                        imm = `Word_Zero;
                        wd_o = inst_i[20:16];
                        inst_valid = `Inst_Valid;
                        branch_flag_o = `NotBranch;
                    end
                    `EXE_MUL: begin
                        wreg_o = `Write_EN;
                        alu_op_o = `EXE_MUL_OP;
                        alu_sel_o = `EXE_RES_MUL;
                        reg1_read_o = `Read_EN;
                        reg2_read_o = `Read_EN;
                        reg1_addr_o = inst_i[25:21];
                        reg2_addr_o = inst_i[20:16];
                        wd_o = inst_i[20:16];
                        inst_valid = `Inst_Valid;
                        branch_flag_o = `NotBranch;
                    end
                    default: begin
                        wreg_o = `Write_DIS;
                        alu_op_o = `EXE_NOP_OP;
                        alu_sel_o = `EXE_RES_NOP;
                        reg1_read_o = `Read_DIS;
                        reg2_read_o = `Read_DIS;
                        inst_valid = `Inst_Invalid;
                        imm = `Word_Zero;
                        wd_o = `NOP_Reg_Addr;
                        next_inst_in_delayslot_o = `NotInDelaySlot;
                        branch_flag_o = `NotBranch;
                        branch_target_address_o = `Word_Zero;
                        link_addr_o = `Word_Zero;
                    end
                endcase
            end
            `EXE_REGIMM_INST: begin
                case(op4)
                    `EXE_BGEZ: begin
                        wreg_o = `Write_DIS;
                        alu_op_o = `EXE_BGEZ_OP;
                        alu_sel_o = `EXE_RES_JUMP_BRANCH;
                        reg1_read_o = `Read_EN;
                        reg2_read_o = `Read_DIS;
                        link_addr_o = `Word_Zero;
                        inst_valid = `Inst_Valid;
                        if (reg1_o[31] == 1'b0) begin
                            branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                            next_inst_in_delayslot_o = `InDelaySlot;
                            branch_flag_o = `Branch;
                        end else begin
                            branch_target_address_o = `Word_Zero;
                            next_inst_in_delayslot_o = `NotInDelaySlot;
                            branch_flag_o = `NotBranch;
                        end
                    end
                    `EXE_BLTZ: begin
                        wreg_o = `Write_DIS;
                        alu_op_o = `EXE_BGEZAL_OP;
                        alu_sel_o = `EXE_RES_JUMP_BRANCH;
                        reg1_read_o = `Read_EN;
                        reg2_read_o = `Read_DIS;
                        link_addr_o = `Word_Zero;
                        inst_valid = `Inst_Valid;
                        if (reg1_o[31] == 1'b1) begin
                            branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                            next_inst_in_delayslot_o = `InDelaySlot;
                            branch_flag_o = `Branch;
                        end else begin
                            branch_target_address_o = `Word_Zero;
                            next_inst_in_delayslot_o = `NotInDelaySlot;
                            branch_flag_o = `NotBranch;
                        end
                    end
                    `EXE_BGEZAL: begin
                        wreg_o = `Write_EN;
                        alu_op_o = `EXE_BGEZAL_OP;
                        alu_sel_o = `EXE_RES_JUMP_BRANCH;
                        reg1_read_o = `Read_EN;
                        reg2_read_o = `Read_DIS;
                        link_addr_o = pc_plus_8;
                        wd_o = `Reg_Num_Log2'b11111;
                        inst_valid = `Inst_Valid;
                        if (reg1_o[31] == 1'b0) begin
                            branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                            next_inst_in_delayslot_o = `InDelaySlot;
                            branch_flag_o = `Branch;
                        end else begin
                            branch_target_address_o = `Word_Zero;
                            next_inst_in_delayslot_o = `NotInDelaySlot;
                            branch_flag_o = `NotBranch;
                        end
                    end
                    `EXE_BLTZAL: begin
                        wreg_o = `Write_EN;
                        alu_op_o = `EXE_BGEZAL_OP;
                        alu_sel_o = `EXE_RES_JUMP_BRANCH;
                        reg1_read_o = `Read_EN;
                        reg2_read_o = `Read_DIS;
                        link_addr_o = pc_plus_8;
                        wd_o = `Reg_Num_Log2'b11111;
                        inst_valid = `Inst_Valid;
                        if (reg1_o[31] == 1'b1) begin
                            branch_target_address_o = pc_plus_4 + imm_sll2_signedext;
                            next_inst_in_delayslot_o = `InDelaySlot;
                            branch_flag_o = `Branch;
                        end else begin
                            branch_target_address_o = `Word_Zero;
                            next_inst_in_delayslot_o = `NotInDelaySlot;
                            branch_flag_o = `NotBranch;
                        end
                    end
                    default: begin
                        wreg_o = `Write_DIS;
                        alu_op_o = `EXE_NOP_OP;
                        alu_sel_o = `EXE_RES_NOP;
                        reg1_read_o = `Read_DIS;
                        reg2_read_o = `Read_DIS;
                        inst_valid = `Inst_Invalid;
                        imm = `Word_Zero;
                        wd_o = `NOP_Reg_Addr;
                        next_inst_in_delayslot_o = `NotInDelaySlot;
                        branch_flag_o = `NotBranch;
                        branch_target_address_o = `Word_Zero;
                        link_addr_o = `Word_Zero;
                    end
                endcase
            end
            default: begin
                wreg_o = `Write_DIS;
                alu_op_o = `EXE_NOP_OP;
                alu_sel_o = `EXE_RES_NOP;
                reg1_read_o = `Read_DIS;
                reg2_read_o = `Read_DIS;
                inst_valid = `Inst_Invalid;
                imm = `Word_Zero;
                wd_o = `NOP_Reg_Addr;
                next_inst_in_delayslot_o = `NotInDelaySlot;
                branch_flag_o = `NotBranch;
                branch_target_address_o = `Word_Zero;
                link_addr_o = `Word_Zero;
            end
        endcase
        
        if (inst_i[31:21] == 11'b01000000000 && inst_i[10:0] == 11'b00000000000) begin
            alu_op_o = `EXE_MFC0_OP;
            alu_sel_o = `EXE_RES_MOVE;
            wd_o = inst_i[20:16];
            wreg_o = `Write_EN;
            inst_valid = `Inst_Valid;
            reg1_read_o = `Read_DIS;
            reg2_read_o = `Read_DIS;
        end else if (inst_i[31:21] == 11'b01000000100 && inst_i[10:0] == 11'b00000000000) begin
            alu_op_o = `EXE_MTC0_OP;
            alu_sel_o = `EXE_RES_NOP;
            wreg_o = `Write_DIS;
            inst_valid = `Inst_Valid;
            reg1_read_o = `Read_EN;
            reg1_addr_o = inst_i[20:16];
            reg2_read_o = `Read_DIS;
        end
    end 

    always @ (*) begin
        if (pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1) begin
            reg1_o = reg1_o;
            stallreg_for_reg1_load = `Stop;
        end else if ((reg1_read_o == `Read_EN) && (ex_wreg_i == `Write_EN) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o = ex_wdata_i;
            stallreg_for_reg1_load = `NoStop;
        end else if ((reg1_read_o == `Read_EN) && (mem_wreg_i == `Write_EN) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o = mem_wdata_i;
            stallreg_for_reg1_load = `NoStop;
        end else if (reg1_read_o == `Read_EN) begin
            reg1_o = reg1_data_i;
            stallreg_for_reg1_load = `NoStop;
        end else if (reg1_read_o == `Read_DIS) begin
            reg1_o = imm;
            stallreg_for_reg1_load = `NoStop;
        end else begin
            reg1_o = `Word_Zero;
            stallreg_for_reg1_load = `NoStop;
        end
    end

    always @ (*) begin
        if (pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1) begin
            reg2_o = reg2_o;
            stallreg_for_reg2_load = `Stop;
        end else if ((reg2_read_o == `Read_EN) && (ex_wreg_i == `Write_EN) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o = ex_wdata_i;
            stallreg_for_reg2_load = `NoStop;
        end else if ((reg2_read_o == `Read_EN) && (mem_wreg_i == `Write_EN) && (mem_wd_i == reg2_addr_o)) begin
            reg2_o = mem_wdata_i;
            stallreg_for_reg2_load = `NoStop;
        end else if (reg2_read_o == `Read_EN) begin
            reg2_o = reg2_data_i;
            stallreg_for_reg2_load = `NoStop;
        end else if (reg2_read_o == `Read_DIS) begin
            reg2_o = imm;
            stallreg_for_reg2_load = `NoStop;
        end else begin
            reg2_o = `Word_Zero;
            stallreg_for_reg2_load = `NoStop;
        end
    end
endmodule