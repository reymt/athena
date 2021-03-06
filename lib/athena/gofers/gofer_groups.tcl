#-----------------------------------------------------------------------
# TITLE:
#    gofer_groups.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    Groups gofer
#    
#    gofer_groups: A list of groups produced according to 
#    various rules

#-----------------------------------------------------------------------
# gofer::GROUPS

::athena::goferx define GROUPS group {
    rc "" -width 3in -span 3
    label {
        Enter a rule for selecting a set of groups.
    }
    rc

    rc
    selector _rule {
        case BY_VALUE "By name" {
            rc "Select groups from the following list:"
            rc
            enumlonglist raw_value -dictcmd {$adb_ group namedict} \
                -width 30 -height 10 
        }
        
        case SUPPORTING_ACTOR "Supporting Actor(s)" {
            rc "Select groups that actively support "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group supports an actor if it contributes to the actor's 
                influence in some neighborhood.
            }
        }

        case LIKING_ACTOR "Liking Actor(s)" {
            rc "Select groups that like "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group likes an actor if its vertical relationship 
                with the actor is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case DISLIKING_ACTOR "Disliking Actor(s)" {
            rc "Select groups that dislike "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group dislikes an actor if its vertical relationship 
                with the actor is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        case LIKING_GROUP "Liking Group(s)" {
            rc "Select groups that like "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F likes group G if its horizontal relationship 
                with G is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case DISLIKING_GROUP "Disliking Group(s)" {
            rc "Select groups that dislike "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F dislikes group G if its horizontal relationship 
                with G is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        case LIKED_BY_GROUP "Liked by Group(s)" {
            rc "Select groups that are liked by "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F is liked by group G if G's horizontal relationship 
                with F is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case DISLIKED_BY_GROUP "Disliked by Group(s)" {
            rc "Select groups that are disliked by "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F is disliked by group G if G's horizontal relationship 
                with F is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        # Civilian Group cases
        case CIV_RESIDENT_IN "Civilian Groups, Resident in Neighborhood(s)" {
            rc {
                Select civilian groups that reside in any of the 
                following neighborhoods:
            }
            rc
            enumlonglist nlist -dictcmd {$adb_ nbhood namedict} \
                -width 30 -height 10
        }



        case CIV_NOT_RESIDENT_IN "Civilian Groups, Not Resident in Neighborhood(s)" {
            rc "Select civilian groups that do not reside in any of the following neighborhoods:"
            rc
            enumlonglist nlist -dictcmd {$adb_ nbhood namedict} \
                -width 30 -height 10
        }

        case CIV_MOOD_IS_GOOD "Civilian Groups, Mood is Good" { 
            rc "Select civilian groups whose mood is good."
            rc
            rc {
                A group's mood is good if it is Satisfied or Very
                Satisfied, i.e., it is greater than 20.0.
            }
        }

        case CIV_MOOD_IS_BAD "Civilian Groups, Mood is Bad" { 
            rc "Select civilian groups whose mood is bad."
            rc
            rc {
                A group's mood is bad if it is Dissatisfied or Very
                Dissatisfied, i.e., it is less than &minus;20.0.
            }
        }

        case CIV_MOOD_IS_AMBIVALENT "Civilian Groups, Mood is Ambivalent" { 
            rc "Select civilian groups whose mood is ambivalent."
            rc
            rc {
                A group's mood is ambivalent if it is between
                &minus;20.0 and 20.0.
            }
        }

        case CIV_SUPPORTING_ACTOR "Civilian Groups, Supporting Actor(s)" {
            rc "Select civilian groups that actively support "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group supports an actor if it contributes to the actor's 
                influence in some neighborhood.
            }
        }

        case CIV_LIKING_ACTOR "Civilian Groups, Liking Actor(s)" {
            rc "Select civilian groups that like "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group likes an actor if its vertical relationship 
                with the actor is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case CIV_DISLIKING_ACTOR "Civilian Groups, Disliking Actor(s)" {
            rc "Select civilian groups that dislike "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group dislikes an actor if its vertical relationship 
                with the actor is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        case CIV_LIKING_GROUP "Civilian Groups, Liking Group(s)" {
            rc "Select civilian groups that like "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F likes group G if its horizontal relationship 
                with G is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case CIV_DISLIKING_GROUP "Civilian Groups, Disliking Group(s)" {
            rc "Select civilian groups that dislike "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F dislikes group G if its horizontal relationship 
                with G is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        case CIV_LIKED_BY_GROUP "Civilian Groups, Liked by Group(s)" {
            rc "Select civilian groups that are liked by "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F is liked by group G if G's horizontal relationship 
                with F is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case CIV_DISLIKED_BY_GROUP "Civilian Groups, Disliked by Group(s)" {
            rc "Select civilian groups that are disliked by "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F is disliked by group G if G's horizontal relationship 
                with F is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        case FRC_OWNED_BY "Force Groups, Owned by Actor(s)" {
            rc "Select force groups that are owned by any of the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10
        }

        case FRC_DEPLOYED_TO "Force Groups, Deployed to Neighborhood(s)" {
            rc "Select force groups that are deployed to "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following neighborhoods:"

            rc
            enumlonglist nlist -dictcmd {$adb_ nbhood namedict} \
                -width 30 -height 10
        }

        case FRC_NOT_DEPLOYED_TO "Force Groups, Not Deployed to Neighborhood(s)" {
            rc "Select force groups that are not deployed to "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following neighborhoods:"

            rc
            enumlonglist nlist -dictcmd {$adb_ nbhood namedict} \
                -width 30 -height 10
        }

        case FRC_SUPPORTING_ACTOR "Force Groups, Supporting Actor(s)" {
            rc "Select force groups that actively support "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group supports an actor if it contributes to the actor's 
                influence in some neighborhood.
            }
        }

        case FRC_LIKING_ACTOR "Force Groups, Liking Actor(s)" {
            rc "Select force groups that like "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group likes an actor if its vertical relationship 
                with the actor is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case FRC_DISLIKING_ACTOR "Force Groups, Disliking Actor(s)" {
            rc "Select force groups that dislike "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following actors:"

            rc
            enumlonglist alist -dictcmd {$adb_ actor namedict} \
                -width 30 -height 10

            rc {
                A group dislikes an actor if its vertical relationship 
                with the actor is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        case FRC_LIKING_GROUP "Force Groups, Liking Group(s)" {
            rc "Select force groups that like "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F likes group G if its horizontal relationship 
                with G is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case FRC_DISLIKING_GROUP "Force Groups, Disliking Group(s)" {
            rc "Select force groups that dislike "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F dislikes group G if its horizontal relationship 
                with G is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

        case FRC_LIKED_BY_GROUP "Force Groups, Liked by Group(s)" {
            rc "Select force groups that are liked by "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F is liked by group G if G's horizontal relationship 
                with F is LIKE or SUPPORT (i.e., the 
                relationship is greater than or equal to 0.2).
            }
        }

        case FRC_DISLIKED_BY_GROUP "Force Groups, Disliked by Group(s)" {
            rc "Select force groups that are disliked by "
            enumlong anyall -defvalue ANY -dictcmd {::eanyall deflist}
            label " the following groups:"

            rc
            enumlonglist glist -dictcmd {$adb_ group namedict} \
                -width 30 -height 10

            rc {
                Group F is disliked by group G if G's horizontal relationship 
                with F is DISLIKE or OPPOSE (i.e., the 
                relationship is less than or equal to &minus;0.2).
            }
        }

    }
}

#-----------------------------------------------------------------------
# Gofer Rules

# Rule: BY_VALUE
#
# Some set of groups chosen by the user.

::athena::goferx rule GROUPS BY_VALUE {raw_value} {
    method make {raw_value} {
        return [my validate [dict create raw_value $raw_value]]
    }

    method validate {gdict} {
        dict with gdict {}

        dict create raw_value \
            [my val_elist group "groups" $raw_value]
    }

    method narrative {gdict {opt ""}} {
        dict with gdict {}

        return [my nar_list "group" "these groups" $raw_value $opt]
    }

    method eval {gdict} {
        dict with gdict {}

        return $raw_value
    }
}

# Rule: SUPPORTING_ACTOR
#
# Groups who have the desire and ability (i.e.,
# security) to contribute to the actor's support.

::athena::goferx rule GROUPS SUPPORTING_ACTOR {anyall alist} {
    method make {anyall alist} {
        return [my validate [dict create anyall $anyall alist $alist]]
    }

    method validate {gdict} {
        return [my val_anyall_alist $gdict]
    }

    method narrative {gdict {opt ""}} {
        set result "groups that actively support "
        append result [my nar_anyall_alist $gdict $opt]
        return "$result"
    }

    method eval {gdict} {
        return [my anyall_alist_supportingActor "" $gdict]
    }
}

# Rule: LIKING_ACTOR
#
# Groups who have a positive (LIKE or SUPPORT) vertical
# relationship with any or all of a set of actors.

::athena::goferx rule GROUPS LIKING_ACTOR {anyall alist} {
    method make {anyall alist} {
        return [my validate [dict create anyall $anyall alist $alist]]
    }

    method validate {gdict} {
        return [my val_anyall_alist $gdict]
    }

    method narrative {gdict {opt ""}} {
        set result "groups that like "
        append result [my nar_anyall_alist $gdict $opt]
        return "$result"
    }

    method eval {gdict} {
        return [my anyall_alist_likingActor "" $gdict]
    }
}

# Rule: DISLIKING_ACTOR
#
# Groups who have a negative (DISLIKE or OPPOSE) vertical
# relationship with any or all of a set of actors.

::athena::goferx rule GROUPS DISLIKING_ACTOR {anyall alist} {
    method make {anyall alist} {
        return [my validate [dict create anyall $anyall alist $alist]]
    }

    method validate {gdict} {
        return [my val_anyall_alist $gdict]
    }

    method narrative {gdict {opt ""}} {
        set result "groups that dislike "
        append result [my nar_anyall_alist $gdict $opt]
        return "$result"
    }

    method eval {gdict} {
        return [my anyall_alist_dislikingActor "" $gdict]
    }
}

# Rule: LIKING_GROUP
#
# Groups who have a positive (LIKE or SUPPORT) horizontal
# relationship with any or all of a set of groups.

::athena::goferx rule GROUPS LIKING_GROUP {anyall glist} {
    method make {anyall glist} {
        return [my validate [dict create anyall $anyall glist $glist]]
    }

    method validate {gdict} { 
        return [my val_anyall_glist $gdict] 
    }

    method narrative {gdict {opt ""}} {
        set result "groups that like "
        append result [my nar_anyall_glist $gdict $opt]
        return "$result"
    }

    method eval {gdict} {
        return [my anyall_glist_likingGroup "" $gdict]
    }
}

# Rule: DISLIKING_GROUP
#
# Groups who have a negative (DISLIKE or OPPOSE) horizontal
# relationship with any or all of a set of groups.

::athena::goferx rule GROUPS DISLIKING_GROUP {anyall glist} {
    method make {anyall glist} {
        return [my validate [dict create anyall $anyall glist $glist]]
    }

    method validate {gdict} { 
        return [my val_anyall_glist $gdict] 
    }

    method narrative {gdict {opt ""}} {
        set result "groups that dislike "
        append result [my nar_anyall_glist $gdict $opt]
        return "$result"
    }

    method eval {gdict} {
        return [my anyall_glist_dislikingGroup "" $gdict]
    }
}

# Rule: LIKED_BY_GROUP
#
# Groups for whom any or all of set of groups have a positive 
# (LIKE or SUPPORT) horizontal relationship.

::athena::goferx rule GROUPS LIKED_BY_GROUP {anyall glist} {
    method make {anyall glist} {
        return [my validate [dict create anyall $anyall glist $glist]]
    }

    method validate {gdict} { 
        return [my val_anyall_glist $gdict] 
    }

    method narrative {gdict {opt ""}} {
        set result "groups that are liked by "
        append result [my nar_anyall_glist $gdict $opt]
        return "$result"
    }

    method eval {gdict} {
        return [my anyall_glist_likedByGroup "" $gdict]
    }
}

# Rule: DISLIKED_BY_GROUP
#
# Groups for whom any or all of set of groups have a negative 
# (DISLIKE or OPPOSE) horizontal relationship.

::athena::goferx rule GROUPS DISLIKED_BY_GROUP {anyall glist} {
    method make {anyall glist} {
        return [my validate [dict create anyall $anyall glist $glist]]
    }

    method validate {gdict} { 
        return [my val_anyall_glist $gdict] 
    }

    method narrative {gdict {opt ""}} {
        set result "groups that are disliked by "
        append result [my nar_anyall_glist $gdict $opt]
        return "$result"
    }

    method eval {gdict} {
        return [my anyall_glist_dislikedByGroup "" $gdict]
    }
}

#-----------------------------------------------------------------------
# Civgroup Rules

::athena::goferx rulefrom GROUPS CIV_RESIDENT_IN        CIVGROUPS RESIDENT_IN
::athena::goferx rulefrom GROUPS CIV_NOT_RESIDENT_IN    CIVGROUPS NOT_RESIDENT_IN
::athena::goferx rulefrom GROUPS CIV_MOOD_IS_GOOD       CIVGROUPS MOOD_IS_GOOD
::athena::goferx rulefrom GROUPS CIV_MOOD_IS_BAD        CIVGROUPS MOOD_IS_BAD
::athena::goferx rulefrom GROUPS CIV_MOOD_IS_AMBIVALENT CIVGROUPS MOOD_IS_AMBIVALENT
::athena::goferx rulefrom GROUPS CIV_SUPPORTING_ACTOR   CIVGROUPS SUPPORTING_ACTOR
::athena::goferx rulefrom GROUPS CIV_LIKING_ACTOR       CIVGROUPS LIKING_ACTOR
::athena::goferx rulefrom GROUPS CIV_DISLIKING_ACTOR    CIVGROUPS DISLIKING_ACTOR
::athena::goferx rulefrom GROUPS CIV_LIKING_GROUP       CIVGROUPS LIKING_GROUP
::athena::goferx rulefrom GROUPS CIV_DISLIKING_GROUP    CIVGROUPS DISLIKING_GROUP
::athena::goferx rulefrom GROUPS CIV_LIKED_BY_GROUP     CIVGROUPS LIKED_BY_GROUP
::athena::goferx rulefrom GROUPS CIV_DISLIKED_BY_GROUP  CIVGROUPS DISLIKED_BY_GROUP

#-----------------------------------------------------------------------
# Frcgroup Rules

::athena::goferx rulefrom GROUPS FRC_OWNED_BY           FRCGROUPS OWNED_BY
::athena::goferx rulefrom GROUPS FRC_DEPLOYED_TO        FRCGROUPS DEPLOYED_TO
::athena::goferx rulefrom GROUPS FRC_NOT_DEPLOYED_TO    FRCGROUPS NOT_DEPLOYED_TO
::athena::goferx rulefrom GROUPS FRC_SUPPORTING_ACTOR   FRCGROUPS SUPPORTING_ACTOR
::athena::goferx rulefrom GROUPS FRC_LIKING_ACTOR       FRCGROUPS LIKING_ACTOR
::athena::goferx rulefrom GROUPS FRC_DISLIKING_ACTOR    FRCGROUPS DISLIKING_ACTOR
::athena::goferx rulefrom GROUPS FRC_LIKING_GROUP       FRCGROUPS LIKING_GROUP
::athena::goferx rulefrom GROUPS FRC_DISLIKING_GROUP    FRCGROUPS DISLIKING_GROUP
::athena::goferx rulefrom GROUPS FRC_LIKED_BY_GROUP     FRCGROUPS LIKED_BY_GROUP
::athena::goferx rulefrom GROUPS FRC_DISLIKED_BY_GROUP  FRCGROUPS DISLIKED_BY_GROUP
