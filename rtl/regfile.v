module regfile (

output wire [31:0] regA,
input wire [4:0] regA_addr,

output wire [31:0] regB,
input wire [4:0] regB_addr,

input wire [31:0] regC,
input wire [4:0] regC_addr,
input wire clk,
input wire wen
);

    reg [31:0] mem[31:0];

    assign regA = regA_addr==0? 0 : mem[regA_addr];
    assign regB = regB_addr==0? 0 : mem[regB_addr];

    always @(clk) begin
        if (wen) begin
            mem[regC_addr]  = regC;
            $display("Info: write to reg=%d data=%x",regC_addr,regC);
        end
    end
endmodule