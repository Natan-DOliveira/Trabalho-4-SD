`timescale 1ns/1ps

module tb_minha_fpu;

    logic        clock_100KHz;
    logic        reset;
    logic [3:0]  status_out;
    logic [31:0] op_A_in;
    logic [31:0] op_B_in;
    logic [31:0] data_out;

    minha_fpu DUT (.*);

    // Clock de 100 kHz (período = 10 us = 10000 ns)
    always #5 clock_100KHz = ~clock_100KHz;

    initial begin
        $monitor("Tempo: %t | Estado: %s | op_A_in: %h | op_B_in: %h | data_out: %h | status_out: %b | status(interno): %s",
                 $time, DUT.state.name, op_A_in, op_B_in, data_out, status_out, DUT.status.name);

        // Inicialização
        clock_100KHz = 0;
        reset        = 0;
        op_A_in      = 32'h00000000;
        op_B_in      = 32'h00000000;
        #10; 
        reset = 1;

        // Teste 1: Soma 1.5 + 1.5 = 3.0
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 1: Soma 1.5 + 1.5 = 3.0 ---");
        op_A_in = {1'b0, 10'h100, 21'h400000}; // +2^0 * 1.5
        op_B_in = {1'b0, 10'h100, 21'h400000}; // +2^0 * 1.5
        #300;

        // Teste 2: Soma 2.0 + 0.0 = 2.0
        $display("\n--- Teste 2: Soma 2.0 + 0.0 = 2.0 ---");
        reset = 0; #10;
        reset = 1;
        op_A_in = {1'b0, 10'h100, 21'h800000}; // +2^0 * 2.0
        op_B_in = {1'b0, 10'h000, 21'h000000}; // 0.0
        #35;

        // Teste 3: Soma (~2^511*2) + (~2^511*2) = +Infinito
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 3: Soma (~2^511*2) + (~2^511*2) = +Infinito ---");
        op_A_in = {1'b0, 10'h3FE, 21'h7FFFFF}; // +2^511 * ~2.0
        op_B_in = {1'b0, 10'h3FE, 21'h7FFFFF}; // +2^511 * ~2.0
        #95;

        // Teste 4: Soma 2.0 + (-1.0) = 1.0
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 4: Soma 2.0 + (-1.0) = 1.0 ---");
        op_A_in = {1'b0, 10'h100, 21'h800000}; // +2^0 * 2.0
        op_B_in = {1'b1, 10'h100, 21'h000000}; // -2^0 * 1.0
        #95;

        // Teste 5: Soma ~2.0 + ~1.0000005 = ~2.0 (INEXACT)
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 5: Soma ~2.0 + ~1.0000005 = ~2.0 ---");
        op_A_in = {1'b0, 10'h100, 21'h7FFFFF}; // +2^0 * ~2.0
        op_B_in = {1'b0, 10'h100, 21'h000001}; // +2^0 * ~1.0000005
        #95;

        // Teste 6: Subtração 1.5 - 1.5 = 0.0
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 6: Subtracao 1.5 - 1.5 = 0.0 ---");
        op_A_in = {1'b0, 10'h100, 21'h400000}; // +2^0 * 1.5
        op_B_in = {1'b1, 10'h100, 21'h400000}; // -2^0 * 1.5
        #95;

        // Teste 7: Subtração (~2^-511*1.0000005) - (~2^-511*1.0000005) = 0.0
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 7: Subtracao (~2^-511*1.0000005) - (~2^-511*1.0000005) = 0.0 ---");
        op_A_in = {1'b0, 10'h001, 21'h000001}; // +2^-511 * ~1.0000005
        op_B_in = {1'b1, 10'h001, 21'h000001}; // -2^-511 * ~1.0000005
        #95;

        // Teste 8: Subtração 2.0 - 0.5 = 1.5
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 8: Subtracao 2.0 - 0.5 = 1.5 ---");
        op_A_in = {1'b0, 10'h100, 21'h800000}; // +2^0 * 2.0
        op_B_in = {1'b1, 10'h0FF, 21'h800000}; // -2^-1 * 2.0 = -0.5
        #95;

        // Teste 9: Subtração Infinito - 2.0 = Infinito
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 9: Subtracao Infinito - 2.0 = Infinito ---");
        op_A_in = {1'b0, 10'h3FF, 21'h000000}; // +Infinito
        op_B_in = {1'b1, 10'h100, 21'h800000}; // -2^0 * 2.0
        #35;

        // Teste 10: Subtração Infinito - Infinito = NaN
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 10: Subtracao Infinito - Infinito = NaN ---");
        op_A_in = {1'b0, 10'h3FF, 21'h000000}; // +Infinito
        op_B_in = {1'b1, 10'h3FF, 21'h000000}; // -Infinito
        #35;

        #10;
        $finish;
    end
endmodule