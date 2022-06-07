onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/DUT/reset_n
add wave -noupdate /tb/DUT/clk
add wave -noupdate /tb/DUT/encryption
add wave -noupdate /tb/DUT/key_length
add wave -noupdate /tb/DUT/key_valid
add wave -noupdate -radix hexadecimal /tb/DUT/key_word_in
add wave -noupdate /tb/DUT/data_valid
add wave -noupdate -radix hexadecimal /tb/DUT/data_word_in
add wave -noupdate -radix hexadecimal /tb/DUT/data_word_out
add wave -noupdate /tb/DUT/data_ready
add wave -noupdate -color purple -radix hexadecimal -radixshowbase 0 /tb/data_bkp
add wave -noupdate -divider {Sub Keys}
add wave -noupdate -color yellow sim:/tb/DUT/st
add wave -noupdate -color yellow sim:/tb/DUT/st_rounds
add wave -noupdate -color yellow -radix hexadecimal sim:/tb/DUT/sub_key_first
add wave -noupdate -color yellow -radix hexadecimal sim:/tb/DUT/sub_key_second
add wave -noupdate -color yellow -radix hexadecimal sim:/tb/DUT/sub_key_word_in
add wave -noupdate -color yellow -radix hexadecimal sim:/tb/DUT/sub_key_data_o
add wave -noupdate -color yellow -radix hexadecimal sim:/tb/DUT/sub_key_valid
add wave -noupdate -color yellow -radix hexadecimal sim:/tb/DUT/z
add wave -noupdate -color yellow -radix unsigned sim:/tb/DUT/sub_key_addr_in
add wave -noupdate -divider {Encryption}
add wave -noupdate -color Cyan sim:/tb/DUT/st
add wave -noupdate -color Cyan sim:/tb/DUT/st_rounds
add wave -noupdate -color Cyan sim:/tb/DUT/micro_state
add wave -noupdate -color Cyan -radix hexadecimal sim:/tb/DUT/x
add wave -noupdate -color Cyan -radix hexadecimal sim:/tb/DUT/y
add wave -noupdate -color Cyan -radix hexadecimal sim:/tb/DUT/k
add wave -noupdate -color Cyan -radix hexadecimal sim:/tb/DUT/l
add wave -noupdate -color Cyan sim:/tb/DUT/sub_key_addr_out
add wave -noupdate -color Cyan -radix hexadecimal sim:/tb/DUT/sub_key_data_o
add wave -noupdate -color Cyan sim:/tb/DUT/_encrypt
add wave -noupdate -color orange -radix hexadecimal sim:/tb/DUT/BRAM_SUB_KEYS/RAM

add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/encryption
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/key_length
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/key_valid
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/key_word_in
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/data_valid
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/data_word_in
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/data_word_out
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/data_ready
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/st
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/st_cnt
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/st_rounds
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/micro_state
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/sub_key_valid
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/sub_key_addr
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/sub_key_addr_in
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/sub_key_addr_out
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/sub_key_word_in
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/sub_key_first
add wave -noupdate sim:/tb/noc1/noc(0)/router/wrapper_in/encription/sub_key_second

add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/clk
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/reset_n
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/encryption
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/key_length
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/key_valid
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/key_word_in
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/data_valid
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/data_word_in
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/data_word_out
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/data_ready
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/st
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/st_cnt
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/st_rounds
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/micro_state
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/end_encrypt
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/max_keys
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_valid
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_addr
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_addr_in
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_addr_out
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_word_in
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_data_o
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_first
add wave -position end  sim:/tb/noc1/noc(0)/router/wrapper_out/encription/sub_key_second

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1448170 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {1575 us}
