module CPU(
    input clk,
    output [3:0] seg_an,
    output [7:0] seg_cat
    );
    wire clk_out;
    clock_divider cd1(.clk(clk), .clk_out(clk_out));

    //Program Counter
    reg [31:0] PC;
    initial begin
        PC = 32'h00000000;
    end

    wire [31:0] PCadd4;
    reg [31:0] PC_next;
    //Part 1, lets just increment through the instruction memory
    alu_32bit a32b1(.a(PC), .b(32'h00000004), .control(4'b0010), .result(PCadd4), .c_out(), .overflow(), .zero());

    //update PC
    always @(posedge clk_out) begin
        PC <= PC_next;
    end

    wire sig_end; //dummy variable
    wire [31:0] currInst; //very important variable
    instMEM iM1(.clk(clk_out), .PC(PC), .currInst(currInst), .prog_end(sig_end)); //access instruction memory



    //part 2 lets access the register file, main control unit and ALU
    //main control unit
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    wire [1:0] ALUOp;
    control c1(.inst(currInst[31:26]), .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite), 
    .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .ALUOp(ALUOp));

    //alu control unit
    wire [3:0] bit4aluControl;
    alu_control ac1(.alu_op(ALUOp), .funct(currInst[5:0]), .control(bit4aluControl));

    //register file
    wire [31:0] dt1, dt2; 
    reg [31:0] dt_wr;
    //mux, should RD_reg2 also go to wr_reg?
    reg [4:0] wr_reg_mux;
    always @(*) begin
        if(RegDst) wr_reg_mux = currInst[15:11];
        else wr_reg_mux = currInst[20:16];
    end

    regFILE rF1(.clk(clk_out), .RD_reg1(currInst[25:21]), .RD_reg2(currInst[20:16]), .WR_reg(wr_reg_mux), 
    .RD_reg1_dt(dt1), .RD_reg2_dt(dt2), .WR_reg_dt(dt_wr), .WR_controlSig(RegWrite));

    reg [31:0] dt2_mux;
    always @(*) begin
        if(!ALUSrc) dt2_mux = dt2; //mux
        else dt2_mux = {{16{currInst[15]}}, currInst[15:0]}; //important for I-type instructions
    end

    //perform ALU calculation
    wire [31:0] ALU_result;
    wire zero;
    alu_32bit a32b2(.a(dt1), .b(dt2_mux), .control(bit4aluControl), .result(ALU_result), .c_out(), .overflow(),.zero(zero));

    //part 3 lets access data memory and write data back to the register file
    wire [31:0] dataMem_rd;
    wire [31:0] prog_result;
    dataMEM dM1(.clk(clk_out), .addr(ALU_result), .WR_dt(dt2), .RD_dt(dataMem_rd), .MemWrite(MemWrite), .MemRead(MemRead), 
    .result(prog_result));

    //mux, access regiter file with either dt2 or data red from data mem
    always @(*) begin
        if(MemtoReg) dt_wr = dataMem_rd;
        else dt_wr = ALU_result;
    end

    //part 4, to allow for branch instruction, lets allow for a different increment to the PC
    //operand b is shift by 2 verison fo sign extended offset, I type instruction
    wire [31:0] PCbranch;
    alu_32bit a32b3(.a(PCadd4), .b({{16{currInst[15]}}, currInst[15:0]} << 2), .control(4'b0010), .result(PCbranch), .c_out(), .overflow(), .zero());
    

    
    //mux, either increase PC by 4 or perform branch
    wire BranchAndZero = (Branch & zero); //technically part of control
    
    always @(*) begin
        if(!BranchAndZero) PC_next = PCadd4;
        else PC_next = PCbranch;
    end

    //result is in address 12
    seg7_driver s7d1(.clk(clk), .rst(1'b0), .seg_an(seg_an), .seg_cat(seg_cat), .num(prog_result));

    /*
    Multiplication algorithm (program.mem):
        8C010000
        8C020004
        8C040008
        00631822
        10400003
        00611820
        00441022
        1000FFFC
        AC03000C
    */

endmodule
