module seg7_driver(
    input clk, rst,
    input [15:0] num,
    output reg [3:0] seg_an,
    output reg [7:0] seg_cat
    );

    reg [15:0] num_BCD;
    reg [16:0] counter;
    reg [3:0] DigitBCD;

    // --- Binary to BCD Conversion (Double Dabble Algorithm) ---
    integer i;
    always @(*) begin
        // Initialize BCD digits to 0 and scratchpad
        num_BCD = 0;
        // The Double Dabble loop for a 16-bit number:
        // We shift the binary number bit by bit into the BCD registers
        for (i = 15; i >= 0; i = i - 1) begin
            // Check and adjust BCD columns (add 3 if >= 5)
            if (num_BCD[3:0] >= 5)   num_BCD[3:0]   = num_BCD[3:0] + 3;
            if (num_BCD[7:4] >= 5)   num_BCD[7:4]   = num_BCD[7:4] + 3;
            if (num_BCD[11:8] >= 5)  num_BCD[11:8]  = num_BCD[11:8] + 3;
            if (num_BCD[15:12] >= 5) num_BCD[15:12] = num_BCD[15:12] + 3;
            
            // Shift left by 1 (bringing in the next bit of 'num')
            num_BCD = {num_BCD[14:0], num[i]};
        end
    end

    // --- Refresh Counter ---
    always @(posedge clk or posedge rst) begin
        if(rst) counter <= 0;
        else counter <= counter + 1'b1;
    end

    // --- Digit Multiplexer ---
    always @(*) begin
        case(counter[16:15])
            2'b00: begin 
                seg_an   = 4'b1110;
                DigitBCD = num_BCD[3:0];   // Ones place
            end
            2'b01: begin 
                seg_an   = 4'b1101;
                DigitBCD = num_BCD[7:4];   // Tens place
            end
            2'b10: begin 
                seg_an   = 4'b1011;
                DigitBCD = num_BCD[11:8];  // Hundreds place
            end
            2'b11: begin 
                seg_an   = 4'b0111;
                DigitBCD = num_BCD[15:12]; // Thousands place
            end
            default: begin
                seg_an   = 4'b1111;
                DigitBCD = 4'b0000;
            end
        endcase
    end

    // --- 7-Segment Decoder (Cathode Driver) ---
    always @(*) begin
        case(DigitBCD) 
            4'd0: seg_cat = 8'b11000000;
            4'd1: seg_cat = 8'b11111001;
            4'd2: seg_cat = 8'b10100100;
            4'd3: seg_cat = 8'b10110000;
            4'd4: seg_cat = 8'b10011001;
            4'd5: seg_cat = 8'b10010010;
            4'd6: seg_cat = 8'b10000010;
            4'd7: seg_cat = 8'b11111000;
            4'd8: seg_cat = 8'b10000000;
            4'd9: seg_cat = 8'b10010000;
            default: seg_cat = 8'b11111111; // Fixed missing bit (was 7 bits)
        endcase
    end

endmodule
