`timescale 1ns/1ps

module mac_2_systolic_tb;

parameter H = 5;
parameter W = 5;
parameter R = 3;
parameter S = 3;
parameter E = 3;
parameter F = 3;

reg clk;
reg rst_n;

reg signed [7:0] A [H-1:0][W-1:0][2:0];
reg signed [7:0] w [R-1:0][S-1:0][2:0];

wire signed [23:0] out [E-1:0][F-1:0];

integer i,j,k;
integer fp;

mac_2_systolic DUT(
    .A(A),
    .w(w),
    .clk(clk),
    .rst_n(rst_n),
    .out(out)
);

/////////////////////////////////////////////////
// Clock
/////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

/////////////////////////////////////////////////
// Stimulus
/////////////////////////////////////////////////

initial begin

    rst_n = 0;

    for(i=0;i<H;i=i+1)
        for(j=0;j<W;j=j+1)
            for(k=0;k<3;k=k+1)
                A[i][j][k] = 0;

    for(i=0;i<R;i=i+1)
        for(j=0;j<S;j=j+1)
            for(k=0;k<3;k=k+1)
                w[i][j][k] = 0;

    #20;
    rst_n = 1;

    // Channel 0

    A[0][0][0]=1;   A[0][1][0]=2;   A[0][2][0]=3;   A[0][3][0]=4;   A[0][4][0]=5;
    A[1][0][0]=6;   A[1][1][0]=7;   A[1][2][0]=8;   A[1][3][0]=9;   A[1][4][0]=10;
    A[2][0][0]=11;  A[2][1][0]=12;  A[2][2][0]=13;  A[2][3][0]=14;  A[2][4][0]=15;
    A[3][0][0]=16;  A[3][1][0]=17;  A[3][2][0]=18;  A[3][3][0]=19;  A[3][4][0]=20;
    A[4][0][0]=21;  A[4][1][0]=22;  A[4][2][0]=23;  A[4][3][0]=24;  A[4][4][0]=25;

    // Channel 1

    for(i=0;i<H;i=i+1)
        for(j=0;j<W;j=j+1)
            A[i][j][1] = 1;

    // Channel 2

    for(i=0;i<H;i=i+1)
        for(j=0;j<W;j=j+1)
            A[i][j][2] = 2;

    // Weights

    for(i=0;i<R;i=i+1)
        for(j=0;j<S;j=j+1)
        begin
            w[i][j][0] = 1;
            w[i][j][1] = 1;
            w[i][j][2] = 1;
        end
end

/////////////////////////////////////////////////
// Wait for DONE and dump outputs
/////////////////////////////////////////////////

initial begin

    wait(DUT.state == DUT.DONE);

    repeat(3) @(posedge clk);

    $display("\n==== OUTPUT FEATURE MAP ====\n");

    for(i=0;i<3;i=i+1)
    begin
        for(j=0;j<3;j=j+1)
            $write("%0d ", out[i][j]);

        $display("");
    end

    fp = $fopen("mac_output.txt","w");

    for(i=0;i<3;i=i+1)
    begin
        for(j=0;j<3;j=j+1)
            $fwrite(fp,"%0d ", out[i][j]);

        $fwrite(fp,"\n");
    end

    $fclose(fp);

    $display("\nout[2][2] = %0d", out[2][2]);

    $finish;
end

/////////////////////////////////////////////////
// Debug monitor
/////////////////////////////////////////////////

always @(posedge clk)
begin
    $display("T=%0t state=%0d row=%0d col=%0d count=%0d out22=%0d",
              $time,
              DUT.state,
              DUT.row,
              DUT.col,
              DUT.compute_count,
              DUT.out[2][2]);
end

endmodule