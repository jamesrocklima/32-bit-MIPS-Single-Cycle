module dataMEM(
    input clk,
    input [31:0] addr,
    input [31:0] WR_dt,
    output [31:0] RD_dt,
    input MemWrite,
    input MemRead,
    output [31:0] result
);

    reg [31:0] data_mem [511:0];

    assign RD_dt = (MemRead) ? data_mem[addr[11:2]] : 32'b0;

    always @(posedge clk) begin
        
        if(MemWrite) data_mem[addr[11:2]] <= WR_dt;
    end

    assign result = data_mem[12 / 4];

    //initialize for multiplication algorithm
    initial begin
        data_mem[0] = 47;
        data_mem[1] = 68;
        data_mem[2] = 1;
        data_mem[3] = 0;
    end
    
endmodule
