// Global Const
`define Word_LEN            32
`define Word_Zero           `Word_LEN'h00000000

`define True_v              1'b1
`define False_v             1'b0

`define Inst_Valid          1'b0
`define Inst_Invalid        1'b1

`define Alu_Op_Bus          7:0
`define Alu_Sel_Bus         2:0

`define Stall_Bus           5:0
`define Stop                1'b1
`define NoStop              1'b0

`define Branch 1'b1				
`define NotBranch 1'b0	

`define InDelaySlot         1'b1
`define NotInDelaySlot      1'b0

`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0

// Enable Signal
`define Rst_EN              1'b1
`define Rst_DIS             1'b0

`define Write_EN            1'b1
`define Write_DIS           1'b0

`define Read_EN             1'b1
`define Read_DIS            1'b0

`define Chip_EN             1'b1
`define Chip_DIS            1'b0

// Regfile Const
`define Reg_Width           32
`define Reg_Bus             31:0
`define Reg_Addr_Bus        4:0 
`define Reg_Num             32
`define Reg_Num_Log2        5
`define Double_Reg_Width    64
`define Double_Reg_Bus      63:0

`define NOP_Reg_Addr        5'b00000

// Data RAM
`define Data_Addr_Bus       31:0
`define Data_Bus            31:0
`define Data_Mem_Num        131071
`define Data_Mem_Num_Log2   17
`define Byte_Width          7:0

// FPGA
`define LED                 32'h0000_f000
`define SWITCH              32'h0000_f010
`define SEG                 32'h0000_f020
`define BTN                 32'h0000_f030

// 7 Segment Display
`define SEG_0               8'b00111111
`define SEG_1               8'b00000110
`define SEG_2               8'b01011011
`define SEG_3               8'b01001111
`define SEG_4               8'b01100110
`define SEG_5               8'b01101101
`define SEG_6               8'b01111101
`define SEG_7               8'b00000111
`define SEG_8               8'b01111111
`define SEG_9               8'b01101111
`define SEG_BLANK           8'b00000000
`define REFRESH_COUNTER_WIDTH 17

`define TIME_MIN            21'd2_00

// CPO register address
`define CP0_REG_COUNT       5'b01001       //read and write
`define CP0_REG_COMPARE     5'b01011       //read and write
`define CP0_REG_STATUS      5'b01100       //read and write
`define CP0_REG_CAUSE       5'b01101       //read only
`define CP0_REG_EPC         5'b01110       //read and write
`define CP0_REG_PrId        5'b01111       //read only
`define CP0_REG_CONFIG      5'b10000       //read only

