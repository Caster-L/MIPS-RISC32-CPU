# mips_assembler.py

import re

instruction_set = {
    # R-type instructions
    'and':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b100100},
    'or':    {'type': 'R', 'opcode': 0b000000, 'funct': 0b100101},
    'xor':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b100110},
    'nor':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b100111},
    'sll':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b000000},
    'sllv':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b000100},
    'srl':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b000010},
    'srlv':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b000110},
    'sra':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b000011},
    'srav':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b000111},
    'sync':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b001111},
    'pref':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b110011},
    'nop':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b000000},
    'movz':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b001010},
    'movn':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b001011},
    'mfhi':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b010000},
    'mthi':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b010001},
    'mflo':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b010010},
    'mtlo':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b010011},
    'slt':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b101010},
    'sltu':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b101011},
    'add':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b100000},
    'addu':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b100001},
    'sub':   {'type': 'R', 'opcode': 0b000000, 'funct': 0b100010},
    'subu':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b100011},
    'clz':   {'type': 'R', 'opcode': 0b011100, 'funct': 0b100000},
    'clo':   {'type': 'R', 'opcode': 0b011100, 'funct': 0b100001},
    'mult':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b011000},
    'multu': {'type': 'R', 'opcode': 0b000000, 'funct': 0b011001},
    'mul':   {'type': 'R', 'opcode': 0b011100, 'funct': 0b000010},
    'jalr':  {'type': 'R', 'opcode': 0b000000, 'funct': 0b001001},
    'jr':    {'type': 'R', 'opcode': 0b000000, 'funct': 0b001000},

    # I-type instructions
    'andi':  {'type': 'I', 'opcode': 0b001100},
    'ori':   {'type': 'I', 'opcode': 0b001101},
    'xori':  {'type': 'I', 'opcode': 0b001110},
    'lui':   {'type': 'I', 'opcode': 0b001111},
    'slti':  {'type': 'I', 'opcode': 0b001010},
    'sltiu': {'type': 'I', 'opcode': 0b001011},
    'addi':  {'type': 'I', 'opcode': 0b001000},
    'addiu': {'type': 'I', 'opcode': 0b001001},
    'beq':   {'type': 'I', 'opcode': 0b000100},
    'bne':   {'type': 'I', 'opcode': 0b000101},
    'bgtz':  {'type': 'I', 'opcode': 0b000111},
    'blez':  {'type': 'I', 'opcode': 0b000110},
    'lb':    {'type': 'I', 'opcode': 0b100000},
    'lbu':   {'type': 'I', 'opcode': 0b100100},
    'lh':    {'type': 'I', 'opcode': 0b100001},
    'lhu':   {'type': 'I', 'opcode': 0b100101},
    'lw':    {'type': 'I', 'opcode': 0b100011},
    'sb':    {'type': 'I', 'opcode': 0b101000},
    'sh':    {'type': 'I', 'opcode': 0b101001},
    'sw':    {'type': 'I', 'opcode': 0b101011},

    # J-type instructions
    'j':     {'type': 'J', 'opcode': 0b000010},
    'jal':   {'type': 'J', 'opcode': 0b000011},
}

registers = {
    '$zero': 0,
    '$0': 0,
    '$1': 1,
    '$2': 2,
    '$3': 3,
    '$4': 4,
    '$5': 5,
    '$6': 6,
    '$7': 7,
    '$8': 8,
    '$9': 9,
    '$10': 10,
    '$11': 11,
    '$12': 12,
    '$13': 13,
    '$14': 14,
    '$15': 15,
    '$16': 16,
    '$17': 17,
    '$18': 18,
    '$19': 19,
    '$20': 20,
    '$21': 21,
    '$22': 22,
    '$23': 23,
    '$24': 24,
    '$25': 25,
    '$26': 26,
    '$27': 27,
    '$28': 28,
    '$29': 29,
    '$30': 30,
    '$31': 31,
    '$at': 1,
    '$v0': 2,
    '$v1': 3,
    '$a0': 4,
    '$a1': 5,
    '$a2': 6,
    '$a3': 7,
    '$t0': 8,
    '$t1': 9,
    '$t2': 10,
    '$t3': 11,
    '$t4': 12,
    '$t5': 13,
    '$t6': 14,
    '$t7': 15,
    '$s0': 16,
    '$s1': 17,
    '$s2': 18,
    '$s3': 19,
    '$s4': 20,
    '$s5': 21,
    '$s6': 22,
    '$s7': 23,
    '$t8': 24,
    '$t9': 25,
    '$k0': 26,
    '$k1': 27,
    '$gp': 28,
    '$sp': 29,
    '$fp': 30,
    '$ra': 31,
}

