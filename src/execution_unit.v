/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

module execution_unit (
    input   wire       clk,      // clock
    input   wire       reset,    // reset

    //From ID
    input   wire    [31:0]  ID_EX_rs1,
    input   wire    [31:0]  ID_EX_rs2,
    input   wire    [31:0]  ID_EX_imm,
    input   wire    [4:0]   ID_EX_rd,
    input   wire    [31:0]  ID_EX_PC,
    
    input   wire    ID_EX_ALU_src,
    input   wire    ID_EX_Branch,
    input   wire    [3:0] ID_EX_ALU_op,
    input   wire    ID_EX_RegWrite,
    input   wire    ID_EX_MemRead,
    input   wire    ID_EX_MemWrite,
    input   wire    ID_EX_MemtoReg,

    //To ME
    output  reg     [31:0] EX_ME_ALU_result,
    output  reg     [31:0] EX_ME_rs2,
    output  reg     [4:0]  EX_ME_rd,
    output  reg     EX_ME_RegWrite,
    output  reg     EX_ME_MemRead,
    output  reg     EX_ME_MemWrite,
    output  reg     EX_ME_MemtoReg,

    //To IF and ID
    output  reg     [31:0] EX_ME_branch_PC,
    output  reg     EX_ME_branch_taken 
);

    wire [31:0] operand_B = (ID_EX_ALU_src) ? ID_EX_imm : ID_EX_rs2;

    wire    alu_zero;
    wire    [31:0] alu_result;

ALU alu_unit (
    .A(ID_EX_rs1),
    .B(operand_B),
    .ALU_control(ID_EX_ALU_op),
    .PC(ID_EX_PC)
    .result(alu_result),
    .zero(alu_zero)
);

    always @(*) begin
        EX_ME_branch_taken = 1'b0;
        EX_ME_branch_PC = 32'd0;

        if (ID_EX_Branch) begin
            if (alu_zero) begin
            EX_ME_branch_taken = 1'b1;
            EX_ME_branch_PC = ID_EX_PC + ID_EX_imm;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_ME_ALU_result <= 32'b0;
            EX_ME_rs2 <= 32'b0;
            EX_ME_rd <= 5'b0;
            EX_ME_RegWrite <= 1'b0;
            EX_ME_MemRead <= 1'b0;
            EX_ME_MemWrite <= 1'b0;
            EX_ME_MemtoReg <= 1'b0;
        end else begin
            EX_ME_ALU_result <= alu_result;
            EX_ME_rs2 <= ID_EX_rs2;
            EX_ME_rd <= ID_EX_rd;
            EX_ME_RegWrite <= ID_EX_RegWrite;
            EX_ME_MemRead <= ID_EX_MemRead;
            EX_ME_MemWrite <= ID_EX_MemWrite;
            EX_ME_MemtoReg <= ID_EX_MemtoReg;
        end
    end 
endmodule