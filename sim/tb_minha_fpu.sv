module tb_minha_fpu;

    logic clock_100KHz
    logic reset;
    logic [3:0] status_out;
    logic [31:0] op_A_in,
    logic [31:0] op_B_in;
    logic [31:0] data_out;

    minha_fpu DUT (.*);

endmodule