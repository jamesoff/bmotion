# bMotion: admin plugin file for abstracts
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_plugin_admin_abstract { handle { arg "" }} {

  #abstract show <name>
  if [regexp -nocase {show ([^ ]+)} $arg matches name] {
    set result [bMotion_abstract_all $name]
    bMotion_putadmin "Abstract $name has [llength $result] items."
    set i 0
    foreach a $result {
      bMotion_putadmin "$i: $a"
      incr i
    }
    return 0
  }

  #abstract gc
  if [regexp -nocase {gc} $arg matches] {
    bMotion_putadmin "Garbage collecting..."
    bMotion_abstract_gc
    return 0
  }

  #status
  if [regexp -nocase {status} $arg] {
    global bMotion_abstract_contents bMotion_abstract_timestamps bMotion_abstract_max_age
    global bMotion_abstract_ondisk

    set mem 0
    set disk 0

    set handles [array names bMotion_abstract_contents]
    bMotion_putadmin "bMotion abstract info info:\r"
    foreach handle $handles {      
      set diff [expr [clock seconds]- $bMotion_abstract_timestamps($handle)]
      bMotion_putadmin "$handle: [llength [bMotion_abstract_all $handle]] items, $diff seconds since used"
      incr mem
    }
    foreach handle $bMotion_abstract_ondisk {
      bMotion_putadmin "$handle: on disk"
      incr disk
    }
    bMotion_putadmin "[expr $mem + $disk] total abstracts, $mem loaded, $disk on disk"
    return 0
  }

  if [regexp -nocase {info (.+)} $arg matches name] {
    set result [bMotion_abstract_all $name]
    bMotion_putadmin "Abstract $name has [llength $result] items.\r"
    return 0
  }

  if [regexp -nocase {delete (.+) (.+)} $arg matches name index] {
    bMotion_putadmin "Deleting element $index from abstract $name...\r"
    bMotion_abstract_delete $name $index
    return 0
  }

	if [regexp -nocase {purge ([^ ]+) (.+)} $arg matches name re] {
		bMotion_putadmin "Purging abstract $name for elements matching /$re/"
		bMotion_abstract_filter $name $re
		return 0
	}

	if [regexp -nocase "flush" $arg] {
		bMotion_abstract_flush
		bMotion_putadmin "Flushing all abstracts to disk..."
		return 0
	}

	if [regexp -nocase "diagnose" $arg] {
		bMotion_diagnostic_parsing
		return 0
	}

	if [regexp -nocase "reset (.+)" $arg matches name] {
		bMotion_putadmin "Removing all entries from $name"
		bMotion_abstract_reset $name
		return 0
	}

	if [regexp -nocase "filter (\[a-z\]+)( (\[^ \]+)( .+)?)?" $arg matches cmd parms abstract filter] {
		switch $cmd {
			"list" {
				global bMotion_abstract_filters
				set filternames [array names bMotion_abstract_filters]
				foreach f $filternames {
					if {$f == "dummy"} {
						continue
					}
					bMotion_putadmin "$f: $bMotion_abstract_filters($f)"
				}
				return
			}

			"purge" {
				bMotion_abstract_flush_filters
				bMotion_putadmin "Flushed all filters."
				return
			}

			"add" {
				if {$abstract == ""} {
					bMotion_putadmin "Missing abstract"
					return
				}

				if {$filter == ""} {
					bMotion_putadmin "Missing filter"
					return
				}

				set filter [string trim $filter]

				bMotion_abstract_add_filter $abstract $filter
				bMotion_putadmin "Added filter /$filter/ for abstract $abstract"
				return
			}

			"apply" {
				if {$abstract == ""} {
					bMotion_putadmin "Missing abstract name"
					return
				}
				bMotion_putadmin "Applying filter for $abstract (if one exists)"
				bMotion_abstract_apply_filter $abstract
				return
			}
		}
	}

  #all else fails, list help
	bMotion_putadmin "Try .bmotion help abstract"
  return 0
}

proc bMotion_plugin_admin_abstract_help { } {
	bMotion_putadmin "Manage abstracts in bMotion."
	bMotion_putadmin "  .bmotion abstract info <abstract>"
	bMotion_putadmin "    Find out info about an abstract"
	bMotion_putadmin "  .bmotion abstract show <abstract>"
	bMotion_putadmin "    List the contents of an abstract (Potentially much output!)"
	bMotion_putadmin "  .bmotion abstract gc"
	bMotion_putadmin "    Force a garbage collection of abstracts (pages out unused ones)"
	bMotion_putadmin "  .bmotion abstract status"
	bMotion_putadmin "    List all abstracts and their status (Much ouput!)"
	bMotion_putadmin "  .bmotion abstract delete <abstract> <index>"
	bMotion_putadmin "    Delete an element from an abstract"
	bMotion_putadmin "    Index is 0-based; use the show command to find entries"
	bMotion_putadmin "  .bmotion abstract purge <abstract> <regexp>"
	bMotion_putadmin "    Remove all matching elements from an abstract (dangerous)"
	bMotion_putadmin "  .bmotion abstract flush"
	bMotion_putadmin "    Force all abstracts to be flushed to disk"
	bMotion_putadmin "  .bmotion abstract filter add <abstract> <regexp>"
	bMotion_putadmin "    Add a filter to an abstract"
	bMotion_putadmin "  .bmotion abstract filter list"
	bMotion_putadmin "    List all abstract filters"
	bMotion_putadmin "  .bmotion abstract filter purge"
	bMotion_putadmin "    Purge all filters"
	bMotion_putadmin "  .bmotion abstract filter apply <abstract>"
	bMotion_putadmin "    For an abstract to be filtered now"
	bMotion_putadmin "  .bmotion abstract diagnose"
	bMotion_putadmin "    Test all abstracts for parsability and report any broken ones"
	bMotion_putadmin "  .bmotion abstract reset <abstract>"
	bMotion_putadmin "    Remove everything from an abstract and save it"
	return 0
}


# register the plugin
bMotion_plugin_add_management "abstract" "^abstract" n "bMotion_plugin_admin_abstract" "any" "bMotion_plugin_admin_abstract_help"
