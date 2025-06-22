module minha_fpu
(
    input logic clock_100KHz,
    input logic reset,
    input logic [31:0] op_A_in,                 // [31]: Sinal | [30:21]: Expoente | [20:0]: Mantissa
    input logic [31:0] op_B_in,                 // [31]: Sinal | [30:21]: Expoente | [20:0]: Mantissa
    
    output logic [3:0] status_out,
    output logic [31:0] data_out
);
        // Estados do status_out
    typedef enum logic [3:0]
    {
        ESPERA    = 4'b0000,
        EXACT     = 4'b0001,                    // Resultado EXATO
        OVERFLOW  = 4'b0010,                    // Resultado excede o expoente máximo de 10'h3FF
        UNDERFLOW = 4'b0100,                    // Resultado é muito pequeno
        INEXACT   = 4'b1000                     // Resultado foi arredondado
    } state_status_out;
    
    	// FSM da FPU
    typedef enum logic [3:0]
    {
        EXTRAI    = 4'b0000,                     // EXTRAI os valores e coloca nos operadores
        ESPECIAIS = 4'b0001,                     // verifica se alguns dos operandos tem um valor dos casos ESPECIAIS
        DIFERENCA = 4'b0010,                     // calcula a DIFERENCA dos expoentes
        ALINHA    = 4'b0011,                     // ALINHA as mantissas
        OPERACAO  = 4'b0100,                     // realiza a OPERACAO de soma ou subtração
        NORMALIZA = 4'b0101,                     // NORMALIZA o resultado, ajusta a mantissa e o expoente
        ARREDONDA = 4'b0110,                     // ARREDONDA o resultado
        VERIFICA  = 4'b0111,                     // VERIFICA overflow, underflow e inexact
        SAIDA     = 4'b1000                      // SAÍDA dos valores
    } state_fsm;
    
        // Sinais Internos
    state_fsm state;
    state_status_out status;
    logic saida_count;
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

    assign status_out = status;
    
    always_ff @(posedge clock_100KHz or negedge reset) begin
        if (!reset) begin
            state              <= EXTRAI;
            status             <= ESPERA;
            saida_count        <= 1'b0;
            sinal_op_A         <= 1'b0;
            sinal_op_B         <= 1'b0;
            sinal_data_out     <= 1'b0;
            expoente_op_A      <= 10'b0;
            expoente_op_B      <= 10'b0;
            expoente_data_out  <= 10'b0;
            diferenca_expoente <= 10'b0;
            mantissa_op_A      <= 22'b0;
            mantissa_op_B      <= 22'b0;
            mantissa_data_out  <= 23'b0;
            data_out           <= 32'b0;
        end
        else begin
            case (state)
                EXTRAI: begin
                    sinal_op_A    <= op_A_in[31];
                    expoente_op_A <= op_A_in[30:21];
                    mantissa_op_A <= {1'b1, op_A_in[20:0]};
                    sinal_op_B    <= op_B_in[31];
                    expoente_op_B <= op_B_in[30:21];
                    mantissa_op_B <= {1'b1, op_B_in[20:0]};
                    state <= ESPECIAIS;
                end

                ESPECIAIS: begin
                    if (op_A_in == 32'h0) begin
                        state             <= SAIDA;
                        status            <= EXACT;
                        sinal_data_out    <= sinal_op_B;
                        expoente_data_out <= expoente_op_B;
                        mantissa_data_out <= mantissa_op_B;
                    end 
                    else if (op_B_in == 32'h0) begin
                        state             <= SAIDA;
                        status            <= EXACT;
                        sinal_data_out    <= sinal_op_A;
                        expoente_data_out <= expoente_op_A;
                        mantissa_data_out <= mantissa_op_A;
                    end else if (op_A_in[30:21] == 10'h3FF || op_B_in[30:21] == 10'h3FF) begin
                        if (op_A_in[30:21] == 10'h3FF && op_A_in[20:0] != 21'h0) begin
                            state             <= SAIDA;
                            status            <= INEXACT;
                            sinal_data_out    <= 1'b0;
                            expoente_data_out <= 10'h3FF;
                            mantissa_data_out <= 21'h1;
                        end 
                        else if (op_B_in[30:21] == 10'h3FF && op_B_in[20:0] != 21'h0) begin
                            state             <= SAIDA;
                            status            <= INEXACT;
                            sinal_data_out    <= 1'b0;
                            expoente_data_out <= 10'h3FF;
                            mantissa_data_out <= 21'h1;
                        end 
                        else if (op_A_in[30:21] == 10'h3FF && op_B_in[30:21] == 10'h3FF && op_A_in[31] != op_B_in[31]) begin
                            state             <= SAIDA;
                            status            <= INEXACT;
                            sinal_data_out    <= 1'b0;
                            expoente_data_out <= 10'h3FF;
                            mantissa_data_out <= 21'h1;
                        end 
                        else begin
                            state    <= SAIDA;
                            status   <= OVERFLOW;
                            sinal_data_out    <= op_A_in[30:21] == 10'h3FF ? op_A_in[31] : op_B_in[31];
                            expoente_data_out <= 10'h3FF;
                            mantissa_data_out <= 21'h0;
                        end
                    end 
                    else begin
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
                        sinal_data_out    <= sinal_op_A;
                        mantissa_data_out <= mantissa_op_A[20:0];
                    end
                    else begin
                        state         <= OPERACAO;
                        mantissa_op_B <= mantissa_op_B >> diferenca_expoente;
                    end
                end
                
                OPERACAO: begin
                        // SOMA
                    if (sinal_op_A == sinal_op_B) begin
                        sinal_data_out    <= sinal_op_A;
                        mantissa_data_out <= mantissa_op_A + mantissa_op_B;
                    end
                        // SUBTRAÇÃO
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
                    if (mantissa_data_out[22] == 1'b1) begin
                        mantissa_data_out <= mantissa_data_out >> 1;
                        expoente_data_out <= expoente_data_out + 1;
                    end
                    else if (mantissa_data_out[21] == 1'b0 && mantissa_data_out != 0) begin
                        mantissa_data_out <= mantissa_data_out << 1;
                        expoente_data_out <= expoente_data_out - 1;
                    end
                    else begin
                        state <= ARREDONDA;
                    end
                end
                
                ARREDONDA: begin
                    if (mantissa_data_out[1] == 1'b1 && (mantissa_data_out[0] == 1'b1 || mantissa_data_out[22:2] != 21'h0)) begin
                        status                  <= INEXACT;
                        mantissa_data_out[22:2] <= mantissa_data_out[22:2] + 1;
                            // OVERFLOW
                        if (mantissa_data_out[22:2] + 1 == 21'h0) begin
                            mantissa_data_out <= {1'b1, 21'h0};
                            expoente_data_out <= expoente_data_out + 1;
                        end
                    end
                    else if (status != INEXACT) begin
                        status <= EXACT;
                    end
                    state             <= VERIFICA;
                    mantissa_data_out <= {1'b0, mantissa_data_out[22:2]};
                end
                
                VERIFICA: begin
                    if (expoente_data_out > 10'h3FF) begin
                        status            <= OVERFLOW;
                        sinal_data_out    <= sinal_data_out;
                        expoente_data_out <= 10'h3FF;
                        mantissa_data_out <= 23'h0;
                    end
                    else if (expoente_data_out == 0 || mantissa_data_out == 0) begin
                        status            <= UNDERFLOW;
                        sinal_data_out    <= 1'b0;
                        expoente_data_out <= 10'h0;
                        mantissa_data_out <= 23'h0;
                    end
                    else if (status != INEXACT) begin
                        status   <= EXACT;
                    end
                    state        <= SAIDA;
                end
                
                SAIDA: begin
                    saida_count <= saida_count + 1;
                    data_out    <= {sinal_data_out, expoente_data_out, mantissa_data_out[20:0]};
                end
            endcase
        end    
    end
endmodule