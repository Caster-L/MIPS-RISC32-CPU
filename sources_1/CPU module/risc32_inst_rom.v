`timescale 1ns/1ps
`include "risc32_consts.v"
`include "risc32_instructions.v"

module risc32_inst_rom(
    input wire                      ce_i,
    input wire[`Inst_Addr_Bus]      addr_i,
    
    output reg[`Inst_Bus]           inst_o
);
    
    wire [`Inst_Bus] inst_mem[0 : 127];

    always @ (*) begin
        if (ce_i == `Chip_DIS) begin
            inst_o = `Word_Zero;
        end else begin
            inst_o = inst_mem[addr_i[`Inst_Mem_Num_Log2 : 2]];
        end
    end
    
    // Store the machine code
    assign inst_mem[0] = 32'h3c010000;
    assign inst_mem[1] = 32'h3421f000;
    assign inst_mem[2] = 32'h8c2f0010;
    assign inst_mem[3] = 32'h8c2d0030;
    assign inst_mem[4] = 32'h201d0000;
    assign inst_mem[5] = 32'h340e0001;
    assign inst_mem[6] = 32'h11ae0003;
    assign inst_mem[7] = 32'h201d0000;
    assign inst_mem[8] = 32'h0800003b;
    assign inst_mem[9] = 32'h201d0000;
    assign inst_mem[10] = 32'h20020002;
    assign inst_mem[11] = 32'h01e2802a;
    assign inst_mem[12] = 32'h1600fff5;
    assign inst_mem[13] = 32'h201d0000;
    assign inst_mem[14] = 32'h20030002;
    assign inst_mem[15] = 32'h0043202a;
    assign inst_mem[16] = 32'h14800027;
    assign inst_mem[17] = 32'h201d0000;
    assign inst_mem[18] = 32'h20050002;
    assign inst_mem[19] = 32'h00003020;
    assign inst_mem[20] = 32'h00053820;
    assign inst_mem[21] = 32'h10e00005;
    assign inst_mem[22] = 32'h201d0000;
    assign inst_mem[23] = 32'h00c53020;
    assign inst_mem[24] = 32'h20e7ffff;
    assign inst_mem[25] = 32'h08000015;
    assign inst_mem[26] = 32'h201d0000;
    assign inst_mem[27] = 32'h0046402a;
    assign inst_mem[28] = 32'h1500000d;
    assign inst_mem[29] = 32'h201d0000;
    assign inst_mem[30] = 32'h00024820;
    assign inst_mem[31] = 32'h01254822;
    assign inst_mem[32] = 32'h0120502a;
    assign inst_mem[33] = 32'h15400005;
    assign inst_mem[34] = 32'h201d0000;
    assign inst_mem[35] = 32'h11200014;
    assign inst_mem[36] = 32'h201d0000;
    assign inst_mem[37] = 32'h0800001f;
    assign inst_mem[38] = 32'h201d0000;
    assign inst_mem[39] = 32'h20a50001;
    assign inst_mem[40] = 32'h08000013;
    assign inst_mem[41] = 32'h201d0000;
    assign inst_mem[42] = 32'h0800002c;
    assign inst_mem[43] = 32'h201d0000;
    assign inst_mem[44] = 32'hac220020;
    assign inst_mem[45] = 32'h201107d0;
    assign inst_mem[46] = 32'h20122710;
    assign inst_mem[47] = 32'h2252ffff;
    assign inst_mem[48] = 32'h1e40fffe;
    assign inst_mem[49] = 32'h201d0000;
    assign inst_mem[50] = 32'h2231ffff;
    assign inst_mem[51] = 32'h1e20fffa;
    assign inst_mem[52] = 32'h201d0000;
    assign inst_mem[53] = 32'h20420001;
    assign inst_mem[54] = 32'h0800000b;
    assign inst_mem[55] = 32'h201d0000;
    assign inst_mem[56] = 32'h20420001;
    assign inst_mem[57] = 32'h0800000b;
    assign inst_mem[58] = 32'h201d0000;
    assign inst_mem[59] = 32'hac2f0000;
    assign inst_mem[60] = 32'hac2f0020;
    assign inst_mem[61] = 32'h08000002;
    assign inst_mem[62] = 32'h201d0000;
    assign inst_mem[63] = 32'h00000000;




endmodule

