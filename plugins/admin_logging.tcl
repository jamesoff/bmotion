# bMotion logging admin plugin
#

proc bMotion_plugin_management_logging { handle { args "" } } {
	global BMOTION_LOG_LEVEL bMotion_log_level bMotion_log_categories bMotion_log_active

	set args [lindex $args 0]
	if {$args == ""} {
		set level [bMotion_log_level_string $bMotion_log_level]
		bMotion_putadmin "Current log level is $level. Change with .bmotion log level LEVEL"

		if {[llength $bMotion_log_active] == 0} {
			bMotion_putadmin "Currently showing logs from all categories. "
		} else {
			bMotion_putadmin "Currently showing logs from $bMotion_log_active"
		}
		bMotion_putadmin "Use .bmotion log categories to view all, .bmotion log categories CATS where CATS is cat1,cat2 or +cat1 or -cat1 to change."
		return
	}

	if {[regexp -nocase {level ([a-z]+)} $args matches level]} {
		set level [string toupper $level]
		set l -1
		catch {
			set l $BMOTION_LOG_LEVEL($level)
		}
		if {$l > -1} {
			set bMotion_log_level $l
			bMotion_putadmin "Log level changed to $level"
		} else {
			bMotion_putadmin "Unknown log level."
		}
		return
	}
	
	if {[regexp -nocase {categor(y|ies)( .+)?} $args matches skip categories]} {
		global bMotion_log_categories bMotion_log_active
		if {$categories == ""} {
			bMotion_putadmin "Available log categories:"
			bMotion_putadmin $bMotion_log_categories
			return
		}
		set categories [string trim [string tolower $categories]]

		# "all" clears the list, which means all categories
		if {$categories == "all"} {
			bMotion_putadmin "Setting log categories to (all)"
			set bMotion_log_active [list]
			return
		}

		# check if + or - is in the string, if not we're just setting new categories
		set first_char [string index $categories 0]
		if {($first_char != "+") && ($first_char != "-")} {
			set cat_list [split $categories ","]
			set all_ok 1
			foreach cat $cat_list {
				if {[lsearch $bMotion_log_categories $cat] == -1} {
					set all_ok 0
					bMotion_putadmin "Unknown category $cat"
				}
			}
			if {$all_ok} {
				set bMotion_log_active $cat_list
				bMotion_putadmin "Setting log categories to $cat_list"
			} else {
				bMotion_putadmin "Not changing active category list."
			}
			return
		}

		# it's a list of differences
		set cat_list [split $categories ","]
		set all_ok 1
		set new_categories $bMotion_log_active
		foreach cat $cat_list {
			set first_char [string index $cat 0]
			set cat_name [string range $cat 1 end]
			if {[lsearch $bMotion_log_categories $cat_name] == -1} {
				set all_ok 0
				bMotion_putadmin "Unknown category '$cat_name'"
			} else {
				switch $first_char {
					"+" { 
						lappend $new_categories $cat_name
						set new_categories [lsort -unique $new_categories]
					}
					"-" { 
						if {[llength $new_categories] == 0} {
							set new_categories $bMotion_log_categories
						}
						set index [lsearch $new_categories $cat_name]
						if {$index > -1} {
							set new_categories [lreplace $new_categories $index $index]
						}
					}
					default { 
						set all_ok 0
						bMotion_putadmin "Unknown category operator $first_char"
					}
				}
			}
		}
		if {$all_ok} {
			set new_categories [lsort -unique $new_categories]
			if [llength $new_categories] {
				bMotion_putadmin "Setting log category to $new_categories"
			} else {
				bMotion_putadmin "Setting log categories to (all)"
			}
			set bMotion_log_active $new_categories
		} else {
			bMotion_putadmin "Not changing active category list"
		}
		return
	}
}

bMotion_plugin_add_management "logging" "^log(ging)?" n bMotion_plugin_management_logging "any"

