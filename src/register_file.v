/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

module register_file (
    input   wire        clk,
    input   wire        reset,

    input   wire [4:0]  rs1_addr,
    input   wire [4:0]  rs2_addr,
    output  wire [31:0] rs1_data,
    output  wire [31:0] rs2_data,

    input   wire        RegWrite,
    input   wire [4:0]  rd_addr,
    input   wire [31:0] rd_data
);

    reg [31:0] regs[31:0];
    integer i;

    //Either reset or write logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i+1) 
                regs[i] <= 32'b0;
        end else if (RegWrite && rd_addr != 5'b0) begin
            regs[rd_addr] <= rd_data;
        end
    end

    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : regs[rs2_addr];

endmodule