/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

 module branch_unit (
    input   wire    clk,      // clock
    input   wire    reset, 

    input   wire    EX_ME_branch_taken,
    input   wire    [31:0]EX_ME_branch_PC,

    output  reg     IF_flush,
    output  reg     ID_flush,
    output  reg     [31:0] new_PC
 );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_flush <= 1'b0;
            ID_flush <= 1'b0;
            new_PC <= 32'b0;
        end else begin
            IF_flush <= EX_ME_branch_taken;
            ID_flush <= EX_ME_branch_taken;
            if (EX_ME_branch_taken) new_PC <= EX_ME_branch_PC;
        end
    end
endmodule