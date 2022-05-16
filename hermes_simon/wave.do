onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_rx(0)
add wave -noupdate -radix decimal /tb/cycles

add wave -noupdate -group ROUTER0 -radix hexadecimal -color {Blue Violet} /tb/data_in(0)
add wave -noupdate -group ROUTER0 -color {Blue Violet} /tb/rx(0)
add wave -noupdate -group ROUTER0 -color {Blue Violet} /tb/credit_o(0)
add wave -noupdate -group ROUTER0 -radix hexadecimal /tb/data_out(0)
add wave -noupdate -group ROUTER0 /tb/tx(0)
add wave -noupdate -group ROUTER0 /tb/credit_i(0)

add wave -noupdate -group ROUTER1 -radix hexadecimal -color {Blue Violet} /tb/data_in(1)
add wave -noupdate -group ROUTER1 -color {Blue Violet} /tb/rx(1)
add wave -noupdate -group ROUTER1 -color {Blue Violet} /tb/credit_o(1)
add wave -noupdate -group ROUTER1 -radix hexadecimal /tb/data_out(1)
add wave -noupdate -group ROUTER1 /tb/tx(1)
add wave -noupdate -group ROUTER1 /tb/credit_i(1)

add wave -noupdate -group ROUTER2 -radix hexadecimal -color {Blue Violet} /tb/data_in(2)
add wave -noupdate -group ROUTER2 -color {Blue Violet} /tb/rx(2)
add wave -noupdate -group ROUTER2 -color {Blue Violet} /tb/credit_o(2)
add wave -noupdate -group ROUTER2 -radix hexadecimal /tb/data_out(2)
add wave -noupdate -group ROUTER2 /tb/tx(2)
add wave -noupdate -group ROUTER2 /tb/credit_i(2)

add wave -noupdate -group ROUTER3 -radix hexadecimal -color {Blue Violet} /tb/data_in(3)
add wave -noupdate -group ROUTER3 -color {Blue Violet} /tb/rx(3)
add wave -noupdate -group ROUTER3 -color {Blue Violet} /tb/credit_o(3)
add wave -noupdate -group ROUTER3 -radix hexadecimal /tb/data_out(3)
add wave -noupdate -group ROUTER3 /tb/tx(3)
add wave -noupdate -group ROUTER3 /tb/credit_i(3)

add wave -noupdate -group ROUTER4 -radix hexadecimal -color {Blue Violet} /tb/data_in(4)
add wave -noupdate -group ROUTER4 -color {Blue Violet} /tb/rx(4)
add wave -noupdate -group ROUTER4 -color {Blue Violet} /tb/credit_o(4)
add wave -noupdate -group ROUTER4 -radix hexadecimal /tb/data_out(4)
add wave -noupdate -group ROUTER4 /tb/tx(4)
add wave -noupdate -group ROUTER4 /tb/credit_i(4)

add wave -noupdate -group ROUTER5 -radix hexadecimal -color {Blue Violet} /tb/data_in(5)
add wave -noupdate -group ROUTER5 -color {Blue Violet} /tb/rx(5)
add wave -noupdate -group ROUTER5 -color {Blue Violet} /tb/credit_o(5)
add wave -noupdate -group ROUTER5 -radix hexadecimal /tb/data_out(5)
add wave -noupdate -group ROUTER5 /tb/tx(5)
add wave -noupdate -group ROUTER5 /tb/credit_i(5)

add wave -noupdate -group ROUTER6 -radix hexadecimal -color {Blue Violet} /tb/data_in(6)
add wave -noupdate -group ROUTER6 -color {Blue Violet} /tb/rx(6)
add wave -noupdate -group ROUTER6 -color {Blue Violet} /tb/credit_o(6)
add wave -noupdate -group ROUTER6 -radix hexadecimal /tb/data_out(6)
add wave -noupdate -group ROUTER6 /tb/tx(6)
add wave -noupdate -group ROUTER6 /tb/credit_i(6)

