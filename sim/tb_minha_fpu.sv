`timescale 1ns/1ps

module tb_minha_fpu;

    logic clock_100KHz;
    logic reset;
    logic [3:0] status_out;
    logic [31:0] op_A_in;
    logic [31:0] op_B_in;
    logic [31:0] data_out;

    minha_fpu DUT (.*);
    
    always #5 clock_100KHz = ~clock_100KHz;
    
    initial begin
    	clock_100KHz = 0;
    	reset        = 0;
    	op_A_in      = 32'h000000;
    	op_B_in      = 32'h000000;
    	#5;
    	    // CASO 1: 1 + 1
    	reset        = 1;
    	op_A_in      = {1'b0, 10'h1FF, 21'h000000};
    	op_B_in      = {1'b0, 10'h1FF, 21'h000000};
    	#100;    
    end

endmodule
