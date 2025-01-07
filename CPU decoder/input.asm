# 初始化 FPGA 基地址
    addi $1, $0, 0xf000     # $1 = FPGA 基地址
main:
    # 从 FPGA 加载要判断的数 n
    lw $2, 0x10($1)
    addi $29, $0, 0

    lw $13, 0x30($1)
    ori $14, $0, 0x0001
    beq $13, $14, check
    andi $29, $0, 0
    j display
    andi $29, $0, 0

check:
    # 边界检查：如果 n < 2，则不是素数
    addi $3, $0, 2          # $3 = 2
    slt  $4, $2, $3         # 如果 n < 2，$4 = 1
    bne  $4, $0, not_prime  # 如果 $4 != 0，跳转到 not_prime
    addi $29, $0, 0

    # 初始化除数 i = 2
    addi $5, $0, 2          # $5 = i

check_loop:
    # 计算 i_squared = i * i（使用加法循环）
    add  $6, $0, $0         # $6 = i_squared = 0
    add  $7, $0, $5         # $7 = counter = i

i_square_loop:
    beq  $7, $0, compare_i_n   # 如果 counter == 0，跳转到 compare_i_n
    add  $6, $6, $5            # i_squared += i
    addi $7, $7, -1            # counter -= 1
    j    i_square_loop
    nop

compare_i_n:
    # 如果 i_squared > n，跳出循环，n 是素数
    slt  $8, $2, $6            # 如果 n < i_squared，$8 = 1
    bne  $8, $0, is_prime      # 如果 $8 != 0，跳转到 is_prime
    addi $29, $0, 0

    # 检查 n 是否能被 i 整除
    add  $9, $0, $2            # $9 = temp = n

mod_loop:
    sub  $9, $9, $5            # temp -= i
    slt  $10, $9, $0           # 如果 temp < 0，$10 = 1
    bne  $10, $0, next_i       # 如果 temp < 0，跳转到 next_i
    addi $29, $0, 0
    beq  $9, $0, not_prime     # 如果 temp == 0，n 能被 i 整除，非素数
    addi $29, $0, 0
    j    mod_loop
    addi $29, $0, 0

next_i:
    # i += 1
    addi $5, $5, 1
    j    check_loop
    addi $29, $0, 0

is_prime:
    # 将结果 1（素数）存入 RAM[1]
    addi $11, $0, 4            # 偏移量 = 1 * 4 字节
    add  $11, $1, $11          # $11 = RAM[1] 的地址
    addi $12, $0, 1            # $12 = 1
    sw   $12, 0($11)           # RAM[1] = 1
    j    display_result
    addi $29, $0, 0

not_prime:
    # 将结果 0（非素数）存入 RAM[1]
    addi $11, $0, 4            # 偏移量 = 1 * 4 字节
    add  $11, $1, $11          # $11 = RAM[1] 的地址
    addi $12, $0, 0            # $12 = 0
    sw   $12, 0($11)           # RAM[1] = 0
    j    display_result
    addi $29, $0, 0

display:
    sw $2, 0x0($1)
    sw $2, 0x20($1)
    j main

display_result:
    sw $2, 0x0($1)
    sw $12, 0x20($3)
    j main

end_program:
    # 程序结束
    nop