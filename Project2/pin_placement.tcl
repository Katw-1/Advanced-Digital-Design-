set vga_pins{ \
    red   { AA1 V1 Y2 Y1 } \
    green {  W1 T2 R2 R1 } \
    blue  {  P1 T1 P4 N2 } \
}
foreach { channel pins } ${vga_pins}{
    for{ set bit 0 }${bit} <4 }{incr bit} {
        set pin [ lindex ${pins} ${bit} ]
        set_location_assignment PIN_${pin} -to color.${channel}\[${i}\]  
        set_instance_assignement -name IO_STANDARD "3.3-V LVTTL" -to color.${channel}\[${i}\]
    }  
}
set misc_pins{ \
    reset B8 "3.3V SCHMITT TRIGGER" \
    clock P11 "3.3-V LVTTL" \
    h_sync N3 "3.3-V LVTTL" \
    v_sync N1 "3.3-V LVTTL" \
    mode F15  "3.3-V LVTTL" \
}
foreach{ signal pin iostd } ${misc_pins}{
    set_location_assignment PIN_${pin} -to ${signal}
    set_instance_assignement -name IO_STANDARD ${iostd} -to ${signal}
}