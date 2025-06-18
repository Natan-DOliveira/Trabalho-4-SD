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

    typedef enum logic [3:0]
    {
        ESPERA    = 4'b0000,
        EXACT     = 4'b0001,                    // Resultado EXATO
        OVERFLOW  = 4'b0010,                    // Resultado excede o expoente máximo de 10'h3FF
        UNDERFLOW = 4'b0100,                    // Resultado é muito pequeno
        INEXACT   = 4'b1000                     // Resultado foi arredondado
    } state_status_out;
    
    	// FSM
    typedef enum logic [3:0]
    {
        EXTRAI    = 3'b000,                     // EXTRAI os valores e coloca nos operadores
        DIFERENCA = 3'b001,                     // calcula a DIFERENCA dos expoentes
        ALINHA    = 3'b010,                     // ALINHA as mantissas
        OPERACAO  = 3'b011,                     // realiza a OPERACAO de soma ou subtração
        NORMALIZA = 3'b100,                     // NORMALIZA o resultado
        ARREDONDA = 3'b101,                     // ARREDONDA o resultado
        VERIFICA  = 3'b110,                     // VERIFICA overflow, underflow e inexact
        SAIDA     = 3'b111                      // SAÍDA dos valores
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
    logic [21:0] mantissa_op_A;
    logic [21:0] mantissa_op_B;
    logic [22:0] mantissa_data_out;
    
        // Atribuições
    assign status_out = status;
    
    always_ff @(posedge clock_100KHz or negedge reset) begin
        if (!reset) begin
            state             <= EXTRAI;
            status            <= ESPERA;
            sinal_op_A        <= 1'b0;
            sinal_op_B        <= 1'b0;
            expoente_op_A     <= 10'b0;
            expoente_op_B     <= 10'b0;
            expoente_data_out <= 10'b0;
            mantissa_op_A     <= 22'b0;
            mantissa_op_B     <= 22'b0;
            mantissa_data_out <= 23'b0;
            data_out          <= 32'b0;
        end
        else begin
            case (state)

                EXTRAI: begin
                    if (op_A_in != 32'b0 && op_B_in != 32'b0) begin
                        sinal_op_A    <= op_A_in[31];
                        expoente_op_A <= op_A_in[30:21];
                        mantissa_op_A <= {1'b1, op_A_in[20:0]};
                        sinal_op_B    <= op_B_in[31];
                        expoente_op_B <= op_B_in[30:21];
                        mantissa_op_B <= {1'b1, op_B_in[20:0]};
                        state <= DIFERENCA;
                    end
                end

                DIFERENCA: begin
                    if (expoente_op_A >= expoente_op_B) begin
                        expoente_data_out  <= expoente_op_A;
                        diferenca_expoente <= expoente_op_A - expoente_op_B;
                    end
                    else begin
                        expoente_data_out  <= expoente_op_B;
                        diferenca_expoente <= expoente_op_B - expoente_op_A;
                            // Troca o operando A pelo B (para facilitar as operações)
                        mantissa_op_A <= mantissa_op_B;
                        mantissa_op_B <= {1'b1, op_A_in[20:0]};
                        sinal_op_A <= sinal_op_B;
                        sinal_op_B <= op_A_in[31];
                    end
                    state <= ALINHA;
                end
                
                ALINHA: begin
                        // UNDERFLOW
                    if (diferenca_expoente > 22) begin
                        state             <= SAIDA;
                        status            <= UNDERFLOW;
                        sinal_data_out    <= sinal_op_A
                        mantissa_data_out <= mantissa_op_A;
                    end
                    else begin
                        state         <= OPERACAO;
                        mantissa_op_B <= mantissa_op_B >> diferenca_expoente;
                    end
                end
                
                OPERACAO: begin
                        // Soma
                    if (sinal_op_A == sinal_op_B) begin
                        sinal_data_out    <= sinal_op_A;
                        mantissa_data_out <= mantissa_op_A + mantissa_op_B;
                    end
                        // Subtração
                    else begin
                        if (mantissa_op_A >= mantissa_op_B) begin
                            sinal_data_out    <= sinal_op_A;
                            mantissa_data_out <= mantissa_op_A - mantissa_op_B;
                        end
                        else begin
                            sinal_data_out    <= sinal_op_B;
                            mantissa_data_out <= mantissa_op_B - mantissa_op_A;
                        end
                    end
                    state <= NORMALIZA;
                end

                NORMALIZA: begin
                    state <= ARREDONDA;
                end
                
                ARREDONDA: begin
                    if (mantissa_data_out[0] == 1'b1) begin
                        status      <= INEXACT;
                        mantissa_data_out[21:1] <= mantissa_data_out[21:1] + 1;
                    end
                    mantissa_data_out <= mantissa_data_out[21:1];
                    state <= VERIFICA;
                end
                
                VERIFICA: begin
                    if (expoente_data_out > 10'h3FF) begin
                        status   <= OVERFLOW;
                        data_out <= {sinal_data_out, 10'h3FF, 21'h0};
                    end
                    else if (expoente_data_out == 0 || mantissa_data_out == 0) begin
                        status   <= UNDERFLOW;
                        data_out <= 32'h0;
                    end
                    else if (status != INEXACT) begin
                        status   <= EXACT;
                    end
                end
                
                SAIDA: begin
                    state      <= EXTRAI;
                    data_out   <= {sinal_data_out, expoente_data_out, mantissa_data_out[20:0]};
                    status_out <= status;
                end
            endcase
        end    
    end
endmodule