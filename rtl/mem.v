module mem #(
    parameter WORDSIZE=32,
    parameter SIZE = 1024 * 1024
)(

    input wire clk,
    input wire wen,
    input wire [31:0] addr,
    input wire [WORDSIZE-1:0] data_i,
    output wire [WORDSIZE-1:0] data_o
);

reg [WORDSIZE-1:0] mem [SIZE-1:0];

// Memory is byte-addressable but 
// address is aligned to 4 bytes
assign data_o = mem[addr[31:2]];

always @(posedge clk) begin
    if(wen) begin
        mem[addr[31:2]] <= data_i;
    end
end

endmodule