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
add wave -noupdate -group rdminus_rom /top/DUT/u_rdminus_rom/i_k
add wave -noupdate -group rdminus_rom /top/DUT/u_rdminus_rom/k_out
add wave -noupdate -group rdminus_rom /top/DUT/u_rdminus_rom/k_error
add wave -noupdate -group rdminus_rom /top/DUT/u_rdminus_rom/d_out
add wave -noupdate -group rdminus_rom /top/DUT/u_rdminus_rom/i_rd_en
add wave -noupdate -expand -group {RD FSM} /top/DUT/u_rd_fsm/current_state
add wave -noupdate -expand -group {RD FSM} /top/DUT/u_rd_fsm/i_data
add wave -noupdate -expand -group {RD FSM} /top/DUT/u_rd_fsm/next_state
add wave -noupdate -expand -group {RD FSM} /top/DUT/u_rd_fsm/o_rd
add wave -noupdate -expand -group {RD FSM} /top/DUT/u_rd_fsm/rst_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {290000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 272
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
WaveRestoreZoom {249 ns} {396800 ps}
