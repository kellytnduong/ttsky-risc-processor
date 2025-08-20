module ALU_tb ();
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALU_control;
    reg [31:0] PC;
    wire [31:0] result;
    wire zero;

    ALU dut (
        .A(A),
        .B(B),
        .ALU_control(ALU_control),
        .PC(PC),
        .result(result),
        .zero(zero)
    );

    inital begin
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0, ALU_tb);

        //ADD
        A = 32'd10;
        B = 32'd5;
        ALU_control = 4'b0000;
        PC = 32'd0;
        #10;

        //SUB
        A = 32'd10;
        B = 32'd5;
        ALU_control = 4'b0001;
        PC = 32'd0;
        #10;

        //LUI
        A = 32'd0;
        B = 32'h12345000;
        ALU_control = 4'b1010;
        PC = 32'd0;
        #10;

        //AUIPC
        A = 32'd0;
        B = 32'h0001000;
        ALU_control = 4'b1011;
        PC = 32'd100;
        #10;

        //JAL
        A = 32'd0;
        B = 32'h00000004;
        ALU_control = 4'b1100;
        PC = 32'd200;
        #10;

        //JALR
        A = 32'd0;
        B = 32'h00000008;
        ALU_control = 4'b1101;
        PC = 32'd0;
        #10;
        $finish;
    end
endmodule