module aclock (
 input reset, 
 input clk,  
 input [1:0] H_in1,  
 input [3:0] H_in0,  
 input [3:0] M_in1,  
 input [3:0] M_in0,  
 input LD_time,  
 input LD_alarm,  
 input STOP_al,  
 input AL_ON,  
 output reg Alarm,  
 output [1:0]  H_out1,  
 output [3:0]  H_out0,  
 output [3:0]  M_out1,  
 output [3:0]  M_out0,  
 output [3:0]  S_out1,  
 output [3:0]  S_out0  
 );

 reg clk_1s; 
 reg [3:0] tmp_1s; 
 reg [5:0] tmp_hour, tmp_minute, tmp_second; 
 reg [1:0] c_hour1,a_hour1;  
 reg [3:0] c_hour0,a_hour0; 
 reg [3:0] c_min1,a_min1; 
 reg [3:0] c_min0,a_min0; 
 reg [3:0] c_sec1,a_sec1; 
 reg [3:0] c_sec0,a_sec0; 
 
 function [3:0] mod_10;
 input [5:0] number;
 begin
 mod_10 = (number >=50) ? 5 : ((number >= 40)? 4 :((number >= 30)? 3 :((number >= 20)? 2 :((number >= 10)? 1 :0))));
 end
 endfunction
 
 always @(posedge clk_1s or posedge reset )
 begin
 if(reset) begin 
 a_hour1 <= 2'b00;
 a_hour0 <= 4'b0000;
 a_min1 <= 4'b0000;
 a_min0 <= 4'b0000;
 a_sec1 <= 4'b0000;
 a_sec0 <= 4'b0000;
 tmp_hour <= H_in1*10 + H_in0;
 tmp_minute <= M_in1*10 + M_in0;
 tmp_second <= 0;
 end 
 else begin
 if(LD_alarm) begin 
 a_hour1 <= H_in1;
 a_hour0 <= H_in0;
 a_min1 <= M_in1;
 a_min0 <= M_in0;
 a_sec1 <= 4'b0000;
 a_sec0 <= 4'b0000;
 end 
 if(LD_time) begin 
 tmp_hour <= H_in1*10 + H_in0;
 tmp_minute <= M_in1*10 + M_in0;
 tmp_second <= 0;
 end 
 else begin  
 tmp_second <= tmp_second + 1;
 if(tmp_second >=59) begin 
 tmp_minute <= tmp_minute + 1;
 tmp_second <= 0;
 if(tmp_minute >=59) begin 
 tmp_minute <= 0;
 tmp_hour <= tmp_hour + 1;
 if(tmp_hour >= 24) begin 
 tmp_hour <= 0;
 end 
 end 
 end

 end 
 end 
 end 
 
 always @(posedge clk or posedge reset)
 begin
 if(reset) 
 begin
 tmp_1s <= 0;
 clk_1s <= 0;
 end
 else begin
 tmp_1s <= tmp_1s + 1;
 if(tmp_1s <= 5) 
 clk_1s <= 0;
 else if (tmp_1s >= 10) begin
 clk_1s <= 1;
 tmp_1s <= 1;
 end
 else
 clk_1s <= 1;
 end
 end
 
 always @(*) begin

 if(tmp_hour>=20) begin
 c_hour1 = 2;
 end
 else begin
 if(tmp_hour >=10) 
 c_hour1  = 1;
 else
 c_hour1 = 0;
 end
 c_hour0 = tmp_hour - c_hour1*10; 
 c_min1 = mod_10(tmp_minute); 
 c_min0 = tmp_minute - c_min1*10;
 c_sec1 = mod_10(tmp_second);
 c_sec0 = tmp_second - c_sec1*10; 
 end
 
 assign H_out1 = c_hour1;  
 assign H_out0 = c_hour0;  
 assign M_out1 = c_min1;  
 assign M_out0 = c_min0;  
 assign S_out1 = c_sec1;  
 assign S_out0 = c_sec0;  

 always @(posedge clk_1s or posedge reset) begin
 if(reset) 
 Alarm <=0; 
 else begin
 if({a_hour1,a_hour0,a_min1,a_min0,a_sec1,a_sec0}=={c_hour1,c_hour0,c_min1,c_min0,c_sec1,c_sec0})
 begin 
 if(AL_ON) Alarm <= 1; 
 end
 if(STOP_al) Alarm <=0; 
 end
 end
 
endmodule 

module test;

 reg reset;
 reg clk;
 reg [1:0] H_in1;
 reg [3:0] H_in0;
 reg [3:0] M_in1;
 reg [3:0] M_in0;
 reg LD_time;
 reg LD_alarm;
 reg STOP_al;
 reg AL_ON;

 wire Alarm;
 wire [1:0] H_out1;
 wire [3:0] H_out0;
 wire [3:0] M_out1;
 wire [3:0] M_out0;
 wire [3:0] S_out1;
 wire [3:0] S_out0;

 aclock uut (
 .reset(reset), 
 .clk(clk), 
 .H_in1(H_in1), 
 .H_in0(H_in0), 
 .M_in1(M_in1), 
 .M_in0(M_in0), 
 .LD_time(LD_time), 
 .LD_alarm(LD_alarm), 
 .STOP_al(STOP_al), 
 .AL_ON(AL_ON), 
 .Alarm(Alarm), 
 .H_out1(H_out1), 
 .H_out0(H_out0), 
 .M_out1(M_out1), 
 .M_out0(M_out0), 
 .S_out1(S_out1), 
 .S_out0(S_out0)
 );
 
 initial begin 
  clk = 0;
  forever #50 clk = ~clk;
 end
 
 initial begin
    $dumpfile("aclock.vcd");
    $dumpvars(0, test);
    
    reset = 1;
    H_in1 = 1;
    H_in0 = 0;
    M_in1 = 1;
    M_in0 = 4;
    LD_time = 0;
    LD_alarm = 0;
    STOP_al = 0;
    AL_ON = 0;
    
    #1000;
    reset = 0;
    H_in1 = 1;
    H_in0 = 0;
    M_in1 = 2;
    M_in0 = 0;
    LD_time = 0;
    LD_alarm = 1;
    STOP_al = 0;
    AL_ON = 1;
    #1000; 
    reset = 0;
    H_in1 = 1;
    H_in0 = 0;
    M_in1 = 2;
    M_in0 = 0;
    LD_time = 0;
    LD_alarm = 0;
    STOP_al = 0;
    AL_ON = 1; 
    wait(Alarm);
    #1000
    STOP_al = 1;
    #1000
    STOP_al = 0;
    H_in1 = 0;
    H_in0 = 4;
    M_in1 = 4;
    M_in0 = 5;
    LD_time = 1;
    LD_alarm = 0;
    #1000
    STOP_al = 0;
    H_in1 = 0;
    H_in0 = 4;
    M_in1 = 5;
    M_in0 = 5;
    LD_alarm = 1;
    LD_time = 0;
    wait(Alarm);
    #1000
    STOP_al = 1;
    #1000;
    $finish;
 end
endmodule
