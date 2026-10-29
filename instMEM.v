module instMEM (
    input clk,
    input [31:0] PC,
    output [31:0] currInst,
    output reg prog_end          
);
    reg [31:0] inst_mem [0:255];

    initial begin
        $readmemh("program.mem", inst_mem);
    end

    // Read instruction
    assign currInst = inst_mem[PC[9:2]];

    // Program completion flag 
    always @(*) begin
        if (PC[9:2] == 8'd255) 
            prog_end = 1'b1;
        else 
            prog_end = 1'b0;
    end

endmodule
