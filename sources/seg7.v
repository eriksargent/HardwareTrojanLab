`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2017 07:24:06 PM
// Design Name: 
// Module Name: seg7
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seg7(
    input [3:0] val,
    output reg [7:0] seg,
    input clk
    );
    
    always @(posedge clk) begin
        if(val == 0)
            seg <= 8'b11000000;
        else if (val == 1)
            seg <= 8'b11111001;
        else if (val == 2)
            seg <= 8'b10100100;      
        else if (val == 3)
            seg <= 8'b10110000;   
        else if (val == 4)
            seg <= 8'b10011001;
        else if (val == 5)
            seg <= 8'b10010010;
        else if (val == 6)
            seg <= 8'b10000010;
        else if (val == 7)
            seg <= 8'b11111000;
        else if (val == 8)
            seg <= 8'b10000000;
        else if (val == 9)
            seg <= 8'b10010000;
        else if (val == 10)
            seg <= 8'b10010000;
        else if (val == 11)
            seg <= 8'b10000011;
        else if (val == 12)
            seg <= 8'b11000011;
        else if (val == 13)
            seg <= 8'b10100010;
        else if (val == 14)
            seg <= 8'b10000110;
        else if (val == 15)
            seg <= 8'b10001110;
    end
    
endmodule
