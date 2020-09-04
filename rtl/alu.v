module alu #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input [3:0] op,
    output reg [WIDTH-1:0] result,
    output zero
);
always @(*)
    case (op)
        4'b0000: result = A + B;
    endcase
endmodule