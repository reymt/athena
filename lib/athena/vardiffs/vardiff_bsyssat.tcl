#-----------------------------------------------------------------------
# TITLE:
#   vardiff_bsyssat.tcl
#
# AUTHOR:
#   Dave Hanks
#
# DESCRIPTION:
#   athena(n) variable differences: bsyssat.b.c
#
#   A value is a composite satisfaction with concern c across civilian 
#   groups having belief system b.
#
#-----------------------------------------------------------------------

oo::class create ::athena::vardiff::bsyssat {
    superclass ::athena::vardiff
    meta type     bsyssat
    meta category social

    constructor {comp_ val1_ val2_ b_ c_} {
        next $comp_ [list b $b_ c $c_] $val1_ $val2_
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
}