onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/DUT/link_layer/i_link_mux
add wave -noupdate /top/DUT/tx_ctrl/o_link_mux
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12570420 ps} 0}
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
WaveRestoreZoom {0 ps} {105 us}
