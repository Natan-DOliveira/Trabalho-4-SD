`timescale 1ns/1ps

module tb_minha_fpu;

    logic        clock_100KHz;
    logic        reset;
    logic [3:0]  status_out;
    logic [31:0] op_A_in;
    logic [31:0] op_B_in;
    logic [31:0] data_out;

    minha_fpu DUT (.*);

    always #5 clock_100KHz = ~clock_100KHz;

    initial begin
        $monitor("Tempo: %t | Estado: %s | op_A_in: %h | op_B_in: %h | data_out: %h | status_out: %b | status(interno): %s | Sinal data_out: %h | Expoente data_out: %h | Mantissa data_out: %h",
                 $time, DUT.state.name, op_A_in, op_B_in, data_out, status_out, DUT.status.name, DUT.sinal_data_out, DUT.expoente_data_out, DUT.mantissa_data_out);

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
        op_A_in = 32'h20000000;                 // 1.5 (expoente 256)
        op_B_in = 32'h20000000;                 // 1.5
        #100;

            // Teste 2: Soma 0.0 + 2.0 = 2.0
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 2: Soma 0.0 + 2.0 = 2.0 ---");
        op_A_in = 32'h00000000;                 // 0.0
        op_B_in = 32'h20200000;                 // 2.0 (expoente 257)
        #40;

            // Teste 3: Soma 4.0 + 1.5 = 5.5
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 3: Soma 4.0 + 1.5 = 5.5 ---");
        op_A_in = 32'h20400000;                 // 4.0 (expoente 258)
        op_B_in = 32'h20000000;                 // 1.5 (expoente 256)
        #100;

            // Teste 4: Soma 2^512 + 2^512 = ∞ (overflow)
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 4: Soma 2^512 + 2^512 = ∞ ---");
        op_A_in = 32'h7FE00000;                 // 2^512 (expoente 1023)
        op_B_in = 32'h7FE00000;                 // 2^512
        #30;

            // Teste 5: Soma 2^-255 + 2^-255 = 2^-254
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 5: Soma 2^-255 + 2^-255 = 2^-254 ---");
        op_A_in = 32'h1FE00000;                 // 2^-255 (expoente 256)
        op_B_in = 32'h1FE00000;                 // 2^-255
        #100;

            // Teste 6: Subtração 2.0 - 2.0 = 0.0
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 6: Subtração 2.0 - 2.0 = 0.0 ---");
        op_A_in = 32'h20200000;                 // 2.0 (expoente 257)
        op_B_in = 32'h20200000;                 // 2.0
        #100;

            // Teste 7: Subtração 4.0 - 1.5 = 2.5
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 7: Subtração 4.0 - 1.5 = 2.5 ---");
        op_A_in = 32'h20200000;                 // 4.0 (expoente 258)
        op_B_in = 32'h20000000;                 // 1.5 (expoente 256)
        #90;

            // Teste 8: Subtração -2.0 - 2.0 = 0.0
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 8: Subtração -2.0 - 2.0 = 0.0 ---");
        op_A_in = 32'hA0200000;                 // -2.0 (expoente 257)
        op_B_in = 32'h20200000;                 // 2.0
        #90;

            // Teste 9: Subtração 2^512 - 2.0 = 2^512
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 9: Subtração 2^512 - 2.0 = 2^512 ---");
        op_A_in = 32'h7FE00000;                 // 2^512 (expoente 1023)
        op_B_in = 32'h20200000;                 // 2.0 (expoente 257)
        #30;

            // Teste 10: Subtração 2^-255 - 2^-256 = 2^-256
        reset = 0; #10;
        reset = 1;
        $display("\n--- Teste 10: Subtração 2^-255 - 2^-256 = 2^-256 ---");
        op_A_in = 32'h1FE00000;                 // 2^-255 (expoente 256)
        op_B_in = 32'h1FC00000;                 // 2^-256 (expoente 255)
        #90;
    end
endmodule