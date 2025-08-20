/*
 * Copyright (c) 2025 Kelly Duong
 * SPDX-License-Identifier: Apache-2.0
 */

module decode_unit (
    input   wire       clk,      // clock
    input   wire       reset,    // reset

    //Pipeline Control
    input   wire    ID_stall,            //from hazard/stall logic
    input   wire    ID_flush,            //from EX on taken branch/jump

    //From IF/ID pipline register
    input   wire    [31:0]  IF_ID_instr, //Instruction from IF stage
    input   wire    [31:0]  IF_ID_PC,    //PC from IF stage
    input   wire    IF_Valid,

    //From WB 
    input   wire    [4:0] WB_rd_addr,
    input   wire    [31:0] WB_rd_data,
    input   wire    WB_RegWrite,

    //Register File Interface
    input   wire    [31:0]  rs1_data,    //rs1 register data from regfile
    input   wire    [31:0]  rs2_data,    //rs2 register data from regfile
    output  wire    [4:0]   rs1_addr,    //rs1 register address
    output  wire    [4:0]   rs2_addr,    //rs2 register address

    //To EX, ME, WB
    output  reg    ID_EX_RegWrite,           //Write-back enable
    output  reg    ID_EX_MemRead,            //Memory Read enable
    output  reg    ID_EX_MemWrite,           //Memory Write enable
    output  reg    ID_EX_MemtoReg,           //Memory Result to Register if = 1
    output  reg    ID_EX_ALU_src,            //ALU source selection (1 = imm, 0 = rs2)
    output  reg    ID_EX_Branch,             //Branch instruction flag
    output  reg    [3:0] ID_EX_ALU_op,       //ALU operation indicator
    output  reg    [4:0] ID_EX_rd_addr,      //Destination Register

    //To ID/EX Pipeline Register
    output  reg    [31:0] ID_EX_instr,  //Instruction to ID/EX register
    output  reg    [31:0] ID_EX_rs1,    //Operand 1
    output  reg    [31:0] ID_EX_rs2,    //Operand 2
    output  reg    [31:0] ID_EX_imm,    //Immediate Value
    output  reg    [31:0] ID_EX_PC,     //PC latch for ID/EX registers
   
);

    //Instruction Decoding (fixed bits -- default R-Type)
    wire [6:0] opcode = IF_ID_instr[6:0];
    wire [4:0] rd = IF_ID_instr[11:7];
    wire [2:0] funct3 = IF_ID_instr[14:12];
    wire [4:0] rs1 = IF_ID_instr[19:15];
    wire [4:0] rs2 = IF_ID_instr[24:20];
    wire [6:0] funct7 = IF_ID_instr[31:25];


    register_file regfile_inst (
        .clk(clk),
        .reset(reset),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .RegWrite(WB_RegWrite),
        .rd_addr(WB_rd_addr),
        .rd_data(WB_rd_data)
    );

    //Immediate Values (for different Instruction Types)
    wire [11:0] imm_i = IF_ID_instr[31:20];
    wire [11:0] imm_s = {IF_ID_instr[31:25], IF_ID_instr[11:7]};
    wire [12:0] imm_b = {IF_ID_instr[31], IF_ID_instr[7], IF_ID_instr[30:25], IF_ID_instr[11:8], 1'b0};
    wire [19:0] imm_u = IF_ID_instr[31:12];
    wire [20:0] imm_j = {IF_ID_instr[31], IF_ID_instr[19:12], IF_ID_instr[20], IF_ID_instr[30:21], 1'b0};

    reg reg_write_en;
    reg mem_write;
    reg mem_read;
    reg mem_to_reg;
    reg alu_src;
    reg branch;
    reg [3:0] alu_op;

    reg [31:0] imm;

    always @(*) begin
        reg_write_en = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        alu_src = 1'b0;
        branch = 1'b0;
        alu_op = 4'b0000;
        imm = 32'b0;

        case (opcode)
            //R-Type
            7'b0110011: begin
                reg_write_en = 1'b1;
                alu_src = 1'b0;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b0;
                imm = 32'b0;
                case ({funct7, funct3})
                    10'b0000000_000: //ADD
                        alu_op = 4'b0000;
                    10'b0100000_000: //SUB
                        alu_op = 4'b0001;
                    10'b0000000_111: //AND
                        alu_op = 4'b0010;  
                    10'b0000000_110: //OR
                        alu_op = 4'b0011;  
                    10'b0000000_100: //XOR
                        alu_op = 4'b0100;
                    10'b0000000_001: //SLL
                        alu_op = 4'b0101;
                    10'b0000000_101: //SRL
                        alu_op = 4'b0110;
                    10'b0100000_101: //SRA
                        alu_op = 4'b0111;
                    default: alu_op = 4'b0000;
                endcase
            end 

            //I-Type       
            7'b0010011: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b0;
                imm = {{20{imm_i[11]}}, imm_i};
                case (funct3)
                    3'b000: //ADDI
                        alu_op = 4'b0000;
                    3'b111: //ANDI
                        alu_op = 4'b0000;
                    3'b110: //ORI
                        alu_op = 4'b0011;
                    3'b100: //XORI
                        alu_op = 4'b0100;    
                    3'b001: //SLLI
                        alu_op = 4'b0101;
                    3'b101: begin
                        if (funct7[5] == 1'b0)
                            alu_op = 4'b110; //SRLI
                        else
                            alu_op = 4'b0111; //SRAI
                    end
                    default: alu_op = 4'b0000;
                endcase
            end

            //Load Instructions (lb, lh, lw, lbu)
            7'b0000011: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b1;
                mem_read = 1'b1;
                mem_write = 1'b0;
                branch = 1'b0;
                imm = {{20{imm_i[11]}}, imm_i};
                alu_op = 4'b0000; //ADD for address calculation
            end

            //Store Instructions (sb, sh, sw)
            7'b0100011: begin
                reg_write_en = 1'b0;
                alu_src = 1'b1;
                mem_to_reg = 1'b0; //don't care
                mem_read = 1'b0;
                mem_write = 1'b1;
                branch = 1'b0;
                imm = {{20{imm_s[11]}}, imm_s};
                alu_op = 4'b0000; //ADD for address calculation
            
            //Branch Instructions
            7'b1100011: begin
                reg_write_en = 1'b0;
                alu_src = 1'b0;
                mem_to_reg = 1'b0; //don't care
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b1;
                imm = {{19{imm_b[12]}}, imm_b};
                alu_op = 4'b1001; //for branch comparison
            end

            //LUI: Load Upper Immediate
            7'b0110111: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1; // immediate
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b0;
                imm = {imm_u, 12'b0}; // upper immediate
                alu_op = 4'b1010; // ALU op code for LUI (just pass imm)
            end

            //AUIPC: Add Upper Immediate to PC
            7'b0010111: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1; // immediate
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b0;
                imm = {imm_u, 12'b0}; // upper immediate
                alu_op = 4'b1011; // ALU op code for AUIPC (PC+imm)
            end

            //JAL: Jump and Link
            7'b1101111: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1; // immediate
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b1; //jals are like branches
                imm = {{11{imm_j[20]}}, imm_j};
                alu_op = 4'b1100; // ALU op code for JAL
            end

            //JALR: Jump and Link Return
            7'b1100111: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1; // immediate
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b1;
                imm = {{20{imm_i[11]}, imm_i}}; // upper immediate
                alu_op = 4'b1101; // ALU op code for JALR
            end

            default: begin
                reg_write_en = 1'b0;
                alu_src = 1'b0;
                mem_to_reg = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b0;
                imm = 32'b0; 
                alu_op = 4'b0000;
            end
        endcase
    end

    assign rs1_addr = rs1;
    assign rs2_addr = rs2;

    //Pipeline register updating (w/ flush/stall handling)
    always @(posedge clk or posedge reset) begin
        if (reset || ID_flush) begin
            ID_EX_PC <= 32'b0;
            ID_EX_instr <= 32'b0;
            ID_EX_rd_addr <= 5'b0;
            ID_EX_rs1 <= 32'b0;
            ID_EX_rs2 <= 32'b0;
            ID_EX_imm <= 32'b0;
            ID_EX_RegWrite <= 1'b0;
            ID_EX_MemRead <= 1'b0;
            ID_EX_MemWrite <= 1'b0;
            ID_EX_MemtoReg <= 1'b0;
            ID_EX_ALU_src <= 1'b0;
            ID_EX_ALU_op <= 3'b0;
            ID_EX_Branch <= 1'b0;
        end else if (!ID_stall) begin
            ID_EX_PC <= IF_ID_PC;
            ID_EX_instr <= IF_ID_instr;
            ID_EX_rd_addr <= rd;
            ID_EX_rs1 <= rs1_data;
            ID_EX_rs2 <= rs2_data;
            if (alu_op == 4'b1010 || alu_op == 4'b1011) begin
                ID_EX_imm <= imm_u;
            end else begin
                ID_EX_imm <= imm_to_use;
            end
            ID_EX_RegWrite <= reg_write_en;
            ID_EX_MemRead <= mem_read;
            ID_EX_MemWrite <= mem_write;
            ID_EX_MemtoReg <= mem_to_reg;
            ID_EX_ALU_src <= alu_src;
            ID_EX_ALU_op <= alu_op;
            ID_EX_Branch <= branch;
        end
    end
endmodule
