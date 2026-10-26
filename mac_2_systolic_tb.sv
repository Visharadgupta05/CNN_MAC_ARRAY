
`timescale 1ns / 1ps

module Testbench;

    //====================================================
    // CLOCK AND CONTROL
    //====================================================
    reg clk;
    reg reset_n;
    reg clr;
    reg start;

    integer file;

    //====================================================
    // MATRIX A
    //====================================================
    reg signed [3:0] A0 [3:0];
    reg signed [3:0] A1 [3:0];
    reg signed [3:0] A2 [3:0];
    reg signed [3:0] A3 [3:0];

    //====================================================
    // MATRIX B
    //====================================================
    reg signed [3:0] B0 [3:0];
    reg signed [3:0] B1 [3:0];
    reg signed [3:0] B2 [3:0];
    reg signed [3:0] B3 [3:0];

    //====================================================
    // OUTPUTS
    //====================================================
    wire signed [10:0] C00, C01, C02, C03;
    wire signed [10:0] C10, C11, C12, C13;
    wire signed [10:0] C20, C21, C22, C23;
    wire signed [10:0] C30, C31, C32, C33;

    wire done;

    //====================================================
    // DUT
    //====================================================
    SYSTOLIC_TOP DUT (
        .clk(clk),
        .reset_n(reset_n),
        .clr(clr),
        .start(start),

        .A0(A0),
        .A1(A1),
        .A2(A2),
        .A3(A3),

        .B0(B0),
        .B1(B1),
        .B2(B2),
        .B3(B3),

        .C00(C00), .C01(C01), .C02(C02), .C03(C03),
        .C10(C10), .C11(C11), .C12(C12), .C13(C13),
        .C20(C20), .C21(C21), .C22(C22), .C23(C23),
        .C30(C30), .C31(C31), .C32(C32), .C33(C33),

        .done(done)
    );

    //====================================================
    // CLOCK: 10 ns period
    //====================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //====================================================
    // TEST
    //====================================================
    initial begin

        // INITIAL CONDITIONS
        reset_n = 1'b0;
        clr     = 1'b0;
        start   = 1'b0;

        // MATRIX A
        A0[0] =  4'sd1;
        A0[1] =  4'sd2;
        A0[2] =  4'sd3;
        A0[3] =  4'sd4;

        A1[0] =  4'sd5;
        A1[1] =  4'sd6;
        A1[2] =  4'sd7;
        A1[3] = -4'sd1;

        A2[0] = -4'sd2;
        A2[1] = -4'sd3;
        A2[2] = -4'sd4;
        A2[3] = -4'sd5;

        A3[0] = -4'sd6;
        A3[1] = -4'sd7;
        A3[2] =  4'sd0;
        A3[3] =  4'sd1;

        // MATRIX B
        B0[0] =  4'sd1;
        B0[1] = -4'sd1;
        B0[2] =  4'sd2;
        B0[3] =  4'sd3;

        B1[0] =  4'sd2;
        B1[1] =  4'sd3;
        B1[2] = -4'sd2;
        B1[3] =  4'sd1;

        B2[0] = -4'sd3;
        B2[1] =  4'sd2;
        B2[2] =  4'sd1;
        B2[3] = -4'sd1;

        B3[0] =  4'sd1;
        B3[1] = -4'sd2;
        B3[2] =  4'sd3;
        B3[3] =  4'sd2;

        // RESET
        #20;
        reset_n = 1'b1;

        // CLEAR
        @(negedge clk);
        clr = 1'b1;

        @(negedge clk);
        clr = 1'b0;

        // START
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // WAIT FOR DONE
        wait(done == 1'b1);
        #1;

        // DISPLAY RESULTS
        $display("");
        $display("==============================================");
        $display("          4x4 SYSTOLIC ARRAY RESULT");
        $display("==============================================");

        $display("%0d %0d %0d %0d", C00, C01, C02, C03);
        $display("%0d %0d %0d %0d", C10, C11, C12, C13);
        $display("%0d %0d %0d %0d", C20, C21, C22, C23);
        $display("%0d %0d %0d %0d", C30, C31, C32, C33);

        $display("==============================================");

        // SAVE OUTPUT MATRIX TO FILE
        file = $fopen("mac_output.txt", "w");

        if (file != 0) begin
            $fwrite(file, "%0d %0d %0d %0d\n", C00, C01, C02, C03);
            $fwrite(file, "%0d %0d %0d %0d\n", C10, C11, C12, C13);
            $fwrite(file, "%0d %0d %0d %0d\n", C20, C21, C22, C23);
            $fwrite(file, "%0d %0d %0d %0d\n", C30, C31, C32, C33);

            $fclose(file);
            $display("Output saved to mac_output.txt");
        end
        else begin
            $display("Error creating output file");
        end

        // CHECK EXPECTED RESULT
        if ((C00 ==   0) && (C01 ==   3) && (C02 ==  13) && (C03 ==  10) &&
            (C10 ==  -5) && (C11 ==  29) && (C12 ==   2) && (C13 ==  12) &&
            (C20 ==  -1) && (C21 ==  -5) && (C22 == -17) && (C23 == -15) &&
            (C30 == -19) && (C31 == -17) && (C32 ==   5) && (C33 == -23)) begin

            $display("");
            $display("==============================================");
            $display("                TEST PASSED");
            $display("==============================================");

        end
        else begin

            $display("");
            $display("==============================================");
            $display("                TEST FAILED");
            $display("==============================================");

        end

        #20;
        $finish;

    end

endmodule
