/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

 module DMA_peripheral (
    input   wire    clk,      // clock
    input   wire    reset,    // reset_n - low to reset

    input   wire    dma_start,
    input   wire    [31:0] dma_src_addr,
    input   wire    [31:0] dma_dst_addr,
    input   wire    [15:0] dma_word_length,

    output  reg     [31:0] mem_addr,
    output  reg     [31:0] mem_wdata,
    output  reg     mem_we,
    output  reg     mem_req,
    input   wire    [31:0] mem_rdata,
    input   wire    mem_ready,

    output  reg     busy,
    output  reg     done

);
    reg [31:0] curr_src;
    reg [31:0] curr_dst;
    reg [15:0] word_count;
    reg [31:0] read_data;
    
    typedef enum reg [1:0] {IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10, DONE = 2'b11} state_t;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_addr <= 32'b0;
            mem_wdata <= 32'b0;
            mem_we <= 1'b0;
            mem_req <= 1'b0;
            curr_src <= 32'b0;
            curr_dst <= 32'b0;
            word_count <= 16'b0;
            busy <= 1'b0;
            done <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    mem_req <= 1'b0;
                    mem_we <= 1'b0;
                    if (dma_start) begin
                        busy <= 1'b1;
                        word_count <= dma_word_length;
                        curr_src <= dma_src_addr;
                        curr_dst <= dma_dst_addr;
                        state <= READ;
                    end
                end
                READ: begin
                    mem_addr <= curr_src;
                    mem_we <= 1'b0;
                    mem_req <= 1'b1;
                    if (mem_ready) begin
                        mem_req <= 1'b0;
                        read_data <= mem_rdata;
                        state <= WRITE;
                    end
                end
                WRITE: begin
                    mem_addr <= curr_dst;
                    mem_we <= 1'b1;
                    mem_req <= 1'b1;
                    mem_wdata <= read_data;
                    if (mem_ready) begin   
                        mem_we <= 1'b0;
                        mem_req <= 1'b0;
                        curr_src <= curr_src + 32'd4;
                        curr_dst <= curr_dst + 32'd4;
                        if (word_count == 1) begin  
                            state <= DONE;
                        end else begin
                            word_count <= word_count - 1'b1;
                            state <= READ;
                        end
                    end
                end
                DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule