`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2017 06:38:45 PM
// Design Name: 
// Module Name: controller
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


module controller(
    input clk,
    input rx,
    output tx,
    output [6:0]seg,
    output reg [3:0]an
    );
    
    reg [63:0] tx_data;
    wire [7:0] tx_output;
    reg tx_valid = 0;
    wire tx_active;
    reg prev_tx_active = 0;
    wire tx_ready;
    reg [63:0] rx_data;
    wire [7:0] rx_input;
    wire rx_valid;
    reg prev_rx_valid = 0;
    reg rx_ready = 1;
    
    reg [2:0]in_byte_count = 0;
    reg [10:0]out_byte_count = 0;
    
    assign tx_output = tx_data[7:0];
    
    uart_rx URX(clk, rx, rx_valid, rx_input);
    uart_tx UTX(clk, tx_valid, tx_output, tx_active, tx, tx_ready);
    
    reg [10:0] seg_clock;
    reg [10:0] shown_secret;
    reg [17:0] shown_cipher;
    reg [17:0] output_off;
    reg [17:0] output_off_2;
    
    reg [63:0] plaintext;
    reg [55:0] key = 56'hacce551;
    wire [63:0] ciphertext;
    des DES(ciphertext, plaintext, key, 0, 0, clk);
    reg ready_to_encode = 0;
    
    reg [16:0] output_byte_count = 0;
    reg [3:0] output_byte;
    
    seg7 SEG7(output_byte, seg, clk);
    
    always @(posedge clk) begin
        if (ready_to_encode) begin
            tx_data <= ciphertext;
            out_byte_count <= 7;
            tx_valid <= 1;
            ready_to_encode <= 0;
        end
    
        //Load in a byte from the rx when rx_valid goes high
        if (~prev_rx_valid && rx_valid) begin
            rx_data <= (rx_data << 8) | rx_input;
            in_byte_count <= in_byte_count + 1;
            
            if (in_byte_count == 7) begin
                plaintext <= rx_data;
                ready_to_encode <= 1;
            end
        end
        
        prev_rx_valid <= rx_valid;

        //Send the next byte over the tx when the tx_active goes low
        if (prev_tx_active && ~tx_active) begin
            tx_data <= (tx_data >> 8);
            out_byte_count <= out_byte_count - 1;
            
            //Stop transmitting after sending all data
            if (out_byte_count == 0) begin
                tx_valid <= 0;
            end
        end
        
        prev_tx_active <= tx_active;
        
        seg_clock <= seg_clock + 1;
    end
    
    always @(posedge seg_clock[10]) begin
        if (output_off >= 20000 && shown_secret < 5 && plaintext == 64'hcab00d1e) begin
            output_byte <= (key ^ ciphertext) >> (output_byte_count << 2);
//            output_byte <= 3;
//            seg <= 0;
            
            an <= 4'b1110;
            shown_secret <= shown_secret + 1;
        end
        else if (shown_cipher < 80000) begin
//            seg <= 7'b1111111;
//            seg <= output_byte;            
            an <= 4'b1110;
            if (output_byte_count == 16) begin
                output_byte <= 8;
            end
            else begin
                output_byte <= ciphertext >> (output_byte_count << 2);
            end
            shown_cipher <= shown_cipher + 1;
        end
        else if (output_off < 20000) begin
            an <= 4'b1111;
            output_off <= output_off + 1;
            
            if (shown_secret == 0) begin
                output_byte_count <= output_byte_count + 1;
            end
            
            if (output_byte_count == 17) begin
                output_byte_count <= 0;
            end
        end
        else if (output_off_2 < 20000) begin
            an <= 4'b1111;
            output_off_2 <= output_off_2 + 1;
        end
        else begin
            shown_secret <= 0;
            shown_cipher <= 0;
            output_off <= 0;
            output_off_2 <= 0;
        end
    end
endmodule