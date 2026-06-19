`timescale 1ns / 1ps


module mac_2_systolic #(

parameter int H = 5, // input height
    parameter int W = 5, // input width
    parameter int R = 3, // kernel height
    parameter int S = 3,  //kernel width
    parameter int P = 0,  //padding = 0
    parameter int U = 1,

    parameter int E = ((H - R + 2*P)/U) + 1, // output height ---> 3
    parameter int F = ((W - S + 2*P)/U) + 1 //output width ---> 3
)(
    input  logic signed [7:0] A [H-1:0][W-1:0][2:0],
    input  logic signed [7:0] w [R-1:0][S-1:0][2:0],
    input  logic clk,
    input  logic rst_n,
    output reg signed [23:0] out [E-1:0][F-1:0]

    );
    
    integer i , j;
   logic signed [7:0] act_pipe_ch0 [0:2][0:2];
   
   logic signed [23:0] psum_pipe_ch0 [0:2][0:2];
   
   logic signed [7:0] act_pipe_ch1 [0:2][0:2];
   
   logic signed [23:0] psum_pipe_ch1 [0:2][0:2];
   
   logic signed [7:0] act_pipe_ch2 [0:2][0:2];
   
   logic signed [23:0] psum_pipe_ch2 [0:2][0:2];
   
  reg [1:0] row = 0;
  reg [1:0] col = 0;
  logic clr;
  
 parameter IDLE          = 3'b000  ;
 parameter LOAD_WINDOW   = 3'b001 ;
 parameter COMPUTE       = 3'b010 ;
 parameter STORE_RESULT  = 3'b011  ;
 parameter NEXT_WINDOW   = 3'b100  ;
 parameter DONE          = 3'b101  ;
 
 reg [2:0] state , next_state;
 reg [1:0] compute_count;
 
 always @(posedge clk)
 begin
 
if(!rst_n)
begin 
 
 state <= IDLE;
 row <= 0;
 col <= 0;
 compute_count <= 0;
 
 for(i=0;i<E;i=i+1)
  for(j=0;j<F;j=j+1)
   out[i][j] <= 0;
 
 for(i=0;i<3;i=i+1)
begin
    act_pipe_ch0[i][0] <= 0;
    act_pipe_ch0[i][1] <= 0;
    act_pipe_ch0[i][2] <= 0;

    act_pipe_ch1[i][0] <= 0;
    act_pipe_ch1[i][1] <= 0;
    act_pipe_ch1[i][2] <= 0;

    act_pipe_ch2[i][0] <= 0;
    act_pipe_ch2[i][1] <= 0;
    act_pipe_ch2[i][2] <= 0;
end
 
 
 
 
 
 end
 
 else
 begin
 
 state <= next_state;
case (state)

IDLE: 
begin
row <= 0;
col <= 0;
compute_count <= 0;
end


LOAD_WINDOW:
begin

compute_count <= 0;
//CHANNEL 0 
act_pipe_ch0[0][0] <= A[row][col][0];
act_pipe_ch0[0][1] <= A[row][col+1][0];
act_pipe_ch0[0][2] <= A[row][col+2][0] ;
                   
act_pipe_ch0[1][0] <= A[row+1][col][0];
act_pipe_ch0[1][1] <= A[row+1][col+1][0];
act_pipe_ch0[1][2] <= A[row+1][col+2][0] ;
                   
act_pipe_ch0[2][0] <= A[row+2][col][0];
act_pipe_ch0[2][1] <= A[row+2][col+1][0]  ;
act_pipe_ch0[2][2] <= A[row+2][col+2][0]  ;
        
  
  //channel 1
  act_pipe_ch1[0][0] <= A[row][col][1];         
  act_pipe_ch1[0][1] <= A[row][col+1][1];       
  act_pipe_ch1[0][2] <= A[row][col+2][1] ;      
                                           
  act_pipe_ch1[1][0] <= A[row+1][col][1];      
  act_pipe_ch1[1][1] <= A[row+1][col+1][1];    
  act_pipe_ch1[1][2] <= A[row+1][col+2][1] ;   
                                            
  act_pipe_ch1[2][0] <= A[row+2][col][1];     
  act_pipe_ch1[2][1] <= A[row+2][col+1][1]  ; 
  act_pipe_ch1[2][2] <= A[row+2][col+2][1]  ; 
  
  //channel 2
  act_pipe_ch2[0][0] <= A[row][col][2];         
  act_pipe_ch2[0][1] <= A[row][col+1][2];       
  act_pipe_ch2[0][2] <= A[row][col+2][2] ;      
                                        
  act_pipe_ch2[1][0] <= A[row+1][col][2];      
  act_pipe_ch2[1][1] <= A[row+1][col+1][2];    
  act_pipe_ch2[1][2] <= A[row+1][col+2][2] ;   
                                        
  act_pipe_ch2[2][0] <= A[row+2][col][2];     
  act_pipe_ch2[2][1] <= A[row+2][col+1][2]  ; 
  act_pipe_ch2[2][2] <= A[row+2][col+2][2]  ; 

 end
 
 COMPUTE :
 begin
 if (compute_count == 3)
 compute_count <= 0;

 else
 compute_count <= compute_count + 1;
end
 
 STORE_RESULT:
 begin
 
 out[row][col] <=  psum_pipe_ch0[2][0] +  psum_pipe_ch0[2][1] +   psum_pipe_ch0[2][2] +
                   psum_pipe_ch1[2][0] +  psum_pipe_ch1[2][1] +   psum_pipe_ch1[2][2] +
                   psum_pipe_ch2[2][0] +  psum_pipe_ch2[2][1] +   psum_pipe_ch2[2][2];
 
 
 end
 
 NEXT_WINDOW:
begin
    if(col == 2)
    begin
        col <= 0;

        if(row != 2)
            row <= row + 1;
    end
    else
    begin
        col <= col + 1;
    end
end
 

 endcase
 
 end
 end
 
 
 assign clr = (state == NEXT_WINDOW);
 
 always @(*)
 begin
 
 next_state = state;
 case(state)
 IDLE : next_state = LOAD_WINDOW;
 LOAD_WINDOW : next_state = COMPUTE;
 COMPUTE:
 begin
 if (compute_count == 3)
 next_state = STORE_RESULT;

else
next_state = COMPUTE;

 end
 

 NEXT_WINDOW:
begin
    if(row == 2 && col == 2)
        next_state = DONE;
    else
        next_state = LOAD_WINDOW;
end


STORE_RESULT:
begin
    if(row == 2 && col == 2)
        next_state = DONE;
    else
        next_state = NEXT_WINDOW;
end

DONE:
    next_state = DONE;
    
   
 endcase
 
 end
 
 
    
    // CHANNEL 0
PE pe00_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[0][0]) , .weight(w[0][0][0]), .sum_in(24'h000000), .sum_out(psum_pipe_ch0[0][0]));
PE pe01_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[0][1]) , .weight(w[0][1][0]), .sum_in(24'h000000), .sum_out(psum_pipe_ch0[0][1]));
PE pe02_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[0][2]) , .weight(w[0][2][0]), .sum_in(24'h000000), .sum_out(psum_pipe_ch0[0][2])); 
                                                                   
PE pe10_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[1][0]) , .weight(w[1][0][0]), .sum_in(psum_pipe_ch0[0][0]), .sum_out(psum_pipe_ch0[1][0]));
PE pe11_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[1][1]) , .weight(w[1][1][0]), .sum_in(psum_pipe_ch0[0][1]), .sum_out(psum_pipe_ch0[1][1]));
PE pe12_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[1][2]) , .weight(w[1][2][0]), .sum_in(psum_pipe_ch0[0][2]), .sum_out(psum_pipe_ch0[1][2])); 
                                    
PE pe20_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[2][0]) , .weight(w[2][0][0]), .sum_in(psum_pipe_ch0[1][0]), .sum_out(psum_pipe_ch0[2][0]));
PE pe21_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[2][1]) , .weight(w[2][1][0]), .sum_in(psum_pipe_ch0[1][1]), .sum_out(psum_pipe_ch0[2][1]));
PE pe22_ch0(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch0[2][2]) , .weight(w[2][2][0]), .sum_in(psum_pipe_ch0[1][2]), .sum_out(psum_pipe_ch0[2][2]));  
                                   
                                   
// CHANNEL 1                        
PE pe00_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[0][0]) , .weight(w[0][0][1]), .sum_in(24'h000000), .sum_out(psum_pipe_ch1[0][0]));
PE pe01_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[0][1]) , .weight(w[0][1][1]), .sum_in(24'h000000), .sum_out(psum_pipe_ch1[0][1]));
PE pe02_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[0][2]) , .weight(w[0][2][1]), .sum_in(24'h000000), .sum_out(psum_pipe_ch1[0][2])); 
                                                                               
PE pe10_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[1][0]) , .weight(w[1][0][1]), .sum_in(psum_pipe_ch1[0][0]), .sum_out(psum_pipe_ch1[1][0]));
PE pe11_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[1][1]) , .weight(w[1][1][1]), .sum_in(psum_pipe_ch1[0][1]), .sum_out(psum_pipe_ch1[1][1]));
PE pe12_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[1][2]) , .weight(w[1][2][1]), .sum_in(psum_pipe_ch1[0][2]), .sum_out(psum_pipe_ch1[1][2])); 
                                                                                                            
PE pe20_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[2][0]) , .weight(w[2][0][1]), .sum_in(psum_pipe_ch1[1][0]), .sum_out(psum_pipe_ch1[2][0]));
PE pe21_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[2][1]) , .weight(w[2][1][1]), .sum_in(psum_pipe_ch1[1][1]), .sum_out(psum_pipe_ch1[2][1]));
PE pe22_ch1(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch1[2][2]) , .weight(w[2][2][1]), .sum_in(psum_pipe_ch1[1][2]), .sum_out(psum_pipe_ch1[2][2]));    
                                   
                                    
  //CHANNEL 2                       
PE pe00_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[0][0]) , .weight(w[0][0][2]), .sum_in(24'h000000), .sum_out(psum_pipe_ch2[0][0]));
PE pe01_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[0][1]) , .weight(w[0][1][2]), .sum_in(24'h000000), .sum_out(psum_pipe_ch2[0][1]));
PE pe02_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[0][2]) , .weight(w[0][2][2]), .sum_in(24'h000000), .sum_out(psum_pipe_ch2[0][2])); 
                                                                              
PE pe10_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[1][0]) , .weight(w[1][0][2]), .sum_in(psum_pipe_ch2[0][0]), .sum_out(psum_pipe_ch2[1][0]));
PE pe11_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[1][1]) , .weight(w[1][1][2]), .sum_in(psum_pipe_ch2[0][1]), .sum_out(psum_pipe_ch2[1][1]));
PE pe12_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[1][2]) , .weight(w[1][2][2]), .sum_in(psum_pipe_ch2[0][2]), .sum_out(psum_pipe_ch2[1][2])); 
                                                                                                                                       
PE pe20_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[2][0]) , .weight(w[2][0][2]), .sum_in(psum_pipe_ch2[1][0]), .sum_out(psum_pipe_ch2[2][0]));
PE pe21_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[2][1]) , .weight(w[2][1][2]), .sum_in(psum_pipe_ch2[1][1]), .sum_out(psum_pipe_ch2[2][1]));
PE pe22_ch2(.clk(clk),.rst_n(rst_n),.clr(clr), .act_in(act_pipe_ch2[2][2]) , .weight(w[2][2][2]), .sum_in(psum_pipe_ch2[1][2]), .sum_out(psum_pipe_ch2[2][2]));
                                    
  
 
endmodule

module PE(
    input  logic clk,
    input  logic rst_n,
    input logic clr, 
    input  logic signed [7:0] act_in,
    input  logic signed [7:0] weight,
    input  logic signed [23:0] sum_in,
    output reg signed [23:0] sum_out
);

always @(posedge clk)
begin
    if(!rst_n || clr )
    begin
        sum_out <= 24'd0;
       
        end
    else
    begin
        sum_out <= sum_in + act_in * weight;
       
end
end

endmodule