def parse_register(reg):
    reg = reg.strip()
    if reg in registers:
        return registers[reg]
    else:
        raise ValueError(f"未知寄存器 {reg}")

def assemble_file(input_file, output_file):
    # 第一遍：解析标签，建立标签与地址的映射
    labels = {}
    instructions = []
    with open(input_file, 'r') as f_in:
        addr = 0
        for line in f_in:
            line = line.split('#')[0].strip()
            if not line:
                continue
            if ':' in line:
                # 存在标签
                label, rest = line.split(':', 1)
                label = label.strip()
                labels[label] = addr
                line = rest.strip()
                if not line:
                    continue
            instructions.append(line)
            addr += 1  # 假设每条指令占用 1 单位地址

    # 第二遍：解析指令，生成机器码
    with open(output_file, 'w') as f_out:
        addr = 0
        for line in instructions:
            try:
                machine_code = assemble_instruction(line, labels, addr)
                if machine_code:
                    f_out.write(machine_code + '\n')
                addr +=1
            except ValueError as e:
                print(f"错误：'{line.strip()}': {e}")

def assemble_instruction(line, labels, addr):
    tokens = line.replace(',', ' ').split()
    if not tokens:
        return None
    op = tokens[0]
    if op in labels:
        tokens = tokens[1:]
        op = tokens[0]
    if op not in instruction_set:
        raise ValueError(f"不支持的指令 {op}")
    instr = instruction_set[op]
    opcode = instr['opcode']
    if instr['type'] == 'R':
        # R 型指令处理
        funct = instr['funct']
        shamt = 0
        if op in ['sll', 'srl', 'sra']:
            rd = parse_register(tokens[1])
            rt = parse_register(tokens[2])
            shamt = int(tokens[3], 0) & 0x1F
            rs = 0
        elif op in ['jr']:
            rs = parse_register(tokens[1])
            rt = 0
            rd = 0
        elif op in ['mfhi', 'mflo']:
            rd = parse_register(tokens[1])
            rs = 0
            rt = 0
        elif op in ['mthi', 'mtlo']:
            rs = parse_register(tokens[1])
            rt = 0
            rd = 0
        elif op in ['nop']:
            rs = rt = rd = shamt = funct = 0
        else:
            rd = parse_register(tokens[1])
            rs = parse_register(tokens[2])
            rt = parse_register(tokens[3])
        machine_code = (opcode << 26) | (rs << 21) | (rt << 16) | \
                       (rd << 11) | (shamt << 6) | funct
    elif instr['type'] == 'I':
        rt = parse_register(tokens[1])
        if op in ['lui']:
            immediate = int(tokens[2], 0) & 0xFFFF
            rs = 0
        elif op in ['beq', 'bne']:
            rs = parse_register(tokens[1])
            rt = parse_register(tokens[2])
            label = tokens[3]
            if label in labels:
                offset = labels[label] - (addr +1)
                immediate = offset & 0xFFFF
            else:
                raise ValueError(f"未知的标签 {label}")
        elif op in ['blez', 'bgtz']:
            rs = parse_register(tokens[1])
            rt = 0
            label = tokens[2]
            if label in labels:
                offset = labels[label] - (addr +1)
                immediate = offset & 0xFFFF
            else:
                raise ValueError(f"未知的标签 {label}")
        elif op in ['addi', 'addiu', 'andi', 'ori', 'xori', 'slti', 'sltiu']:
            rs = parse_register(tokens[2])
            immediate = int(tokens[3], 0) & 0xFFFF
        elif op in ['lb', 'lbu', 'lh', 'lhu', 'lw', 'sb', 'sh', 'sw']:
            # 内存访问指令
            mem = tokens[2]
            match = re.match(r'(-?(?:0x)?[0-9a-fA-F]+)\((\$[a-zA-Z0-9]+)\)', mem)
            if match:
                immediate_str = match.group(1)
                immediate = int(immediate_str, 0) & 0xFFFF
                rs = parse_register(match.group(2))
            else:
                raise ValueError(f"地址格式错误 {tokens[2]}")
        else:
            rs = parse_register(tokens[2])
            immediate = int(tokens[3], 0) & 0xFFFF
        machine_code = (opcode << 26) | (rs << 21) | (rt << 16) | immediate
    elif instr['type'] == 'J':
        label = tokens[1]
        if label in labels:
            address = labels[label] & 0x3FFFFFF
        else:
            raise ValueError(f"未知的标签 {label}")
        machine_code = (opcode << 26) | address
    else:
        raise ValueError(f"不支持的指令类型 {instr['type']}")
    return f"{machine_code:08x}"

if __name__ == '__main__':
    input_file = 'input.asm'   # 输入文件名
    output_file = 'output.txt' # 输出文件名
    assemble_file(input_file, output_file)