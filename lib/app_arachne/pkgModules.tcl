#-----------------------------------------------------------------------
# TITLE:
#    pkgModules.tcl
#
# PROJECT:
#    athena - Athena Regional Stability Simulation
#
# DESCRIPTION:
#    app_arachne(n) package modules file
#
#    Generated by Kite.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Package Definition

# -kite-provide-start  DO NOT EDIT THIS BLOCK BY HAND
package provide app_arachne 6.3.0a12
# -kite-provide-end

#-----------------------------------------------------------------------
# Required Packages

# Add 'package require' statements for this package's external 
# dependencies to the following block.  Kite will update the versions 
# numbers automatically as they change in project.kite.

# -kite-require-start ADD EXTERNAL DEPENDENCIES
package require projectlib
package require huddle 0.1.5
package require json 1.3.3
package require -exact athena 6.3.0a12
package require -exact ahttpd 6.3.0a12
# -kite-require-end

namespace import projectlib::* athena::* ahttpd::*

#-----------------------------------------------------------------------
# Namespace definition

namespace eval ::app_arachne:: {
    variable library [file dirname [info script]]
}

#-----------------------------------------------------------------------
# Modules

source [file join $::app_arachne::library main.tcl                 ]
source [file join $::app_arachne::library app.tcl                  ]
source [file join $::app_arachne::library case.tcl                 ]
source [file join $::app_arachne::library js.tcl                   ]

# Smart domain handlers
source [file join $::app_arachne::library domain debug.tcl             ]
source [file join $::app_arachne::library domain scenario.tcl          ]
source [file join $::app_arachne::library domain scenario_case.tcl     ]
source [file join $::app_arachne::library domain scenario_history.tcl  ]
source [file join $::app_arachne::library domain scenario_actor.tcl    ]
source [file join $::app_arachne::library domain scenario_group.tcl    ]
source [file join $::app_arachne::library domain scenario_nbhood.tcl   ]
source [file join $::app_arachne::library domain scenario_sigevent.tcl ]

