`timescale 1ns/ps

module execution_unit_tb();
    reg clk;
    reg reset;
    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [31:0] PC;
    reg [31:0] imm;
    reg [4:0] rd;
    reg ALU_src;
    reg branch;
    reg RegWrite;
    reg MemRead;
    reg MemWrite;
    reg MemtoReg;
    reg [3:0] ALU_op;

    wire [31:0] ALU_result;
    wire [31:0] rs2_output;
    wire [31:0] branch_PC;
    wire [4:0] rd_output;
    wire RegWrite_output;
    wire MemRead_output;
    wire MemWrite_output;
    wire MemtoReg_output;
    wire branch_taken;

    execution_unit dut (
        .clk(clk),
        .reset(reset),
        .ID_EX_rs1(rs1),
        .ID_EX_rs2(rs2),
        .ID_EX_PC(PC),
        .ID_EX_imm(imm),
        .ID_EX_rd(rd),
        .ID_EX_ALU_src(ALU_src),
        .ID_EX_branch(branch),
        .ID_EX_RegWrite(RegWrite),
        .ID_EX_MemRead(MemRead),
        .ID_EX_MemWrite(MemWrite),
        .ID_EX_MemtoReg(MemtoReg),
        .ID_EX_ALU_op(ALU_op),
        .EX_ME_ALU_result(ALU_result),
        .EX_ME_rs2(rs2_output),
        .EX_ME_branch_PC(branch_PC),
        .EX_ME_rd(rd_output),
        .EX_ME_RegWrite(RegWrite_output),
        .EX_ME_MemRead(MemRead_output),
        .EX_ME_MemWrite(MemWrite_output),
        .EX_ME_MemtoReg(MemtoReg_output),
        .EX_ME_branch_taken(branch_taken)
    );

    initial begin  
        $dumpfile("execution_unit_tb.vcd");
        $dumpvars(0, execution_unit_tb);

        clk = 0;
        reset = 0;
        rs1 = 32'd10;
        rs2 = 32'd5;
        imm = 32'd20;
        PC = 32'd100;
        rd = 5'd1;
        ALU_src = 0;
        branch = 1;
        ALU_op = 4'b0000;
        RegWrite = 1;
        MemRead = 0;
        MemWrite = 0;
        MemtoReg = 0;

        #10 ALU_op = 4'b0000; //ADD
        #10 ALU_op = 4'b0001; //SUB
        #10 ALU_op = 4'b1010; //LUI
        #10 ALU_op = 4'b1011; //AUIPC
        #10 ALU_op = 4'b1100; //JAL
        #10 ALU_op = 4'b1101; //JALR
        #10
        $finish
    end
    always #5 clk = ~clk; //(5 cycles low, 5 cycles high) -> 100 MHz clock
endmodule