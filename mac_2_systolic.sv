`timescale 1ns / 1ps

module SYSTOLIC_TOP(

    input clk,
    input reset_n,
    input clr,
    input start,

    // Input matrix A
    input signed [3:0] A0 [3:0],
    input signed [3:0] A1 [3:0],
    input signed [3:0] A2 [3:0],
    input signed [3:0] A3 [3:0],

    // Weight matrix B
    input signed [3:0] B0 [3:0],
    input signed [3:0] B1 [3:0],
    input signed [3:0] B2 [3:0],
    input signed [3:0] B3 [3:0],

    // Results
    output signed [10:0] C00,
    output signed [10:0] C01,
    output signed [10:0] C02,
    output signed [10:0] C03,

    output signed [10:0] C10,
    output signed [10:0] C11,
    output signed [10:0] C12,
    output signed [10:0] C13,

    output signed [10:0] C20,
    output signed [10:0] C21,
    output signed [10:0] C22,
    output signed [10:0] C23,

    output signed [10:0] C30,
    output signed [10:0] C31,
    output signed [10:0] C32,
    output signed [10:0] C33,

    output done
);

    //====================================================
    // CONTROL SIGNALS
    //====================================================

    wire load_A;
    wire load_B;
    wire feed_A;
    wire feed_B;


    //====================================================
    // BUFFER OUTPUTS
    //====================================================

    wire signed [3:0] A0_out;
    wire signed [3:0] A1_out;
    wire signed [3:0] A2_out;
    wire signed [3:0] A3_out;

    wire signed [3:0] B0_out;
    wire signed [3:0] B1_out;
    wire signed [3:0] B2_out;
    wire signed [3:0] B3_out;


    //====================================================
    // CONTROL UNIT
    //====================================================

    CONTROL_UNIT CU (

        .clk       (clk),
        .reset_n   (reset_n),
        .start     (start),

        .load_A    (load_A),
        .load_B    (load_B),

        .feed_A    (feed_A),
        .feed_B    (feed_B),

        .done      (done)
    );


    //====================================================
    // INPUT BUFFER
    //====================================================

    INPUT_BUFFER IB (

        .clk       (clk),
        .reset_n   (reset_n),
        .clr       (clr),

        .load_A    (load_A),
        .feed_A    (feed_A),

        .A0        (A0),
        .A1        (A1),
        .A2        (A2),
        .A3        (A3),

        .A0_out    (A0_out),
        .A1_out    (A1_out),
        .A2_out    (A2_out),
        .A3_out    (A3_out)
    );


    //====================================================
    // WEIGHT BUFFER
    //====================================================

    WEIGHT_BUFFER WB (

        .clk       (clk),
        .reset_n   (reset_n),
        .clr       (clr),

        .load_B    (load_B),
        .feed_B    (feed_B),

        .B0        (B0),
        .B1        (B1),
        .B2        (B2),
        .B3        (B3),

        .B0_out    (B0_out),
        .B1_out    (B1_out),
        .B2_out    (B2_out),
        .B3_out    (B3_out)
    );


    //====================================================
    // 4x4 SYSTOLIC ARRAY
    //====================================================

    systolic_array SA (

        .A0_in    (A0_out),
        .A1_in    (A1_out),
        .A2_in    (A2_out),
        .A3_in    (A3_out),

        .B0_in    (B0_out),
        .B1_in    (B1_out),
        .B2_in    (B2_out),
        .B3_in    (B3_out),

        .clk      (clk),
        .clr      (clr),
        .reset_n  (reset_n),

        .C00      (C00),
        .C01      (C01),
        .C02      (C02),
        .C03      (C03),

        .C10      (C10),
        .C11      (C11),
        .C12      (C12),
        .C13      (C13),

        .C20      (C20),
        .C21      (C21),
        .C22      (C22),
        .C23      (C23),

        .C30      (C30),
        .C31      (C31),
        .C32      (C32),
        .C33      (C33)
    );

endmodule



// 16 pes instantiation
module systolic_array(


    // 4 rows for entering input from input buffer
    input signed [3:0] A0_in,
    input signed [3:0] A1_in,
    input signed [3:0] A2_in,
    input signed [3:0] A3_in,


     //  4 columns for entering weight from weight buffer
    input signed [3:0] B0_in,
    input signed [3:0] B1_in,
    input signed [3:0] B2_in,
    input signed [3:0] B3_in, 

     
    input clk,
    input clr,
    input reset_n,
    
   
   
     // Results
     
     // first row
    output signed [10:0] C00,
    output signed [10:0] C01,
    output signed [10:0] C02,
    output signed [10:0] C03,

     // second row
    output signed [10:0] C10,
    output signed [10:0] C11,
    output signed [10:0] C12,
    output signed [10:0] C13,
    
    
     // third row
    output signed [10:0] C20,
    output signed [10:0] C21,
    output signed [10:0] C22,
    output signed [10:0] C23,
    
    
    // fourth row
    output signed [10:0] C30,
    output signed [10:0] C31,
    output signed [10:0] C32,
    output signed [10:0] C33
     

);

 // Intermediate wires
    wire signed [3:0] A0_wire [3:0];
    wire signed [3:0] A1_wire [3:0];
    wire signed [3:0] A2_wire [3:0]; 
    wire signed [3:0] A3_wire [3:0];
   
    wire signed [3:0] B0_wire [3:0]; 
    wire signed [3:0] B1_wire [3:0];  
    wire signed [3:0] B2_wire [3:0]; 
    wire signed [3:0] B3_wire [3:0];  



//zeroth row
PE PE00(.A_in(A0_in), .B_in(B0_in), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A0_wire[0]), .B_out(B0_wire[0]), .result (C00));
PE PE01(.A_in(A0_wire[0]), .B_in(B1_in), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A0_wire[1]), .B_out(B0_wire[1]), .result (C01));
PE PE02(.A_in(A0_wire[1]), .B_in(B2_in), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A0_wire[2]), .B_out(B0_wire[2]), .result (C02));
PE PE03(.A_in(A0_wire[2]), .B_in(B3_in), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A0_wire[3]), .B_out(B0_wire[3]), .result (C03));


// first row 
PE PE10(.A_in(A1_in), .B_in(B0_wire[0]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A1_wire[0]), .B_out(B1_wire[0]), .result (C10));     
PE PE11(.A_in(A1_wire[0]), .B_in(B0_wire[1]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A1_wire[1]), .B_out(B1_wire[1]), .result (C11));
PE PE12(.A_in(A1_wire[1]), .B_in(B0_wire[2]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A1_wire[2]), .B_out(B1_wire[2]), .result (C12));
PE PE13(.A_in(A1_wire[2]), .B_in(B0_wire[3]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A1_wire[3]), .B_out(B1_wire[3]), .result (C13));


// second row 
PE PE20(.A_in(A2_in), .B_in(B1_wire[0]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A2_wire[0]), .B_out(B2_wire[0]), .result (C20));      
PE PE21(.A_in(A2_wire[0]), .B_in(B1_wire[1]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A2_wire[1]), .B_out(B2_wire[1]), .result (C21)); 
PE PE22(.A_in(A2_wire[1]), .B_in(B1_wire[2]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A2_wire[2]), .B_out(B2_wire[2]), .result (C22)); 
PE PE23(.A_in(A2_wire[2]), .B_in(B1_wire[3]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A2_wire[3]), .B_out(B2_wire[3]), .result (C23)); 

// third row

PE PE30(.A_in(A3_in), .B_in(B2_wire[0]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A3_wire[0]), .B_out(B3_wire[0]), .result (C30));      
PE PE31(.A_in(A3_wire[0]), .B_in(B2_wire[1]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A3_wire[1]), .B_out(B3_wire[1]), .result (C31)); 
PE PE32(.A_in(A3_wire[1]), .B_in(B2_wire[2]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A3_wire[2]), .B_out(B3_wire[2]), .result (C32)); 
PE PE33(.A_in(A3_wire[2]), .B_in(B2_wire[3]), .clk(clk), .clr(clr), .reset_n(reset_n), .A_out(A3_wire[3]), .B_out(B3_wire[3]), .result (C33)); 

endmodule



// PE 
module PE(
    input   signed [3:0] A_in,
    input   signed [3:0] B_in,
    input    clk, 
    input clr, 
    input reset_n, 

    output reg signed [3:0] A_out,
    output reg signed [3:0] B_out,
    output reg signed [10:0] result
);

wire signed [7:0] PRODUCT;

BOOTH_MULTIPLICATION BM (.Multiplier(A_in), .Multiplicand(B_in), .PRODUCT(PRODUCT));

always @(posedge clk or negedge reset_n)
begin

if(!reset_n)
begin

A_out <= 4'sd0;
B_out <= 4'sd0;

result <= 11'sd0;
end

else if(clr)
    begin
        A_out <= 4'sd0;
        B_out <= 4'sd0;
        result <= 11'sd0;
    end

else 
begin

A_out <= A_in;
B_out <= B_in;
result <= result + {{3{PRODUCT[7]}}, PRODUCT};



end

end

endmodule


// controller
module CONTROL_UNIT(
input clk ,
 input reset_n,
  input start , 
output reg load_A,
output reg load_B,
output reg feed_A,
output reg feed_B,
output reg done

);


reg [2:0] state , next_state ;
reg [3:0] compute_count = 4'b0000;
reg [1:0] flush_count = 2'b00;

parameter IDLE = 3'b000 , LOAD = 3'b001 , COMPUTE = 3'b010 , FLUSH = 3'b011,  DONE = 3'b100;

always @ (posedge clk or negedge reset_n)
begin

if (!reset_n)
begin
state <= IDLE;
compute_count <= 0;
flush_count <= 0;
end

else 
begin
state <= next_state;

if(state == COMPUTE)
begin

if ( compute_count  < 7 )
compute_count <= compute_count + 1;

else
compute_count <= 0;

end

if(state == FLUSH)
begin

if ( flush_count  < 2 )
flush_count <= flush_count + 1;

else
flush_count <= 0;
end

end

end

always @(*)
begin

case (state )

IDLE:
begin
if (start )
next_state = LOAD;

else
next_state = IDLE;

end

LOAD :
begin
next_state = COMPUTE;
end


COMPUTE:
begin
if(compute_count == 7)
next_state = FLUSH;

else
next_state = COMPUTE;
end


FLUSH:
begin
if(flush_count == 2)
next_state = DONE;

else
next_state = FLUSH;
end


DONE:
begin
next_state = IDLE;

end

endcase
end



always @ (state)
begin

case(state)

IDLE :
begin

load_A = 0;
load_B = 0;
feed_A = 0;
feed_B = 0;
done   = 0;
end

LOAD: 
begin
load_A = 1;
load_B = 1;
feed_A = 0;
feed_B = 0;
done   = 0;

end

COMPUTE :
begin
load_A = 0;
load_B = 0;
feed_A = 1;
feed_B = 1;
done   = 0;
end

FLUSH:
begin
load_A = 0;
load_B = 0;
feed_A = 0;
feed_B = 0;
done   = 0;

end



DONE:
begin
load_A = 0;
load_B = 0;
feed_A = 0;
feed_B = 0;
done   = 1;

end


endcase
end
endmodule





module INPUT_BUFFER(
input clk, 
input reset_n,
input clr,
input load_A, 
input feed_A,
input signed [3:0] A0 [3:0], 
input signed [3:0] A1 [3:0],
input signed [3:0] A2 [3:0],
input signed [3:0] A3 [3:0], 

    output reg signed [3:0] A0_out,
    output reg signed [3:0] A1_out,
    output reg signed [3:0] A2_out,
    output reg signed [3:0] A3_out

);

reg  signed [3:0] A_matrix [3:0][3:0];
reg [2:0] feed_count ; 

// delay registers 
reg signed [3:0] A1_delay;
reg signed [3:0] A2_delay1, A2_delay2;
reg signed [3:0] A3_delay1,
                 A3_delay2, 
                 A3_delay3;




integer i, j;

always @(posedge clk or negedge reset_n )
begin
if (!reset_n)
begin

A0_out <= 4'sd0;
A1_out <= 4'sd0;
A2_out <= 4'sd0;
A3_out <= 4'sd0;
feed_count <= 3'd0;
A1_delay <= 4'sd0;
A2_delay1 <= 4'sd0;
A2_delay2<= 4'sd0;
A3_delay1 <= 4'sd0;
A3_delay2 <= 4'sd0;
A3_delay3 <= 4'sd0;


for (i = 0 ; i < 4 ; i = i + 1)
begin

for (j = 0 ; j < 4; j = j + 1)
A_matrix[i][j] <= 4'sd0;


end
end

else if (clr)
begin

A0_out <= 4'sd0;    
A1_out <= 4'sd0;    
A2_out <= 4'sd0;    
A3_out <= 4'sd0;    
feed_count <= 3'd0; 
A1_delay <= 4'sd0;
A2_delay1 <= 4'sd0;
A2_delay2<= 4'sd0; 
A3_delay1 <= 4'sd0;
A3_delay2 <= 4'sd0;
A3_delay3 <= 4'sd0;



for (i = 0 ; i < 4 ; i = i + 1)  
begin                            
                                 
for (j = 0 ; j < 4; j = j + 1)   
A_matrix[i][j] <= 4'sd0; 

        
end


end

// load 4x4 input matrix to A_matrix 
 else if (load_A)
begin

feed_count <= 0;

for (j = 0 ; j < 4 ; j= j + 1)
begin

A_matrix [0][j] <= A0[j];
A_matrix [1][j] <= A1[j];
A_matrix [2][j] <= A2[j];
A_matrix [3][j] <= A3[j];
end

end

else if (feed_A)

begin 

// 0th row                           
A0_out <= (feed_count <= 3) ?  A_matrix [0][feed_count]: 4'sd0;
A1_out <= (feed_count <= 4) ?  A1_delay : 4'sd0;
A2_out <= (feed_count <= 5) ?  A2_delay2 : 4'sd0;
A3_out <= (feed_count <= 6) ?  A3_delay3 : 4'sd0;
   
A2_delay2 <= A2_delay1;
A3_delay2 <= A3_delay1;
A3_delay3 <= A3_delay2;



if(feed_count < 3'd7)
feed_count <= feed_count + 1;


if (feed_count <= 3)
begin

//1st row

A1_delay <= A_matrix [1][feed_count];

//2nd row


A2_delay1 <= A_matrix [2][feed_count];

//3rd row 

A3_delay1 <= A_matrix[3][feed_count];

end





end


end





endmodule




module WEIGHT_BUFFER(
input clk, 
input reset_n,
input clr,
input load_B, 
input feed_B,
input signed [3:0]  B0 [3:0], 
input signed [3:0]  B1 [3:0],
input signed [3:0]  B2 [3:0],
input signed [3:0]  B3 [3:0], 

    output reg signed [3:0] B0_out,
    output reg signed [3:0] B1_out,
    output reg signed [3:0] B2_out,
    output reg signed [3:0] B3_out

);

reg  signed [3:0] B_matrix [3:0][3:0];
reg [2:0] feed_count ; 

// delay registers 
reg signed [3:0] B1_delay;
reg signed [3:0] B2_delay1, B2_delay2;
reg signed [3:0] B3_delay1,
                 B3_delay2, 
                 B3_delay3;




integer i, j;

always @(posedge clk or negedge reset_n )
begin
if (!reset_n)
begin

B0_out <= 4'sd0;
B1_out <= 4'sd0;
B2_out <= 4'sd0;
B3_out <= 4'sd0;
  feed_count <= 3'd0;
B1_delay <= 4'sd0;
B2_delay1 <= 4'sd0;
B2_delay2<= 4'sd0;
B3_delay1 <= 4'sd0;
B3_delay2 <= 4'sd0;
B3_delay3 <= 4'sd0;


for (i = 0 ; i < 4 ; i = i + 1)
begin

for (j = 0 ; j < 4; j = j + 1)
B_matrix[i][j] <= 4'sd0;


end
end

else if (clr)
begin


B0_out <= 4'sd0;    
B1_out <= 4'sd0;    
B2_out <= 4'sd0;    
B3_out <= 4'sd0;    
feed_count <= 3'd0; 
B1_delay <= 4'sd0;
B2_delay1 <= 4'sd0;
B2_delay2<= 4'sd0; 
B3_delay1 <= 4'sd0;
B3_delay2 <= 4'sd0;
B3_delay3 <= 4'sd0;



for (i = 0 ; i < 4 ; i = i + 1)  
begin                            
                                 
for (j = 0 ; j < 4; j = j + 1)   
B_matrix[i][j] <= 4'sd0; 

        
end


end

// load 4x4 input matrix to A_matrix 
 else if (load_B)
begin

feed_count <= 0;

for (j = 0 ; j < 4 ; j= j + 1)
begin

B_matrix [0][j] <= B0[j];
B_matrix [1][j] <= B1[j];
B_matrix [2][j] <= B2[j];
B_matrix [3][j] <= B3[j];
end

end

else if (feed_B)

begin 

if(feed_count < 3'd7)
feed_count <= feed_count + 1;


B0_out <= (feed_count <= 3) ?  B_matrix[feed_count][0]: 4'sd0;


B1_out <= (feed_count <= 4) ?  B1_delay : 4'sd0;

B2_out <= (feed_count <= 5) ?  B2_delay2 : 4'sd0;
B2_delay2 <= B2_delay1;

B3_out <= (feed_count <= 6) ?  B3_delay3 : 4'sd0;
B3_delay3 <= B3_delay2;
B3_delay2 <= B3_delay1;


if (feed_count <= 3)
begin

// 1st column
B1_delay <= B_matrix [feed_count][1];


// 2nd column 
B2_delay1 <= B_matrix [feed_count][2];

// 3rd column

B3_delay1 <= B_matrix [feed_count][3];


end


end


end

endmodule


module BOOTH_MULTIPLICATION(

input signed [3:0] Multiplier, input signed [3:0] Multiplicand , 
output reg signed [7:0] PRODUCT
);

reg signed [3:0] Q, M;
reg signed [3:0] A;
reg q_1;
integer k;

parameter SHIFT_RIGHT_1 = 2'b00,
          ADD_SHIFT     = 2'b01 , 
          SUB_SHIFT     = 2'b10 ,
          SHIFT_RIGHT_2 = 2'b11;
          
        
always @(*)
begin
A = 4'sd0;
Q = Multiplier;
M = Multiplicand;
q_1 = 0;

for (k = 0; k < 4 ; k = k + 1)
begin
case({Q[0],q_1})
SHIFT_RIGHT_1 : {A, Q, q_1} = {{A[3],A[3:1]} , {A[0], Q[3:1]}, Q[0]}  ;
ADD_SHIFT :
begin
 A = A + M;
{A, Q, q_1} = {{A[3],A[3:1]} , {A[0], Q[3:1]}, Q[0]}  ;
end

SUB_SHIFT :
begin
 A = A - M;
{A, Q, q_1} = {{A[3],A[3:1]} , {A[0], Q[3:1]}, Q[0]}  ;
end

SHIFT_RIGHT_2 : {A, Q, q_1} = {{A[3],A[3:1]} , {A[0], Q[3:1]}, Q[0]} ;



endcase
end

PRODUCT = {A , Q};
end



endmodule




















