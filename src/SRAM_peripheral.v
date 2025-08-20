/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

 module SRAM_peripheral (
    input   wire    clk,      // clock
    input   wire    reset,    // reset_n - low to reset
 
    input   wire    req,
    input   wire    we,
    input   wire    [31:0] addr,
    input   wire    [31:0] wdata,
    output  reg     [31:0] rdata,
    output  reg     ready
 );
    // 4-byte aligned, 1024 words(4KB)
    reg [31:0] mem [0:1023];
    wire [9:0] index = addr[11:2];
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ready <= 1'b0;
            rdata <= 32'b0;
        end else begin 
            ready <= 1'b0; //not ready until a request occurs this cycle
            if (req) begin
                if (we) begin //write
                    mem[index] <= wdata;
                    ready <= 1'b1;
                end else begin //read
                    rdata <= mem[index];
                    ready <= 1'b1;
                end
            end
        end
    end
endmodule