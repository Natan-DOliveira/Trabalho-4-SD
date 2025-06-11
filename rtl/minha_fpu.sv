/*
2+4+1+0+6+8+2+6+1=30
30 mod 4 = 2
X = 8 + 2
X = 10
Y = 31 - 10
Y = 21
*/

module minha_fpu
(
    input logic clock_100KHz,
    input logic reset,
    input logic [31:0] op_A_in,
    // [31]: Sinal | [30:21]: Expoente | [20:0]: Mantissa
    input logic [31:0] op_B_in,
    
    output logic flags_out,
    output logic [3:0] status_out,
    output logic [31:0] data_out,
);

    typedef enum [3:0]
    {
        ESPERA    = 4'b0000,
        EXACT     = 4'b0001,
        OVERFLOW  = 4'b0011, 
        UNDERFLOW = 4'b0111,
        INEXACT   = 4'b1111
    } state_status_out;
    
        // Sinais Internos
    state_status_out status;
    logic [9:0]  expoente_op_A;
    logic [9:0]  expoente_op_B;
    logic [20:0] mantissa_op_A;
    logic [20:0] mantissa_op_B;
    
        // Atribuições
    assign status_out = status;
    
    always_ff @(posedge clock_100KHz or posedge reset) begin
        if (!reset) begin
            status        <= ESPERA;
            expoente_op_A <= 10'b0;
            expoente_op_B <= 10'b0;
            mantissa_op_A <= 21'b0;
            mantissa_op_B <= 21'b0;
            data_out      <= 31'b0;
        end
        else begin
            
        end    
    end
    
endmodule
