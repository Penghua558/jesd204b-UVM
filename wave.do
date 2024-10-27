onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/DUT/rst_n
add wave -noupdate /top/DUT/clk
add wave -noupdate /top/DUT/i_data
add wave -noupdate /top/DUT/i_k
add wave -noupdate /top/DUT/i_vld
add wave -noupdate /top/DUT/o_data
add wave -noupdate /top/DUT/o_k_error
add wave -noupdate /top/DUT/data_encode
add wave -noupdate /top/DUT/rd
add wave -noupdate /top/DUT/symbol_plus
add wave -noupdate /top/DUT/symbol_minus
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {170000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {147600 ps} {443 ns}