add wave -noupdate -group ROUTER7 -radix hexadecimal -color {Blue Violet} /tb/data_in(7)
add wave -noupdate -group ROUTER7 -color {Blue Violet} /tb/rx(7)
add wave -noupdate -group ROUTER7 -color {Blue Violet} /tb/credit_o(7)
add wave -noupdate -group ROUTER7 -radix hexadecimal /tb/data_out(7)
add wave -noupdate -group ROUTER7 /tb/tx(7)
add wave -noupdate -group ROUTER7 /tb/credit_i(7)

add wave -noupdate -group ROUTER8 -radix hexadecimal -color {Blue Violet} /tb/data_in(8)
add wave -noupdate -group ROUTER8 -color {Blue Violet} /tb/rx(8)
add wave -noupdate -group ROUTER8 -color {Blue Violet} /tb/credit_o(8)
add wave -noupdate -group ROUTER8 -radix hexadecimal /tb/data_out(8)
add wave -noupdate -group ROUTER8 /tb/tx(8)
add wave -noupdate -group ROUTER8 /tb/credit_i(8)

add wave -noupdate -group KEY /tb/noc1/noc(0)/router/wrapper_in/key_cont
add wave -noupdate -group KEY /tb/noc1/noc(0)/router/wrapper_in/key_sent
add wave -noupdate -group KEY /tb/noc1/noc(0)/router/wrapper_in/encription/key_length
add wave -noupdate -group KEY /tb/noc1/noc(0)/router/wrapper_in/encription/key_valid
add wave -noupdate -group KEY -radix hexadecimal /tb/noc1/noc(0)/router/wrapper_in/encription/key_word_i

add wave -noupdate -group CYPHER8 -radix hexadecimal /tb/noc1/noc(8)/router/wrapper_in/data_word_in
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/EA
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/O_EA
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/encription/data_ready
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/go
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/buff_populated
add wave -noupdate -group CYPHER8 -radix hexadecimal /tb/noc1/noc(8)/router/wrapper_in/cypher_Buff
add wave -noupdate -group CYPHER8 -radix hexadecimal /tb/noc1/noc(8)/router/wrapper_in/buf_out
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/encription/encryption
add wave -noupdate -group CYPHER8 -radix hexadecimal /tb/noc1/noc(8)/router/wrapper_in/encription/data_word_out
add wave -noupdate -group CYPHER8 -color Cyan -radix hexadecimal /tb/noc1/noc(8)/router/wrapper_in/OUT_data_in
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/OUT_rx
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/IN_credit_o
add wave -noupdate -group CYPHER8 /tb/noc1/noc(8)/router/wrapper_in/OUT_credit_o

add wave -noupdate -group DECRYPT0 -radix hexadecimal /tb/noc1/noc(0)/router/wrapper_out/data_word_in
add wave -noupdate -group DECRYPT0 /tb/noc1/noc(0)/router/wrapper_out/EA
add wave -noupdate -group DECRYPT0 /tb/noc1/noc(0)/router/wrapper_out/O_EA
add wave -noupdate -group DECRYPT0 -radix hexadecimal /tb/noc1/noc(0)/router/wrapper_out/cypher_Buff
add wave -noupdate -group DECRYPT0 -radix hexadecimal /tb/noc1/noc(0)/router/wrapper_out/buf_out
add wave -noupdate -group DECRYPT0 /tb/noc1/noc(0)/router/wrapper_out/IN_rx
add wave -noupdate -group DECRYPT0 -radix decimal /tb/noc1/noc(0)/router/wrapper_out/cont
add wave -noupdate -group DECRYPT0 -radix hexadecimal /tb/noc1/noc(0)/router/wrapper_out/IN_data_in
add wave -noupdate -group DECRYPT0 /tb/noc1/noc(0)/router/wrapper_out/IN_credit_o


 

TreeUpdate [SetDefaultTree]
quietly wave cursor active 1
configure wave -namecolwidth 249
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
WaveRestoreZoom {0 ps} {1 us}
