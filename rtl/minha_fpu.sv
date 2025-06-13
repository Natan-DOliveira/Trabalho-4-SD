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
    
    output logic [3:0] status_out,
    output logic [31:0] data_out,
);

    typedef enum [3:0]
    {
        ESPERA    = 4'b0000,
        EXACT     = 4'b0001,
        OVERFLOW  = 4'b0010, 
        UNDERFLOW = 4'b0100,
        INEXACT   = 4'b1000
    } state_status_out;
    
    	// FSM
    typedef enum [2:0]
    { 
        EXTRAI    = 3'b000,
        ALINHA    = 3'b001,
        OPERACAO  = 3'b010,
        ARREDONDA = 3'b011,
        VERIFICA  = 3'b100,
        OUTPUT    = 3'b101        
    } state_fsm;
    
        // Sinais Internos
    state_fsm state;
    state_status_out status;
    logic sinal_op_A;
    logic sinal_op_B;
    logic sinal_data_out;
    logic [9:0] expoente_op_A;
    logic [9:0] expoente_op_B;
    logic [9:0] expoente_data_out;
    logic [9:0] diferenca_expoente;
    logic [20:0] mantissa_op_A;
    logic [20:0] mantissa_op_B;
    logic [20:0] mantissa_data_out;
    
        // Atribuições
    assign status_out = status;
    
    always_ff @(posedge clock_100KHz or negedge reset) begin
        if (!reset) begin
            state         <= EXTRAI;
            status        <= ESPERA;
            sinal_op_A    <= 1'b0;
            sinal_op_B    <= 1'b0;
            expoente_op_A <= 10'b0;
            expoente_op_B <= 10'b0;
            mantissa_op_A <= 21'b0;
            mantissa_op_B <= 21'b0;
            data_out      <= 31'b0;
        end
        else begin
            case (state)
            
                    // ARRUMAR
                EXTRAI: begin
                    if (op_A_in != 32'b0 && op_B_in != 32'b0) begin
                        sinal_op_A    <= op_A_in[31];
                        expoente_op_A <= op_A_in[30:21];
                        mantissa_op_A <= op_A_in[20:0];
                        sinal_op_B    <= op_B_in[31];
                        expoente_op_B <= op_B_in[30:21];
                        mantissa_op_B <= op_B_in[20:0];
                        state <= ALINHA;
                    end
                end
                
                ALINHA: begin
                    if (expoente_op_A == expoente_op_B) begin
                        state <= OPERACAO;
                    end
                    else begin
                        if (expoente_op_A > expoente_op_B) begin
                            diferenca_expoente <= expoente_op_A - expoente_op_B;
                            mantissa_op_A  << 
                        end
                        else begin
                            diferenca_expoente <= expoente_op_B - expoente_op_A;
                        end
                    end
                end
                
                OPERACAO: begin
                    if (sinal_op_A == sinal_op_B) begin
                        sinal_data_out <= sinal_op_A;
                        mantissa_data_out <= mantissa_op_A + mantissa_op_B;
                    end
                    else begin
                        if ( > )
                        end
                        else begin
                    
                    end
                end
                
                ARREDONDA: begin
                
                
                end
                
                VERIFICA: begin
                
                end
                
                OUTPUT: begin
                
                end
                
            endcase
        end    
    end
    
endmodule
