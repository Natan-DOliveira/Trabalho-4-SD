# Trabalho 4 de Sistemas Digitais 
# Aritmética de Ponto Flutuante

## Feito por: Natan Duarte de Oliveira

## Estrutura do Projeto:
    ├── `rtl`/
    │   ├── minha_fpu.sv
    │
    ├── `sim`/
    │   ├── sim.do
    │   ├── tb_minha_fpu.sv
    |   ├── wave.do
    │
    ├── README.md

## Instruções de Execução:

### - Pelo Linux(Windows com MSYS2 MINGW64 deve funcionar igual):
    1. Entre na pasta ./sim
    2. Execute o comando `vsim -do sim.do`

### - Pelo Windows:
    1. Abra o Questa-Intel® FPGA Edition
    2. Selecione: File --> Change Directory...
    3. Escolha a pasta ./sim
    4. Pelo transcript execute o comando `do sim.do`

## Descrição:
Este trabalho realizado em SystemVerilog é composto pelo módulo `minha_fpu.sv` que implementa uma versão simplificada de uma `FPU` que realiza soma e subtração e é personalizada de acordo com o número da matricula, ou seja, cada aluno terá uma `mantissa` e `expoente` com tamanhos diferentes.

### Cálculo do tamanho da `expoente` e do `mantissa`:
A fórmula para se calcular o `expoente` é o somatório do números da matricula resto de 4, ou seja, `X = [8 (+/-) ∑b mod 4]`. O sinal é definido pelo dígito verificador, que no meu caso é ímpar, então é positivo. 

Para determinar o tamanho da `mantissa` temos que pegar o X e diminiur ele por 31, que é: `Y = 31 - X`.

#### Meu Cálculo:
22418606-1 --> 2+2+4+1+8+6+0+6+1 = 30 

30 % 4 = 2

X = 8  +  2 = 10 --> `expoente[9:0]: 10 bits`

Y = 31 - 10 = 21 --> `mantissa[20:0]: 21 bits`

## Módulo: `minha_fpu`
- A interface do módulo é a mostrada na imagem abaixo:
![Interface módulo minha_fpu](https://i.imgur.com/kYRE72m.png "Interface módulo minha_fpu")
- Entradas:
- - `Clock_100KHz`: Clock de 100 KHz;
- - `reset`: Reset assíncrono-baixo; 
- - `op_A_in`: Operando A de 32 bits que é codificado da seguinte maneira: `[31]: sinal`; `[30:21]: expoente`; `[20:0]: mantissa`;
- - `op_B_in`: Operando B de 32 bits codificado igual ao `op_A_in`;
- Saídas:
- - `data_out`: Resultado da operação de 32 bits com mesma codificação que ambos os operadores;
- - `status_out`: 4 bits, em estilo _one-hot_ (1 bit por estado), que representam os possíveis estados da operação, que são:
- - - **`EXACT`**: Resultado representado corretamente sem arredondamento;
- - - **`OVERFLOW`**: Resultado maior que o valor máximo que pode ser representado;
- - - **`UNDERFLOW`**: Resultado menor que o valor mínimo que pode ser representado;
- - - **`INEXACT`**: Resultado sofreu arredondamento;
    
### Estados da FSM do módulo:

- **`EXTRAI`:** Responsável por, no estado seguinte ao reset passar para **ALTO**, separar os 32 bits dos operandos na codificação correta do `sinal`, `expoente` e `mantissa`;
- **`ESPECIAIS`:** Responsável por verificar os casos especiais dos operandos, como por exemplo se um dos operandos for zero, -/+infinito ou NaN;
- **`DIFERENÇA`:** Responsável por calcular a diferença valor dos expoentes dos operandos, para poder realizar o alinhamento deles;
- **`ALINHA`:** Responsável por alinhar o expoente de menor valor com o de maior valor que possibilita a realização da operação;
- **`OPERAÇÃO`:** Responsável por somar ou subtrair os operandos `A` e `B`;
- **`NORMALIZA`:** Responsável por normalizar o formato da mantissa após a operação;
- **`ARREDONDA`:** Responsável por arredondar, se necessário, a resposta;
- **`VERIFICA`:** Reposnsável por verificar se houve `OVERFLOW`, `UNDERFLOW` e `INEXACT` na resposta;
- **`SAÍDA`:** Responsável por enviar a resposta na codificação correta ao data_out e espera o reset **BAIXO** para recomeçar o módulo;

## Espectro numérico representável:


| Condição | Expoente(binário) | Expoente(decimal )| Mantissa | Valor(decimal) |
| -------- | ----------------- | ----------------- | -------- | -------------- |
| Zero  | 000000 | -31 | 00...0 | 0 |
| Menor Normalizado  | 000001 | -30 | 000...0 | 9.313225746 × 10⁻¹⁰ |
| Normalizado | 000001–111110 | -30 a +31 | X | (1 + mantissa/2²⁵) × 2^(expoente-31) |
| Maior Número | 111110 | +31 | 111...1| 4.294967296 × 10⁹ |
| Overflow | 111111 | +32 | 000...0 | Overflow |

![Espectro numérico representável](https://i.imgur.com/GloTxYy.png "Espectro numérico representável")

## Resultados:
Os resultados foram obtidos através do testbench que realizou 10 testes diferentes, porém os testes 6 e 8 tiveram erros, sendo respectivamente, o zero não sendo detectado corretamente como resposta e a subtração com 2 negativos está errada. Irei mostrar aqui uma imagem da simulação dos testes 1 e 2 e também as suas entradas como no testbench.

- **Teste 1:** `Soma 1,5 + 1,5 = 3,0`
- - op_A_in = 32'h20000000 --> op_A_in = 1,5
- - op_B_in = 32'h20000000 --> op_B_in = 1,5
- - data_out esperado: 32'h20280000;

- **Teste 2:** `Soma 0,0 + 2,0 = 2.0`
- - op_A_in = 32'h00000000 --> op_A_in = 0,0
- - op_B_in = 32'h20200000 --> op_B_in = 2,0
- - data_out esperado: 32'h20200000;

![Forma de Onda Testes 1 e 2](https://i.imgur.com/Ul2QMDa.png "Forma de Onda Testes 1 e 2")