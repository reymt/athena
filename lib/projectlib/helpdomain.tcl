#-----------------------------------------------------------------------
# TITLE:
#    helpdomain.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    projectlib(n): help(5) smartdomain(n) class
#
#    This is an object that serves help pages and images from a 
#    help(5) help database.
#
# URLs:
#    Pages in the help database are referenced as /help/my/page.html.
#    Images are referenced as /help/image/myimage.png.  Search queries
#    are supported: ?search=searchterm.
#
#-----------------------------------------------------------------------

namespace eval ::projectlib:: {
    namespace export helpdomain
}

#-----------------------------------------------------------------------
# mydomain type

oo::class create ::projectlib::helpdomain {
    superclass ::projectlib::smartdomain

    #-------------------------------------------------------------------
    # Instance variables

    variable dbtitle ;# The title of the help database, for use in
                      # output.
    variable helpdb  ;# The path to the help database.
    

    #-------------------------------------------------------------------
    # Constructor

    # constructor domain_ dbtitle_ helpdb_
    #
    # domain_   - The domain, e.g., /help
    # dbtitle_  - The help database title, e.g., "Athena Help"
    # helpdb_   - The path to the help database.

    constructor {domain_ dbtitle_ helpdb_} {
        next $domain_
        set dbtitle $dbtitle_
        set helpdb  $helpdb_

        # FIRST, configure the HTML buffer
        hb configure \
            -cssfiles  {/athena.css}         \
            -headercmd [mymethod htmlHeader] \
            -footercmd [mymethod htmlFooter]

        # NEXT, open the help database.
        sqldocument hdb \
            -readonly yes

        if {[file exists $helpdb]} {
            hdb open $helpdb
        }

        # NEXT, register the urltree handler.
        my urltree / {
            All content in this domain is served up from the help
            database, using the paths in the help database.
        }
    }            

    #-------------------------------------------------------------------
    # Header and Footer

    method htmlHeader {hb title} {
        # TBD: We'll need to set the appname using an option
        # once we use this in the workbench as well.
        # Or parameterize athena::element.
        hb putln [athena::element header Arachne]
    }

    method htmlFooter {hb} {
        hb putln [athena::element footer]
    }

    #-------------------------------------------------------------------
    # URL handlers

    method / {suffix} {
        # FIRST, have we any data?
        if {![hdb isopen]} {
            throw NOTFOUND "Help DB not found: \"$helpdb\""
        }

        # NEXT, handle searching
        set search [qdict prepare search]

        if {$search ne ""} {
            return [my HtmlSearch $search]
        }

        # NEXT, dispatch based on file type.
        set ftype [file extension $suffix]

        switch -- $ftype {
            .html   { my HtmlPage $suffix }
            .png    { my PngImage $suffix }
            default {
                throw NOTFOUND "Page not found in help database"
            }
        }
    }

    # HtmlPage suffix
    #
    # suffix   - The URL suffix
    #
    # Retrieves the page.

    method HtmlPage {suffix} {
        # FIRST, do we have a page with this suffix?
        set title ""

        hdb eval {
            SELECT title, alias, text 
            FROM helpdb_pages 
            WHERE url=$suffix
        } {}

        if {$title eq ""} {
            throw NOTFOUND \
                "Page not found in help database"
        }

        # NEXT, if it's an alias, get the real page text.        
        if {$alias ne ""} {
            set text [hdb onecolumn {
                SELECT text FROM helpdb_pages WHERE path=$alias
            }]
        }

        # NEXT, format it for display.
        hb page "Athena Help: $title"
        my NavBar $suffix
        hb putln [my AddDomain $text]
        return [hb /page]
    }

    # HtmlSearch query
    #
    # query   - The search string
    #
    # Retrieves the search results.

    method HtmlSearch {query} {
        # FIRST, is the query a page title?
        hdb eval {
            SELECT title, text, url
            FROM helpdb_pages 
            WHERE lower(title)=lower($query)
        } {
            my redirect "[my domain]$url"
            # END
        }


        # NEXT, do full text search
        try {
            set found [hdb eval {
                SELECT P.url, 
                       S.title,
                       snippet(helpdb_search) AS snippet
                FROM helpdb_search AS S
                JOIN helpdb_pages AS P USING (path)
                WHERE S.text MATCH $query
                ORDER BY S.title COLLATE NOCASE;
            }]
        } on error {result} {
            puts "Error result: $result"
            throw NOTFOUND \
                "Error in search term: \"$query\""
        }

        hb page "Help Search Results"
        my NavBar /
        hb h1 "Help Search Results"

        if {[llength $found] == 0} {
            hb putln "No help pages match '<code>$query</code>'."
            hb para
        } else {
            hb putln "<b>Search results for '$query':</b><p>"

            hb dl {
                foreach {url title snippet} $found {
                    hb dt
                    hb put <b>
                    hb iref $url $title
                    hb put </b>
                    hb /dt
                    hb dd "$snippet<p>"
                }
            }
        }

        return [hb /page]
    }


    # PngImage suffix
    #
    # suffix   - The URL suffix
    #
    # Retrieves the image.

    method PngImage {suffix} {
        set data [hdb onecolumn {
            SELECT data FROM helpdb_images WHERE url=$suffix 
        }]

        if {$data eq ""} {
            throw NOTFOUND "Image not found"
        } else {
            return [base64::decode $data]
        }
    }



    #-------------------------------------------------------------------
    # Helpers

    # NavBar suffix
    #
    # Adds a navigation bar to the parent items.

    method NavBar {suffix} {
        hb linkbar {
            hb form
            hb xref /index.html Home

            hb xref [my domain]/index.html [string trimleft Help /]

            set parents {}
            foreach folder [split [string trimleft $suffix /] /] {
                if {[file extension $folder] eq ".html"} {
                    hb span " / [file rootname $folder]"
                    continue
                }

                lappend parents $folder

                set url [my domain]/[join $parents /].html 
                hb xref $url " / $folder" 
            }

            hb put "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
            hb entry search -size 15
            hb submit "Search"
            hb /form
        }
    }

    
    # AddDomain content
    #
    # content     - HTML content
    #
    # Adds the domain to the href and src attributes.

    method AddDomain {content} {
        dict set map " href=\"/" " href=\"[my domain]/"
        dict set map " src=\"/"  " src=\"[my domain]/"
        
        return [string map $map $content]
    }





}

