/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

module writeback_unit (
    input   wire        clk,
    input   wire        reset,

    input   wire        [31:0] ME_WB_data,
    input   wire        [31:0] ME_WB_ALU_result,
    input   wire        [4:0] ME_WB_rd,
    input   wire        ME_WB_RegWrite,
    input   wire        ME_WB_MemtoReg,

    output  wire        [31:0] WB_rd_data,
    output  wire        [4:0] WB_rd_addr,
    output  wire        WB_RegWrite

);

    assign WB_rd_data = (ME_WB_MemtoReg) ? ME_WB_data : ME_WB_ALU_result;
    assign WB_rd_addr = ME_WB_rd;
    assign WB_RegWrite = ME_WB_RegWrite;
    
endmodule