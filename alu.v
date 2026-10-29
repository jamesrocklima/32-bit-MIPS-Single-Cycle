module alu_1bit (
    input a,             // 1-bit input A
    input b,             // 1-bit input B
    input c_in,          // Carry In
    input less,          // Input for SLT (used in bit 0)
    input [3:0] control,// Control signals: {Ainvert, Binvert, Op[1:0]}
    output result,       // Final 1-bit result
    output c_out,        // Carry Out
    output overflow,
    output set
);

    // Extract control signals
    wire a_invert = control[3];
    wire b_invert = control[2];
    wire [1:0] op = control[1:0];

    // 1. Operand inversion logic
    wire a_mux = a ^ a_invert;
    wire b_mux = b ^ b_invert;

    // 2. Bitwise operations
    wire and_res = a_mux & b_mux;
    wire or_res  = a_mux | b_mux;

    // 3. Full Adder (handles Add and Sub)
    // For Subtraction, Binvert = 1 and initial c_in for the 0th bit must be 1.
    wire sum_res;
    assign {c_out, sum_res} = a_mux + b_mux + c_in;

    // 4.
    assign overflow = c_in ^ c_out;
    assign set = sum_res ^ overflow;

    // 5. 4-to-1 Multiplexer to select the final result
    reg mux_out;
    always @(*) begin
        case (op)
            2'b00: mux_out = and_res;
            2'b01: mux_out = or_res;
            2'b10: mux_out = sum_res;
            2'b11: mux_out = less;   // Set Less Than
            default: mux_out = 1'b0;
        endcase
    end

    assign result = mux_out;

endmodule

module alu_32bit (
    input [31:0] a,             // 1-bit input A
    input [31:0] b,             // 1-bit input B
    input [3:0] control,// Control signals: {Ainvert, Binvert, Op[1:0]}
    output [31:0]result,       // Final 1-bit result
    output c_out,        // Carry Out
    output overflow,
    output zero
);
    wire [31:0] c;
    wire set;

    alu_1bit a1b0(a[0], b[0], control[2], set, control, result[0], c[0], , ); //cin of LSB is tied to invert b signal for subtraction

    genvar i;
    generate
        for (i = 1; i < 31; i = i + 1) begin : alu_middle_loop
            alu_1bit alu_mid (a[i], b[i], c[i-1], 1'b0, control, result[i], c[i], , );
        end
    endgenerate

    alu_1bit a1b32(a[31], b[31], c[30], 1'b0, control, result[31], c_out, overflow, set);

    assign zero = (result == 0);

endmodule
