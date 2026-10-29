module control(
    input [31:26] inst,
    output reg RegDst,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg [1:0] ALUOp
    );


    always @(*) begin
    // Default values to prevent unintended latches
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;


    case(inst)
        6'b000000: //R-format
        begin
            RegDst = 1'b1;
            RegWrite = 1'b1;
            ALUOp = 2'b10;
        end
        6'b100011: //lw
        begin 
            ALUSrc = 1'b1;
            MemtoReg = 1'b1;
            RegWrite = 1'b1;
            MemRead = 1'b1;
        end

        6'b101011://sw
        begin
            ALUSrc = 1'b1;
            MemWrite = 1'b1;
        end
        6'b000100://beq
        begin
            Branch = 1'b1;
            ALUOp = 2'b01;
        end
    endcase
    end

endmodule
