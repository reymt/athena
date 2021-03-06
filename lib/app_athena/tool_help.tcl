#-----------------------------------------------------------------------
# TITLE:
#   tool_help.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Athena: "help" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::HELP

tool define help {
    usage       {0 1 "?<topic>?"}
    description "Display this help, or help for a given tool."
    needstree      no
} {
    n/a - The "help" tool is a special case.
} {
    #-------------------------------------------------------------------
    # Execution

    # execute ?args?
    #
    # Displays the Athena help.

    typemethod execute {argv} {
        set topic [lindex $argv 0]

        if {$topic eq ""} {
            ShowTopicList
        } else {
            ShowTopic $topic
        }
    }

    # ShowTopicList 
    #
    # List all of the help topics (i.e., the tools and their descriptions).

    proc ShowTopicList {} {
        puts [outdent {
            athena(1) is a collection of tools for working with Athena 
            scenarios at the command line.  The following tools are
            available:
        }]

        puts ""

        foreach tool [lsort [tool names]] {
            puts [format "%-10s - %s" $tool [tool description $tool]]
        }

        puts ""

        puts "Enter 'athena help <topic>' for help on a given topic."

        puts ""
    }

    # ShowTopic topic
    #
    # topic  - A help topic (possibly)

    proc ShowTopic {topic} {
        global thelp

        # For "help", all we can do is display the basic help again.
        if {$topic eq "help"} {
            ShowTopicList
            return
        }

        if {[info exists thelp($topic)]} {
            puts "\n"
            if {[tool exists $topic]} {
                puts [tool usage $topic]
                puts [string repeat - 75]
            }
            puts [outdent $thelp($topic)]
            puts ""
        } else {
            puts "No help is currently available for that topic."
            puts ""
        }
    }
}
