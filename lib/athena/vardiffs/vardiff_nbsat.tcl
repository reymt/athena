#-----------------------------------------------------------------------
# TITLE:
#   vardiff_nbsat.tcl
#
# AUTHOR:
#   Dave Hanks
#
# DESCRIPTION:
#   athena(n) variable differences: nbsat.n.c
#
#-----------------------------------------------------------------------

oo::class create ::athena::vardiff::nbsat {
    superclass ::athena::vardiff
    meta type     nbsat
    meta category social

    constructor {comp_ val1_ val2_ n_ c_} {
        next $comp_ [list n $n_ c $c_] $val1_ $val2_
    }

    method IsSignificant {} {
        set lim [athena::compdb get [my type].limit]

        expr {[my score] >= $lim}
    }

    method format {val} {
        return [qsat longname $val]
    }

    method context {} {
        format "%.1f vs %.1f" [my val1] [my val2]
    }

    method score {} {
        format "%.1f" [next]
    }

    #-------------------------------------------------------------------
    # Input Differences
    
    method FindDiffs {} {
        variable comp

        set n [my key n]
        set c [my key c]

        # FIRST, get the satisfaction inputs.
        $comp eval {
            SELECT g, sat1, sat2 FROM comp_sat WHERE n = $n AND c = $c
        } {
            my diffadd sat $sat1 $sat2 $g $c
        }

        # NEXT, get the population inputs
        $comp eval {
            SELECT g, pop1, pop2 FROM comp_civg WHERE n = $n
        } {
            my diffadd population $pop1 $pop2 $g
        }
    }

}