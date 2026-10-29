module alu_control (
    input [1:0] alu_op,       // From main control (e.g., 00=Load/Store, 01=Branch, 10=R-type)
    input [5:0] funct,        // Function field from instruction [5:0]
    output reg [3:0] control // {Ainvert, Binvert, Op[1:0]}
);

    // MIPS funct field constants for R-type instructions
    localparam [5:0]
        ADD = 6'b100000,
        SUB = 6'b100010,
        AND = 6'b100100,
        OR  = 6'b100101,
        SLT = 6'b101010;

    always @(*) begin
        // Default values
        control = 4'b0000;

        case (alu_op)
            2'b00: begin // Load / Store (Needs Add)
                control = 4'b0010; // Add
            end
            
            2'b01: begin // Branch (Needs Subtract for comparison)
                control = 4'b0110; // Sub
            end
            
            2'b10: begin // R-type instruction (Look at funct field)
                case (funct)
                    ADD: begin
                        control = 4'b0010; // Add
                    end
                    SUB: begin
                        control = 4'b0110; // Sub
                    end
                    AND: begin
                        control = 4'b0000; // AND
                    end
                    OR: begin
                        control = 4'b0001; // OR
                    end
                    SLT: begin
                        control = 4'b0111; // SLT
                    end
                    default: begin
                        control = 4'b0000;
                    end
                endcase
            end
            
            default: begin
                control = 4'b0000;
            end
        endcase
    end

endmodule
