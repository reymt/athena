#-----------------------------------------------------------------------
# TITLE:
#    template.tcl
#
# PROJECT:
#    athena - Athena Regional Stability Simulation
#
# DESCRIPTION:
#    ahttpd(n): Template support.
#
#    Stephen Uhler / Brent Welch (c) 1997-1998 Sun Microsystems
#    Brent Welch (c) 1998-2000 Ajuba Solutions
#    Will Duquette (c) 2015 California Institute of Technology
#
#    See the file "license.terms" for information on usage and 
#    redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# TBD: 
#
# * The code seems to presume that templates always produce HTML.
#   Perhaps a template naming scheme "<filename>.<type>.tml" would be
#   appropriate; rather than replacing .tml with "htmlExt", just strip
#   the .tml off.
#
#-----------------------------------------------------------------------

snit::type ::ahttpd::template {
    pragma -hasinstances no

    #-------------------------------------------------------------------
    # Type Variables

    # info array
    #
    # TBD: Don't forget to scan for info() in code!
    #
    # tmlExt  - The template extension
    # env     - If 1, populate the ::ahttpd::cgienv() array as for 
    #           CGI scripts.
    # htmlExt - The HTML extension for templates
    # check   - If 1, check for newer templates.
    # interp  - The interpreter for substituting templates.

    typevariable info -array {
        tmlExt  .tml
        env     1
        htmlExt .html
        check   1
        interp  {}
    }

    #-------------------------------------------------------------------
    # Public Type Methods

    # init 
    #
    # Enables .tml templates.

    typemethod init {} {
        # Define content-type handlers
        ::ahttpd::doc handler text/html \
            [list ::ahttpd::template text/html]
        ::ahttpd::doc handler application/x-tcl-template \
            [list ::ahttpd::template application/x-tcl-template]
    }

    # check ?flag?
    #
    # flag  - A boolean flag
    #
    # Sets or queries the check flag.  If true, check to see if template
    # files are newer than output files, and regenerate the output if
    # so.

    typemethod check {{flag ""}} {
        if {$flag ne ""} {
            set info(check) $flag
        }

        return $info(check)
    }    

    # interp ?interp?
    #
    # interp  - A Tcl interpreter
    #
    # Sets or queries the interpreter to use for expanding 
    # "Doc" domain templates.  The interpreter is assumed to
    # be preconfigured.

    typemethod interp {{interp ""}} {
        if {$interp ne ""} {
            set info(interp) $interp
        }

        return $info(interp)
    }    

    # tmlext
    #
    # Returns the TML extension, e.g., .tml.

    typemethod tmlext {} {
        return $info(tmlExt)
    }

    # htmlext
    #
    # Returns the HTML extension, e.g., .html.

    typemethod htmlext {} {
        return $info(htmlExt)
    }

    #-------------------------------------------------------------------
    # Content-Type Managers
    
    # application/x-tcl-template path suffix sock
    #
    # path    - The file pathname.
    # suffix  - The URL suffix.
    # sock    - The socket connection.
    #
    # Tcl-subst a template that mixes HTML and Tcl, and return
    # the page to the client.

    typemethod application/x-tcl-template {path suffix sock} {
        upvar #0 ::ahttpd::Httpd$sock data

        # This is always dynamic (ReturnData has no modification date)
        # so the result is not cached at the remote end, nor is a local
        # .html file cached.

        return [httpd returnData $sock text/html \
            [TemplateInstantiate $sock $path {} $suffix {}]]
    }

    # text/html path suffix sock
    #
    # path    - The file pathname.
    # suffix  - The URL suffix.
    # sock    - The socket connection.
    #
    # This  supports templates.  If enabled, a check is made for the
    # corresponding template file.  If it is newer, then it is processed
    # and the result is cached in the .html file.
    #
    # Returns a page to the client.  May use a corresponding template
    # to generate, and cache, the page.

    typemethod text/html {path suffix sock} {
        upvar #0 ::ahttpd::Httpd$sock data

        set ctype "text/html"

        if {$info(check)} {
            # See if the .html cached result is up-to-date
            set template [file root $path]$info(tmlExt)

            if {[file exists $template] && 
                [TemplateCheck $sock $template $path]
            } {
                # Do the subst and cache the result in the .html file
                set html [TemplateInstantiate \
                            $sock $template $path $suffix dynamic]

                # If the content type was set, use it.  Otherwise, use 
                # the default.
                if {[info exists data(contentType)]} {
                    set ctype $data(contentType)
                } else {
                    set ctype "text/html"
                }

                if {$dynamic} {
                    return [httpd returnData $sock $ctype $html]
                }
            }
        }

        # Use ReturnFile so remote end knows it can cache the file.
        # This file may have been generated by TemplateInstantiate above.

        return [httpd returnFile $sock $ctype $path]
    }


    # TemplateCheck sock template htmlfile
    #
    # sock      - The client connection
    # template  - The file pathname of the template.
    # htmlfile  - The file pathname of the cached .html file.
    #
    # Check modify times on all templates that affect a page.
    # Returns 1 if the template or any dependent .tml file are newer 
    # than the cached .html file, and 0 otherwise.

    proc TemplateCheck {sock template htmlfile} {
        if {[file exists $htmlfile]} {
            set mtime [file mtime $htmlfile]
        } else {
            return 1
        }

        # Look for .tml library files down the hierarchy.
        set rlen [llength [file split [doc root]]]
        set dirs [lrange [file split [file dirname $template]] $rlen end]
        
        foreach libdir [doc getpath $sock $template] {
            set libfile [file join $libdir $info(tmlExt)]
            if {[file exists $libfile] && ([file mtime $libfile] > $mtime)} {
                return 1
            }
        }

        # make index.html regeneration depend upon the whole directory's
        # modification time, not just the modification time of index.tml
        if {[file root [file tail $htmlfile]] eq [file root [dirlist indexfile]]} {
            if {[file mtime [file dirname $htmlfile]] > $mtime} {
                return 1
            }
        }

        return [expr {[file mtime $template] > $mtime}]
    }

    # TemplateInstantiate sock template htmlfile suffix dynamicVar
    #
    # sock        - The client socket.
    # template    - The file name of the template.
    # htmlfile    - The file name of the corresponding .html file.
    # suffix      - The URL suffix.
    # dynamicVar  - Name of var to set to dynamic property of the page.
    #
    # Generate a .html file from a template and from any .tml files in 
    # directories leading up to the root.  The processing is done in the 
    # template interpreter.
    #
    # Returns the HTML content, or an error generated by the template.
    #
    # State set in the global array "page"; this is for use in the
    # template code.
    #
    #   url         - The URL past the document root
    #   template    - The filename of the template file
    #   filename    - The filename of the associated htmlfile
    #   root        - The ../ path up to the root
    #   dynamic     - If 1, then this page is dynamically generated
    #               - on every fetch.  Otherwise the page has a cached
    #               - static representation.
    #
    # Side Effects:
    #   Generates a page.  Will set up the CGI environment via the ncgi
    #   module, and will do environment variable settings.
    #   data(contentType) contains the mime type of generated content.

    proc TemplateInstantiate {sock template htmlfile suffix dynamicVar} {
        upvar #0 ::ahttpd::Httpd$sock data
        upvar $dynamicVar dynamic
        set interp $info(interp)

        # Compute a relative path back to the root.

        set dirs [lreplace [split [string trimleft $data(url) /] /] end end]
        set root ""
        foreach d $dirs {
            append root ../
        }

        # Populate the global "page" array with state about this page
        if {[string length $htmlfile]} {
            set filename $htmlfile
            set dynamic 0
        } else {
            set filename $template
            set dynamic 1
        }

        interp eval $interp {uplevel #0 {catch {unset page}}}

        interp eval $interp [list uplevel #0 [list array set page [list \
            url           $data(url)  \
            template      $template   \
            includeStack  [list [file dirname $template]] \
            filename      $filename   \
            root          $root       \
            dynamic       $dynamic    \
        ]]]

        # Populate the global "::ahttpd::cgienv" array similarly to the 
        # CGI environment
        if {$info(env)} {
            cgi setenvfor $sock $filename $interp
        }

        # Check query data.

        if {[httpd postDataSize $sock] > 0 && ![info exists data(query)]} {
            set data(query) {}
        }

        if {[info exist data(query)]} {
            if {![info exist data(mime,content-type)] || $data(proto) eq "GET"} {
                # The check against GET is because IE 5 has the following bug.
                # If it does a POST with content-type multipart/form-data and
                # keep-alive reuses the connection for a subsequent GET request,
                # then the GET request erroneously has a content-type header
                # that is a copy of the one from the previous POST!

                set ctype application/x-www-urlencoded
            } else {
                set ctype $data(mime,content-type)
            }

            # Read and append the pending post data to data(query).
            url readpost $sock data(query)

            # Initialize the Standard Tcl Library ncgi package so its
            # ncgi::value can be used to get the data.

            interp eval $interp [list ncgi::reset $data(query) $ctype]
            interp eval $interp [list ncgi::parse]
            interp eval $interp [list ncgi::urlStub $data(url)]

            # Define page(query) and page(querytype)
            # for compatibility with older versions of TclHttpd
            # This is a bit hideous because it reaches inside ::ncgi
            # to avoid parsing the data twice.

            interp eval $interp [list uplevel #0 [list set page(querytype) \
                [string trim [lindex [split $ctype \;] 0]]]]

            interp eval $interp [list uplevel #0 {
                set page(query) {}
                foreach n $ncgi::varlist {
                    foreach v $ncgi::value($n) {
                        lappend page(query) $n $v
                    }
                }
            }]

        } else {
            interp eval $interp [list ncgi::reset ""]
            interp eval $interp [list uplevel #0 [list set page(query) {}]]
            interp eval $interp [list uplevel #0 [list set page(querytype) {}]]
        }

        # Source the .tml files from the root downward.
        #
        # TBD: It appears that if there are files called ".tml", they
        # are loaded as Tcl scripts, to support templates. Hmmm.

        foreach libdir [doc getpath $sock $template] {
            set libfile [file join $libdir $info(tmlExt)]
            if {[file exists $libfile]} {
                interp eval $interp [list uplevel #0 [list source $libfile]]
            }
        }

        # Process the template itself
        set code [catch {docsubst file $template $interp} html]

        if {$code != 0} {
            # pass errors up - specifically Redirect return code

            # stash error information so [cookie save] doesn't interfere
            global errorCode errorInfo
            set ec $errorCode
            set ei $errorInfo

            puts "Error, $errorInfo"

            # Save return cookies, if any
            cookie save $sock $interp

            return -code $code -errorcode $ec -errorinfo $ei
        }

        # Save return cookies, if any
        cookie save $sock $interp

        set dynamic [interp eval $interp {uplevel #0 {set page(dynamic)}}]
        if {!$dynamic} {
            # Cache the result
            catch {file delete -force $htmlfile}
            if {[catch {open  $htmlfile w} out]} {
                set dynamic 1
                ::ahttpd::log add $sock "Template" "no write permission"
            } else {
                puts -nonewline $out $html
                close $out
            }
        }
        return $html
    }

    #-------------------------------------------------------------------
    # Commands for use in templates

    # dynamic
    # 
    # Supresses generation of HTML cache.
    # Sets the dynamic bit so the page is not cached.

    typemethod dynamic {} {
        global page
        set page(dynamic) 1
        return "<!-- DynamicOnly -->\n"
    }
}


