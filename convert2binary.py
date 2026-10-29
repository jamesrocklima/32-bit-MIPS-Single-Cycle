def assemble_instruction(line):
    # Clean up formatting
    parts = line.replace(",", "").replace("(", " ").replace(")", "").split()
    if not parts or parts[0].startswith("#"):
        return None
    
    op = parts[0]
    
    # --- R-TYPE INSTRUCTIONS (add, sub, and, or, slt) ---
    # Format: op $rd, $rs, $rt -> opcode(6) | rs(5) | rt(5) | rd(5) | shamt(5) | funct(6)
    if op in ["add", "sub", "and", "or", "slt"]:
        rd, rs, rt = int(parts[1][1:]), int(parts[2][1:]), int(parts[3][1:])
        opcode = 0x00
        
        funct_map = {
            "add": 0x20, # 100000
            "sub": 0x22, # 100010
            "and": 0x24, # 100100
            "or":  0x25, # 100101
            "slt": 0x2A  # 101010
        }
        funct = funct_map[op]
        machine_code = (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (0 << 6) | funct
        return f"{machine_code:08X}"

    # --- I-TYPE LOAD/STORE (lw, sw) ---
    # Format: lw/sw $rt, offset($rs) -> opcode(6) | rs(5) | rt(5) | imm(16)
    elif op in ["lw", "sw"]:
        rt, imm, rs = int(parts[1][1:]), int(parts[2]), int(parts[3][1:])
        opcode_map = {
            "lw": 0x23, # 100011
            "sw": 0x2B  # 101011
        }
        opcode = opcode_map[op]
        machine_code = (opcode << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)
        return f"{machine_code:08X}"

    # --- I-TYPE BRANCH (beq) ---
    # Format: beq $rs, $rt, offset -> opcode(6) | rs(5) | rt(5) | imm(16)
    elif op == "beq":
        rs, rt, imm = int(parts[1][1:]), int(parts[2][1:]), int(parts[3])
        opcode = 0x4  # 000100
        machine_code = (opcode << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)
        return f"{machine_code:08X}"

    return None

# --- Example Test Program ---
assembly_code = [
    #Initialize registers
    "lw  $1, 0($0)",    # $1 ($t1) = 47 (Loaded from Data Memory address 0)
    "lw  $2, 4($0)",    # $2 ($t2) = 68 (Loaded from Data Memory address 4)
    "lw  $4, 8($0)",    # $4 = 1        (Loaded from Data Memory address 8, used to decrement)
    "add $3, $0, $0",   # $3 = 0   set reg3 to 0     
    # --- LOOP START ---
    "beq $2, $0, 3",    # If $2 ($t2) == 0, exit loop (branch forward by 3 instructions)
    "add $3, $3, $1",   # Result = Result + 47
    "sub $2, $2, $4",   # Decrement counter ($2 = $2 - 1)
    "beq $0, $0, -4",   # Unconditional jump back to the loop check (branch backward by 3)
    # --- LOOP END ---
    "sw  $3, 12($0)"    # Store final product (3196) into Data Memory address 12
] #remember to initialize data memory with the values needed by the program

print("--- program.mem output ---")
for inst in assembly_code:
    hex_code = assemble_instruction(inst)
    if hex_code:
        print(hex_code)

