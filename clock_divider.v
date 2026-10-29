module clock_divider #(
    // Default divisor: For a 100 MHz clock, dividing by 10,000 gives a 100 kHz clock.
    // Adjust this parameter to make it slower or faster!
    parameter integer DIVISOR = 32'd1000
)(
    input wire clk,
    output reg clk_out
);
    initial begin
        clk_out = 1'b0;
    end 
    
    reg [31:0] counter = 32'd0;

    always @(posedge clk) begin
            if (counter >= (DIVISOR / 2) - 1) begin
                counter <= 32'd0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1'b1;
            end
    end

endmodule
