onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/DUT/link_layer/i_link_mux
add wave -noupdate /top/DUT/tx_ctrl/o_link_mux
add wave -noupdate -radix hexadecimal -childformat {{{/top/DUT/link_layer/data_after_mux[7]} -radix hexadecimal} {{/top/DUT/link_layer/data_after_mux[6]} -radix hexadecimal} {{/top/DUT/link_layer/data_after_mux[5]} -radix hexadecimal} {{/top/DUT/link_layer/data_after_mux[4]} -radix hexadecimal} {{/top/DUT/link_layer/data_after_mux[3]} -radix hexadecimal} {{/top/DUT/link_layer/data_after_mux[2]} -radix hexadecimal} {{/top/DUT/link_layer/data_after_mux[1]} -radix hexadecimal} {{/top/DUT/link_layer/data_after_mux[0]} -radix hexadecimal}} -subitemconfig {{/top/DUT/link_layer/data_after_mux[7]} {-height 16 -radix hexadecimal} {/top/DUT/link_layer/data_after_mux[6]} {-height 16 -radix hexadecimal} {/top/DUT/link_layer/data_after_mux[5]} {-height 16 -radix hexadecimal} {/top/DUT/link_layer/data_after_mux[4]} {-height 16 -radix hexadecimal} {/top/DUT/link_layer/data_after_mux[3]} {-height 16 -radix hexadecimal} {/top/DUT/link_layer/data_after_mux[2]} {-height 16 -radix hexadecimal} {/top/DUT/link_layer/data_after_mux[1]} {-height 16 -radix hexadecimal} {/top/DUT/link_layer/data_after_mux[0]} {-height 16 -radix hexadecimal}} /top/DUT/link_layer/data_after_mux
add wave -noupdate /top/DUT/link_layer/data_vld_after_mux
add wave -noupdate /top/DUT/link_layer/k_flag_after_mux
add wave -noupdate /top/DUT/clk
add wave -noupdate /top/device_clk
add wave -noupdate /top/agent_bitclk
add wave -noupdate /top/character_clk
add wave -noupdate /top/DUT/i_sync_n
add wave -noupdate /top/DUT/frame_clk
add wave -noupdate /top/DUT/tx_ctrl/i_sync_request_tx
add wave -noupdate /top/DUT/syncn_dec/sync_requset_frame_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 274
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
WaveRestoreZoom {26460 ps} {93 ns}
