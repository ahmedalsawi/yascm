`timescale 1ns/1ns

module yascm
#(
    parameter BOOT_ADDR = 32'd0
)
(
    // input  clk,
    // input  rst
);

// TODO remove this
reg clk;
reg rst;


initial begin
    clk = 0;
    forever clk = #5 ~clk;
end
initial begin
rst <=1;
repeat(1) @(posedge clk);
rst <= 0;
end
initial begin
    #1000;
    $finish();
end

/*
  _____    _       _     
 |  ___|__| |_ ___| |__  
 | |_ / _ \ __/ __| '_ \ 
 |  _|  __/ || (__| | | |
 |_|  \___|\__\___|_| |_|
*/
reg [31:0] pc;

wire [31:0] instr;

rom instr_rom  (
    .addr(pc),
    .data_o(instr)
);

always @(posedge clk) begin
    if(rst)
        pc <= BOOT_ADDR;
    else
        pc <= pc + 4;
end

// Testing -- TODO: cleaner testbench
initial
    $readmemh("prog.hex", instr_rom.mem);
initial begin
$dumpfile ("yascm.vcd"); // Change filename as appropriate. 
$dumpvars(0, yascm); 
end



/*
  ____                     _      
 |  _ \  ___  ___ ___   __| | ___ 
 | | | |/ _ \/ __/ _ \ / _` |/ _ \
 | |_| |  __/ (_| (_) | (_| |  __/
 |____/ \___|\___\___/ \__,_|\___|
*/
reg [5:0] op;
reg [4:0] rt,rs,rd;
reg [4:0] shamt;
reg [5:0] funct;
reg [15:0] immediate;
reg [25:0] address;

always @(instr) begin

    op = instr[31-:6];
    $display("instr=%x op=%b",instr, op);
    case(op)
    6'd0 : {rs,rt,rd,shamt,funct}   <= instr[25:0]; // R-format
    6'd35: {rs,rt,immediate}        <= instr[25:0]; // I-format lw
    6'd43: {rs,rt,immediate}        <= instr[25:0]; // I-format sw
    6'd4 : {rs,rt,immediate}        <= instr[25:0]; // I-format beq
    6'd2 : {address}                <= instr[25:0]; // J-format j
    default: 
        $display("Error:%s(%0d): Invalid op %x",`__FILE__,`__LINE__,op);
    endcase
end

// Register file
wire [31:0] regA, regB, regC;
wire [4:0] regA_addr, regB_addr, regC_addr;
reg regfile_wen;

assign regC = write_back;
assign regC_addr = rd;
assign regA_addr = rs;
assign regB_addr = rt;

regfile u_regfile(
    .regA(regA),
    .regA_addr(regA_addr),
    .regB(regB),
    .regB_addr(regB_addr),
    .regC(regC),
    .regC_addr(regC_addr),
    .clk(clk),
    .wen(regfile_wen)
);

// Control
always @(op)begin
    case(op)
        6'd0 : begin
            wb_sel      <= 0;
            regfile_wen <= 1;
        end
        default: begin
            $display("Error:%s(%0d):%0t: Invalid op %x",`__FILE__,`__LINE__,$time,op);
            wb_sel <= 1'bx;
            regfile_wen <=1'bx;
        end
    endcase
end


/*
  _____                     _       
 | ____|_  _____  ___ _   _| |_ ___ 
 |  _| \ \/ / _ \/ __| | | | __/ _ \
 | |___ >  <  __/ (__| |_| | ||  __/
 |_____/_/\_\___|\___|\__,_|\__\___|
*/

wire [3:0] alu_op=0;
wire [31:0] alu_portA, alu_portB,alu_result;
wire zero;

assign alu_portA = regA;
assign alu_portB = regB;
assign alu_op = 0;

alu u_alu(
    .A(alu_portA),
    .B(alu_portB),
    .op(alu_op),
    .result(alu_result),
    .zero(zero)
);

/*
  __  __                                 
 |  \/  | ___ _ __ ___   ___  _ __ _   _ 
 | |\/| |/ _ \ '_ ` _ \ / _ \| '__| | | |
 | |  | |  __/ | | | | | (_) | |  | |_| |
 |_|  |_|\___|_| |_| |_|\___/|_|   \__, |
                                   |___/ 
*/

wire [31:0] data_mem_addr, data_mem_data_i, data_mem_data_o;
wire data_mem_wen;

mem data_mem (
    .clk(clk),
    .wen(data_mem_wen),
    .data_i(data_mem_data_i),
    .addr(data_mem_addr),
    .data_o(data_mem_data_o)
);

/*
 __        __    _ _             _                _    
 \ \      / / __(_) |_ ___      | |__   __ _  ___| | __
  \ \ /\ / / '__| | __/ _ \_____| '_ \ / _` |/ __| |/ /
   \ V  V /| |  | | ||  __/_____| |_) | (_| | (__|   < 
    \_/\_/ |_|  |_|\__\___|     |_.__/ \__,_|\___|_|\_\
*/

wire [31:0] write_back;
reg wb_sel;
// assign write_back = wb_sel? data_mem_data_o : alu_result;
assign write_back = alu_result;
endmodule


