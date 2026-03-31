# Pin definitions
set sseg_lamps {
    { C14 E15 C15 C16 E16 D17 C17 }
    { B14 A15 B15 B16 A16 B17 A17 }
    { D14 E14 D15 D16 E16 C17 D17 }
    { A14 B14 A15 A16 B16 A17 B17 }
}

# Procedure
proc set_pins { digits { name "hex_digit" } } {

    global sseg_lamps

    for { set i 0 } { $i < $digits } { incr i } {

        set j 0

        foreach lamp { a b c d e f g } {

            set location [ lindex [ lindex $sseg_lamps $i ] $j ]

            set_location_assignment PIN_$location -to ${name}\[$i\].$lamp

            incr j
        }
    }
}