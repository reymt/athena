#-----------------------------------------------------------------------
# TITLE:
#    condition_expr.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    athena(n): Mark II Condition, EXPR
#
#-----------------------------------------------------------------------

# FIRST, create the class.
::athena::condition define EXPR "Boolean Expression" {
    #-------------------------------------------------------------------
    # Instance Variables

    variable expression ;# The executive expression
    
    #-------------------------------------------------------------------
    # Constructor

    constructor {pot_ args} {
        next $pot_

        # NEXT, Initialize state variables
        set expression ""
        my set state invalid

        # Save the options
        my configure {*}$args
    }

    #-------------------------------------------------------------------
    # Operations

    method narrative {} {
        let expr {$expression ne "" ? $expression : "???"}
        return [normalize "Expression: $expr"]
    }

    method SanityCheck {errdict} {
        if {$expression eq ""} {
            dict set errdict expression "No expression has been specified"
        } elseif {[catch {[my adb] executive expr validate $expression} result]} {
            dict set errdict expression $result
        }

        return [next $errdict]
    }

    method Evaluate {} {
        if {[catch {
            set flag [[my adb] executive eval [list expr $expression]]
        } result eopts]} {
            # FAILURE

            [my adb] sigevent log error tactic "
                EXPR condition: In [my agent]'s strategy, 
                failed to evaluate expression {$expression}: $result
            " [my agent]

            my set state invalid
            return 0
        }

        # SUCCESS
        return $flag
    }
}

#-----------------------------------------------------------------------
# CONDITION:* Orders


# CONDITION:EXPR
#
# Updates the condition's parameters

::athena::orders define CONDITION:EXPR {
    meta title      "Condition: Boolean Expression"
    meta sendstates PREP
    meta parmlist   {condition_id name expression}

    meta form {
        rcc "Condition ID:" -for condition_id
        text condition_id -context yes \
            -loadcmd {$order_ beanload}

        rcc "Name:" -for name
        text name -width 20

        rcc ""
        label {
            This condition is met when the following Boolean
            expression is true.  See the help for the syntax,
            as well as for useful functions to use within it.
        }

        rcc "Expression:" -for expression
        expr expression
    }


    method _validate {} {
        my prepare condition_id -required -with [list $adb strategy valclass ::athena::condition::EXPR]
        my returnOnError

        set cond [$adb bean get $parms(condition_id)]

        my prepare name -toupper -with [list $cond valName]

        if {[my mode] eq "gui"} {
            # In the GUI, give detailed feedback on errors.  From other sources,
            # the sanity check will catch it.
            my prepare expression -oncheck -type {$adb executive expr}
        }
    }

    method _execute {{flunky ""}} {
        set cond [$adb bean get $parms(condition_id)]
        my setundo [$cond update_ {name expression} [array get parms]]
    }
}





