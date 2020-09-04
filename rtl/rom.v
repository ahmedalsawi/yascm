module rom #(
    parameter WORDSIZE=32,
    parameter SIZE = 1024 * 1024
)(
    input wire [31:0] addr,
    output wire [WORDSIZE-1:0] data_o
);

    reg [WORDSIZE-1:0] mem [SIZE-1:0];

    // Memory is byte-addressable but 
    // address is aligned to 4 bytes
    assign data_o = mem[addr[31:2]];
endmodule