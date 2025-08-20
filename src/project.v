/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module uwasic_risc_processor_Kelly_Duong (
  input wire clk,
  input wire reset
);

  //IF Stage
  wire [31:0] IF_PC;
  wire [31:0] IF_ID_PC;
  wire [31:0] IF_ID_instr;
  wire IF_Valid

  wire IF_stall;
  wire IF_flush;
  wire [31:0] branch_PC;

  fetch_unit fetch_inst (
    .clk(clk),
    .reset(reset),
    .IF_stall(IF_stall),
    .IF_flush(IF_flush),
    .branch_PC(branch_PC),
    .instr(IF_instr),
    .instr_ready(IF_instr_ready),
    .instr_addr(IF_instr_addr),
    .instr_req(IF_instr_req),
    .PC(IF_PC),
    .IF_ID_PC(IF_ID_PC),
    .IF_ID_instr(IF_ID_instr),
    .IF_Valid(IF_Valid)
  );

  //ID Stage
  wire [31:0] ID_EX_rs1;
  wire [31:0] ID_EX_rs2;
  wire [31:0] ID_EX_imm;
  wire [31:0] ID_EX_PC;
  wire [4:0] ID_EX_rd;
  wire [3:0] ID_EX_ALU_op;
  wire ID_EX_ALU_src;
  wire ID_EX_RegWrite;
  wire ID_EX_MemRead;
  wire ID_EX_MemWrite;
  wire ID_EX_Branch;

  decode_unit decode_inst (
    .clk(clk),
    .reset(reset),
    .ID_flush(ID_flush),
    .ID_stall(ID_stall),
    .IF_ID_PC(IF_ID_PC),
    .IF_ID_instr(IF_ID_instr),
    .IF_Valid(IF_Valid),
    .WB_rd(WB_rd),
    .WB_data(WB_data),
    .WB_RegWrite(WB_RegWrite),
    .ID_EX_rs1(ID_EX_rs1),
    .ID_EX_rs2(ID_EX_rs2),
    .ID_EX_imm(ID_EX_imm),
    .ID_EX_rd(ID_EX_rd),
    .ID_EX_PC(ID_EX_PC),
    .ID_EX_ALU_src(ID_EX_ALU_src),
    .ID_EX_ALU_op(ID_EX_ALU_op),
    .ID_EX_Branch(ID_EX_Branch),
    .ID_EX_RegWrite(ID_EX_RegWrite),
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_MemWrite(ID_EX_MemRead),
    .ID_EX_MemtoReg(ID_EX_MemtoReg),
  );
  
  // EX Stage
  wire [31:0] EX_ME_ALU_result;
  wire [31:0] EX_ME_rs2;
  wire [4:0] EX_ME_rd;
  wire EX_ME_RegWrite;
  wire EX_ME_MemRead;
  wire EX_ME_MemWrite;
  wire EX_ME_MemtoReg;
  wire [31:0] EX_ME_branch_PC;
  wire EX_ME_branch_taken;

  execution_unit exec_inst (
    .clk(clk),
    .reset(reset),
    .ID_EX_rs1(ID_EX_rs1),
    .ID_EX_rs2(ID_EX_rs2),
    .ID_EX_imm(ID_EX_imm),
    .ID_EX_rd(ID_EX_rd),
    .ID_EX_PC(ID_EX_PC),
    .ID_EX_ALU_src(ID_EX_ALU_src),
    .ID_EX_ALU_op(ID_EX_ALU_op),
    .ID_EX_Branch(ID_EX_Branch),
    .ID_EX_RegWrite(ID_EX_RegWrite),
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_MemWrite(ID_EX_MemRead),
    .ID_EX_MemtoReg(ID_EX_MemtoReg),
    .EX_ME_ALU_result(EX_ME_ALU_result),
    .EX_ME_rs2(EX_ME_rs2),
    .EX_ME_rd(EX_ME_rd),
    .EX_ME_RegWrite(EX_ME_RegWrite),
    .EX_ME_MemRead(EX_ME_MemRead),
    .EX_ME_MemWrite(EX_ME_MemWrite),
    .EX_ME_MemtoReg(EX_ME_MemtoReg),
    .EX_ME_branch_PC(EX_ME_branch_PC),
    .EX_ME_branch_taken(EX_ME_branch_taken)
  );

  // Branch Unit
  branch_unit branch_inst (
    .clk(clk),      // clock
    .reset(reset), 
    .EX_ME_branch_taken(EX_ME_branch_taken),
    .EX_ME_branch_PC(EX_ME_branch_PC),
    .IF_flush(IF_flush),
    .ID_flush(ID_flush),
    .new_PC(new_PC)
  );

  // ME Stage
  wire [31:0] ME_WB_data;
  wire [31:0] ME_WB_result;
  wire ME_WB_ALU_src;

  memory_unit me_inst (
    .EX_ME_ALU_result(EX_ME_ALU_result),
    .EX_ME_rs2(EX_ME_rs2),
    .EX_ME_rd(EX_ME_rd),
    .EX_ME_RegWrite(EX_ME_RegWrite),
    .EX_ME_MemRead(EX_ME_MemRead),
    .EX_ME_MemWrite(EX_ME_MemWrite),
    .EX_ME_MemtoReg(EX_ME_MemtoReg),

    .ME_WB_data(ME_WB_data),
    .ME_WB_ALU_result(ME_WB_ALU_result),
    .ME_WB_rd(ME_WB_rd),
    .ME_WB_RegWrite(ME_WB_RegWrite),
    .ME_WB_MemtoReg(ME_WB_MemtoReg),

    .mem_rdata(SRAM_rdata),
    .mem_ready(SRAM_ready),

    .mem_addr(ME_addr),
    .mem_wdata(ME_wdata),
    .mem_we(ME_we),
    .mem_req(ME_req)
  )

  // WB Stage
  wire [31:0] WB_rd_data;
  wire [4:0] WB_rd_addr;
  wire WB_RegWrite;

  writeback_unit wb_inst (
    .ME_WB_data(ME_WB_data),
    .ME_WB_ALU_result(ME_WB_ALU_result),
    .ME_WB_rd(ME_WB_rd),
    .ME_WB_RegWrite(ME_WB_RegWrite),
    .ME_WB_MemtoReg(ME_WB_MemtoReg),
    .WB_rd_data(WB_rd_data),
    .WB_rd_addr(WB_rd_addr),
    .WB_RegWrite(WB_RegWrite)
  );

  // Hazard hazard_handler
  assign IF_ID_rs1 = IF_ID_instr[19:15];
  assign IF_ID_rs2 = IF_ID_instr[24:20];

  hazard_handler hazard_inst (
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_rd(ID_EX_rd),
    .IF_ID_rs1(IF_ID_rs1),
    .IF_ID_rs2(IF_ID_rs2),
    .stall_IF(IF_stall),
    .stall_ID(ID_stall)
  )

  // DMA + SRAM Wires
  /////////////////////
  // DMA <-> Arbiter //
  /////////////////////

  wire DMA_req;
  wire DMA_we;
  wire DMA_ready;
  wire [31:0] DMA_addr;
  wire [31:0] DMA_wdata;
  wire [31:0] DMA_rdata;

  ////////////////////
  // ME <-> Arbiter //
  ////////////////////

  wire ME_req;
  wire ME_we;
  wire ME_ready;
  wire [31:0] ME_addr;
  wire [31:0] ME_wdata;
  wire [31:0] ME_rdata;

  ////////////////////
  // IF <-> Arbiter //
  ////////////////////

  wire IF_req;
  wire IF_we;
  wire IF_ready;
  wire [31:0] IF_addr;
  wire [31:0] IF_wdata;
  wire [31:0] IF_rdata;

  //////////////////////
  // SRAM <-> Arbiter //
  //////////////////////

  wire SRAM_req;
  wire SRAM_we;
  wire SRAM_ready;
  wire [31:0] SRAM_addr;
  wire [31:0] SRAM_wdata;
  wire [31:0] SRAM_rdata;

  //SRAM Arbiter
  SRAM_arbiter  arbiter_inst (
    .clk(clk),
    .reset(reset),

    // IF interface
    .IF_req(IF_req),
    .IF_we(IF_we),
    .IF_addr(IF_addr),
    .IF_wdata(IF_wdata),
    .IF_rdata(IF_rdata),
    .IF_ready(IF_ready),

    // ME interface
    .ME_req(ME_req),
    .ME_we(ME_we),
    .ME_addr(ME_addr),
    .ME_wdata(ME_wdata),
    .ME_rdata(ME_rdata),
    .ME_ready(ME_ready),

    // DMA interface
    .DMA_req(DMA_req),
    .DMA_we(DMA_we),
    .DMA_addr(DMA_addr),
    .DMA_wdata(DMA_wdata),
    .DMA_rdata(DMA_rdata),
    .DMA_ready(DMA_ready),

    // SRAM interface
    .SRAM_req(SRAM_req),
    .SRAM_we(SRAM_we),
    .SRAM_addr(SRAM_addr),
    .SRAM_wdata(SRAM_wdata),
    .SRAM_rdata(SRAM_rdata),
    .SRAM_ready(SRAM_ready)
  );

  //SRAM
  SRAM_peripheral sram_inst (
    .clk(clk),
    .reset(reset),
    .req(SRAM_req),
    .we(SRAM_we),
    .addr(SRAM_addr),
    .wdata(SRAM_wdata),
    .rdata(SRAM_rdata),
    .ready(SRAM_ready)
  );

  //DMA
  wire dma_start;
  wire [31:0] dma_src_addr;
  wire [31:0] dma_dst_addr;
  wire [15:0] dma_word_length;

  wire dma_busy;
  wire dma_done;

  DMA_peripheral dma_inst (
    .clk(clk),
    .reset(reset),

    .dma_start(dma_start),
    .dma_src_addr(dma_src_addr),
    .dma_dst_addr(dma_dst_addr),
    .dma_word_length(dma_word_length),

    .mem_req(DMA_req),
    .mem_we(DMA_we),
    .mem_addr(DMA_addr),
    .mem_wdata(DMA_wdata),
    .mem_rdata(DMA_rdata),
    .mem_ready(DMA_ready),

    .busy(dma_busy),
    .done(dma_done)
  );

endmodule
