#-----------------------------------------------------------------------
# TITLE:
#    tactic.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    athena(n): Mark II Tactic, SIGEVENT
#
#    A SIGEVENT tactic writes a message to the sigevents log.
#
#-----------------------------------------------------------------------

# FIRST, create the class.
::athena::tactic define SIGEVENT "Log Significant Event" {system actor} {
    #-------------------------------------------------------------------
    # Instance Variables

    variable msg        ;# The message to log.
    
    #-------------------------------------------------------------------
    # Constructor

    constructor {pot_ args} {
        next $pot_

        # NEXT, Initialize state variables
        set msg ""

        # NEXT, Save the options
        my configure {*}$args
    }

    #-------------------------------------------------------------------
    # Operations

    # No special SanityCheck is required; any message is OK.

    # No special obligation is required; SIGEVENT takes no resources.

    method narrative {} {
        if {$msg ne ""} {
            return "Logs \"$msg\" to the sigevents log"
        } else {
            return "Logs \"???\" to the sigevents log"
        }
    }

    method execute {} {
        if {$msg ne ""} {
            set output $msg
        } else {
            set output "*NULL*"
        }
        [my adb] sigevent log 1 tactic "SIGEVENT: $output" [my agent]
    }
}

#-----------------------------------------------------------------------
# TACTIC:* orders

# TACTIC:SIGEVENT
#
# Updates the tactic's parameters

::athena::orders define TACTIC:SIGEVENT {
    meta title      "Tactic: Log Significant Event"
    meta sendstates PREP
    meta parmlist   {tactic_id name msg}

    meta form {
        rcc "Tactic ID:" -for tactic_id
        text tactic_id -context yes \
            -loadcmd {$order_ beanload}

        rcc "Name:" -for name
        text name -width 20

        rcc "Message:" -for msg
        text msg -width 40
    }

    method _validate {} {
        # FIRST, prepare and validate the parameters
        my prepare tactic_id -required \
            -with [list $adb strategy valclass ::athena::tactic::SIGEVENT]
        my returnOnError

        set tactic [$adb bean get $parms(tactic_id)]

        my prepare name      -toupper   -with [list $tactic valName]
        my prepare msg        
    }

    method _execute {{flunky ""}} {
        set tactic [$adb bean get $parms(tactic_id)]
        my setundo [$tactic update_ {name msg} [array get parms]]
    }
}





