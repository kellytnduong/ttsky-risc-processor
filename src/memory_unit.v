/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

module memory_unit (
    input   wire        clk,
    input   wire        reset,

    //From EX
    input   wire        [31:0] EX_ME_addr,
    input   wire        [31:0] EX_ME_data,
    input   wire        [31:0] EX_ME_ALU_result,
    input   wire        EX_ME_MemRead,
    input   wire        EX_ME_MemWrite,
    input   wire        [4:0] EX_ME_rd,
    input   wire        EX_ME_RegWrite,
    input   wire        EX_MEM_MemtoReg,

    //To WB
    output  reg         [31:0] ME_WB_data,
    output  reg         [31:0] ME_WB_ALU_result,
    output  reg         [4:0] ME_WB_rd,
    output  reg         ME_WB_RegWrite,
    output  reg         ME_WB_MemtoReg,

    //Memory Interface
    output  reg         [31:0] mem_addr,
    output  reg         [31:0] mem_wdata,
    output  reg         mem_we,
    output  reg         mem_req,
    input   wire        [31:0] mem_rdata,
    input   wire        mem_ready
);

    typedef enum reg [1:0] {IDLE = 2'b00, ACCESS = 2'b01, WAIT = 2'b10} state_t;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_addr <= 32'b0;
            mem_wdata <= 32'b0;
            mem_we <= 1'b0;
            mem_req <= 1'b0;
            ME_WE_data <= 32'b0;
            ME_WB_ALU_result <= 32'b0,
            ME_WB_rd <= 5'b0;
            ME_WB_RegWrite <= 1'b0;
            ME_WB_MemtoReg <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    ME_WB_RegWrite <= 1'b0;
                    mem_req <= 1'b0;
                    if (EX_ME_MemRead || EX_ME_MemWrite) begin
                        mem_addr <= EX_ME_ALU_result;
                        mem_wdata <= EX_ME_rs2;
                        mem_we <= EX_ME_MemWrite;
                        mem_req <= 1'b1;
                        state <= ACCESS;
                    end else begin
                        ME_WB_ALU_result <= EX_ME_ALU_result;
                        ME_WB_rd <= EX_ME_rd;
                        ME_WB_RegWrite <= EX_ME_RegWrite;
                        ME_WB_MemtoReg <= EX_ME_MemtoReg;
                    end
                end
                ACCESS: begin
                    if (mem_ready && EX_ME_MemRead) begin
        
                        ME_WB_data <= mem_rdata;
                        ME_WB_ALU_result <= EX_ME_ALU_result;
                        ME_WB_rd <= EX_ME_rd;
                        ME_WB_RegWrite <= EX_ME_RegWrite;
                        ME_WB_MemtoReg <= EX_ME_MemtoReg;
                        mem_req <= 1'b0;
                        mem_we <== 1'b0;
                        state <= IDLE;
                    end else begin
                        mem_req <= 1'b1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

                        

