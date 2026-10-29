module regFILE(
    input clk,
    input [4:0] RD_reg1,
    input [4:0] RD_reg2,
    input [4:0] WR_reg,
    output [31:0] RD_reg1_dt,
    output [31:0] RD_reg2_dt,
    input [31:0] WR_reg_dt,
    input WR_controlSig
);

    reg [31:0] reg_file [31:0];

    assign RD_reg1_dt = (RD_reg1 == 0) ? 0 : reg_file[RD_reg1];
    assign RD_reg2_dt = (RD_reg2 == 0) ? 0 : reg_file[RD_reg2];

    always @(posedge clk) begin
        if(WR_controlSig && (WR_reg != 0)) reg_file[WR_reg] <= WR_reg_dt;
    end
        
endmodule
