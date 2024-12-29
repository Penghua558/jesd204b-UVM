onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/DUT/link_layer/i_link_mux
add wave -noupdate /top/DUT/tx_ctrl/o_link_mux
add wave -noupdate -radix hexadecimal /top/DUT/link_layer/data_after_mux
add wave -noupdate /top/DUT/link_layer/data_vld_after_mux
add wave -noupdate /top/DUT/link_layer/k_flag_after_mux
add wave -noupdate /top/DUT/clk
add wave -noupdate /top/device_clk
add wave -noupdate /top/agent_bitclk
add wave -noupdate /top/character_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12567540 ps} 0}
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
WaveRestoreZoom {12564010 ps} {12576830 ps}
