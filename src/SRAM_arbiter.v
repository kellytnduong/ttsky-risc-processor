/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

 module SRAM_arbiter (
    input   wire    clk,      // clock
    input   wire    reset,    
 
    //IF Client
    input   wire    IF_req,
    input   wire    IF_we,
    input   wire    [31:0] IF_addr,
    input   wire    [31:0] IF_wdata,
    output  reg     [31:0] IF_rdata,
    output  reg     IF_ready,

    //ME Client
    input   wire    ME_req,
    input   wire    ME_we,
    input   wire    [31:0] ME_addr,
    input   wire    [31:0] ME_wdata,
    output  reg     [31:0] ME_rdata,
    output  reg     ME_ready,

    //DMA Client
    input   wire    DMA_req,
    input   wire    DMA_we,
    input   wire    [31:0] DMA_addr,
    input   wire    [31:0] DMA_wdata,
    output  reg     [31:0] DMA_rdata,
    output  reg     DMA_ready,

    //To SRAM
    output   reg    SRAM_req,
    output   reg    SRAM_we,
    output   reg    [31:0] SRAM_addr,
    output   reg    [31:0] SRAM_wdata,
    input    wire   [31:0] SRAM_rdata,
    input    wire   SRAM_ready

 );

    typedef enum reg [1:0] {IDLE = 2'd0, SERVE_IF = 2'd1, SERVE_ME = 2'd2, SERVE_DMA = 2'd3} state_t;
    
    state_t state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else    
            state <= next_state;
    end

    //DMA > ME > IF priority
    always @(*) begin
        SRAM_req = 1'b0;
        SRAM_we = 1'b0;
        SRAM_addr = 32'b0;
        SRAM_wdata = 32'b0;

        IF_ready = 1'b0;
        ME_ready = 1'b0;
        DMA_ready = 1'b0;

        next_state = state;

        case (state)
            IDLE: begin
                if (DMA_req) next_state = SERVE_DMA;
                else if (ME_req) next_state = SERVE_ME;
                else if (IF_req) next_state = SERVE_IF;
            end

            SERVE_DMA: begin
                SRAM_req = 1'b1;
                SRAM_we = DMA_we;
                SRAM_addr = DMA_addr;
                SRAM_wdata = DMA_wdata;
                if (SRAM_ready) begin
                    DMA_ready = 1'b1;
                    next_state = IDLE;
                end
            end

            SERVE_ME: begin
                SRAM_req = 1'b1;
                SRAM_we = ME_we;
                SRAM_addr = ME_addr;
                SRAM_wdata = ME_wdata;
                if (SRAM_ready) begin
                    ME_ready = 1'b1;
                    next_state = IDLE;
                end
            end

            SERVE_IF: begin
                SRAM_req = 1'b1;
                SRAM_we = IF_we;
                SRAM_addr = IF_addr;
                SRAM_wdata = IF_wdata;
                if (SRAM_ready) begin
                    IF_ready = 1'b1;
                    next_state = IDLE;
                end
            end
        endcase
    end

    //Capture read data onnly when ready
    always @(posedge clk) begin
        if (SRAM_ready) begin
            case (state)
                SERVE_DMA: DMA_rdata <= SRAM_rdata;
                SERVE_ME: ME_rdata <= SRAM_rdata;
                SERVE_IF: IF_rdata <= SRAM_rdata;
            endcase
        end
    end
endmodule
