set_location_assignment PIN_AF14 -to clk_clk

# 7-Segment Display Pin Assignments

# HEX0 (lamps_lamps\[6:0\])
set_location_assignment PIN_AE26 -to lamps_lamps\[0\]
set_location_assignment PIN_AE27 -to lamps_lamps\[1\]
set_location_assignment PIN_AE28 -to lamps_lamps\[2\]
set_location_assignment PIN_AG27 -to lamps_lamps\[3\]
set_location_assignment PIN_AF28 -to lamps_lamps\[4\]
set_location_assignment PIN_AG28 -to lamps_lamps\[5\]
set_location_assignment PIN_AH28 -to lamps_lamps\[6\]

# HEX1 (lamps_lamps\[13:7\])
set_location_assignment PIN_AJ29 -to lamps_lamps\[7\]
set_location_assignment PIN_AH29 -to lamps_lamps\[8\]
set_location_assignment PIN_AH30 -to lamps_lamps\[9\]
set_location_assignment PIN_AG30 -to lamps_lamps\[10\]
set_location_assignment PIN_AF29 -to lamps_lamps\[11\]
set_location_assignment PIN_AF30 -to lamps_lamps\[12\]
set_location_assignment PIN_AD27 -to lamps_lamps\[13\]

# HEX2 (lamps_lamps\[20:14\])
set_location_assignment PIN_AB23 -to lamps_lamps\[14\]
set_location_assignment PIN_AE29 -to lamps_lamps\[15\]
set_location_assignment PIN_AD29 -to lamps_lamps\[16\]
set_location_assignment PIN_AC28 -to lamps_lamps\[17\]
set_location_assignment PIN_AD30 -to lamps_lamps\[18\]
set_location_assignment PIN_AC29 -to lamps_lamps\[19\]
set_location_assignment PIN_AC30 -to lamps_lamps\[20\]

# HEX3 (lamps_lamps\[27:21\])
set_location_assignment PIN_AD26 -to lamps_lamps\[21\]
set_location_assignment PIN_AC27  -to lamps_lamps\[22\]
set_location_assignment PIN_AD25 -to lamps_lamps\[23\]
set_location_assignment PIN_AC25 -to lamps_lamps\[24\]
set_location_assignment PIN_AB28 -to lamps_lamps\[25\]
set_location_assignment PIN_AB25 -to lamps_lamps\[26\]
set_location_assignment PIN_AB22 -to lamps_lamps\[27\]


set remaining_pins { \
	AA24 Y23  Y24  W22  W24  V23  W25 \
	V25  AA28 Y27  AB27 AB26 AA26 AA25 \
}

for { set i 0 } { ${i} < 14 } { incr i } {
	set idx [ expr ${i} + 28 ]
	set pin [ lindex ${remaining_pins} ${i} ]
	set_location_assignment PIN_${pin} -to lamps_lamps\[${idx}\]
}	