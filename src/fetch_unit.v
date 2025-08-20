/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

 module fetch_unit (
    input   wire       clk,         // clock
    input   wire       reset,       // reset_n - low to reset

    //Pipeline control 
    input   wire IF_stall,          //from hazard/stall logic
    input   wire IF_flush,          //from EX on taken branch/jump
    input   wire [31:0] branch_PC,  //new PC on taken branch/jump

    //External Memory
    input   wire [31:0] instr,      //instruction from DMA
    input   wire instr_ready,       //indicates valid instruction from DMA
    output  reg [31:0] instr_addr,  //address to fetch instruction in SRAM
    output  reg instr_req,          //request bit to read SRAM

    //Pipeline Registers
    output  reg [31:0] PC,          //Holds current program counter (live PC)
    output  reg [31:0] IF_ID_PC,    //PC latch for IF/ID registers
    output  reg [31:0] IF_ID_instr, //instruction latch for IF/ID registers
    output  reg IF_Valid            //Indicates valid instruction for IF/ID registers
     
);

//PC Register Management
always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= 32'h0000_0000;
        instr_req <= 1'b0;
    end else if (!IF_stall) begin
        if (IF_flush) begin
            PC <= branch_PC;
            instr_req <= 1'b1;
        end else begin
            PC <= PC + 32'd4;
            instr_req <= 1'b1;
        end
    end
end

//Instruction Memory Address Update
always @(*) begin
    instr_addr = PC;
end

//Instruction and PC Update
always @(posedge clk or posedge reset) begin
    if (reset || IF_flush) begin
        IF_ID_instr <= 32'b0;
        IF_ID_PC <= 32'b0;
        IF_Valid <= 1'b0;
    end else if (instr_ready && !IF_stall) begin
        IF_ID_instr <= instr;
        IF_ID_PC <= PC;
        IF_Valid <= 1'b1;
    end else if (!IF_stall) begin
        IF_Valid <= 1'b0;
    end
end

endmodule


