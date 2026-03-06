proc is_valid_x { x_val } {
    set reserved_x { 5 28 33 48 53 68 73}
    
    foreach reserved ${reserved_x} {
        if { ${x_val} == ${reserved} } {
            return 0
        }
    }
    
    return 1
}

proc place_inverters { num_inverters num_chains } {

    set base_x 20
    set base_y 20
    set x_spacing 2
    set y_spacing 4
    
    set half_chain [ expr ${num_chains} / 2 ]
    
    for {set chain 0} { $chain < $num_chains} {incr chain} {
        if { $chain < ${half_chain} } {
            set group_index a
        } else {
            set group_index b
        }
        set base_n 0
        set base_y 20
        for { set i 0 } { ${i} < ${num_inverters} } { incr i } {
            set signal_name "ro_puf:puf|ring_oscillator:\\group_${group_index}:${chain}:ro_inst|stage\[${i}\]"
            
            set_location_assignment LCCOMB_X${base_x}_Y${base_y}_N${base_n} -to ${signal_name}
            
            incr base_n 2
            if { ${base_n} == 32 } {
                set base_n 0
                incr base_y -1
            }
        }
        
        incr base_x
        if { [is_valid_x ${base_x} ] == 0 } {
            incr base_x
        }
    }
}
    
    
