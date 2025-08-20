/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

 module hazard_handler (
    input   wire        ID_EX_MemRead,
    input   wire        [4:0] ID_EX_rd,
    input   wire        [4:0] IF_ID_rs1,
    input   wire        [4:0] IF_ID_rs2,
    output  reg         stall_IF,
    output  reg         stall_ID        
 );

    always @(*) begin
        if (ID_EX_MemRead 
            && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) 
            && (ID_EX_rd != 5'b0)) begin
            stall_IF = 1'b1;
            stall_ID = 1'b1;
        end else begin
            stall_IF = 1'b0;
            stall_ID = 1'b0;
        end
    end
endmodule