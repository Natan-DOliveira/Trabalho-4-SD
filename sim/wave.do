onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_minha_fpu/clock_100KHz
add wave -noupdate /tb_minha_fpu/reset
add wave -noupdate /tb_minha_fpu/op_A_in
add wave -noupdate /tb_minha_fpu/op_B_in
add wave -noupdate /tb_minha_fpu/status_out
add wave -noupdate /tb_minha_fpu/data_out
add wave -noupdate /tb_minha_fpu/DUT/status
add wave -noupdate /tb_minha_fpu/DUT/state
add wave -noupdate /tb_minha_fpu/DUT/sinal_op_A
add wave -noupdate /tb_minha_fpu/DUT/sinal_op_B
add wave -noupdate /tb_minha_fpu/DUT/sinal_data_out
add wave -noupdate /tb_minha_fpu/DUT/expoente_op_A
add wave -noupdate /tb_minha_fpu/DUT/expoente_op_B
add wave -noupdate /tb_minha_fpu/DUT/expoente_data_out
add wave -noupdate /tb_minha_fpu/DUT/diferenca_expoente
add wave -noupdate /tb_minha_fpu/DUT/mantissa_op_A
add wave -noupdate /tb_minha_fpu/DUT/mantissa_op_B
add wave -noupdate /tb_minha_fpu/DUT/mantissa_data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {917 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 126
configure wave -valuecolwidth 85
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {11941 ns}
