# bMotion new logging
# modules and plugins can register logging categories with us
# user can add/remove categories
# all logging goes to +d console mode
# if something pushes to a log category we haven't had registered, auto-register it
# an empty list of active categories matches all

# also supported are logging levels: ERROR, WARN, INFO, DEBUG, TRACE
# ERROR goes to putlog
# others are filtered by the current active level


if {![info exists bMotion_log_categories]} {
	set bMotion_log_categories [list]
}

if {![info exists bMotion_log_active]} {
	set bMotion_log_active [list]
}

set BMOTION_LOG_LEVEL(ERROR) 0
set BMOTION_LOG_LEVEL(WARN)  1
set BMOTION_LOG_LEVEL(INFO)  2
set BMOTION_LOG_LEVEL(DEBUG) 3
set BMOTION_LOG_LEVEL(TRACE) 4

if {![info exists bMotion_log_level]} {
	set bMotion_log_level 1
}


proc bMotion_log { category level message } {
	global BMOTION_LOG_LEVEL bMotion_log_level

	set level [bMotion_log_level_int $level]

	if {$level == $BMOTION_LOG_LEVEL(ERROR)} {
		putlog "bMotion ERROR $category: $message"
		return
	}

	if {$level <= $bMotion_log_level} {
		global bMotion_log_categories bMotion_log_active
		set category [string tolower $category]
		if {[lsearch $bMotion_log_categories $category] == -1} {
			if {$bMotion_log_level <= 2} {
				putloglev d * "bMotion INFO  logging: auto-learning category $category"
			}
			lappend bMotion_log_categories $category
		}
		if {([llength $bMotion_log_active] == 0) || ([lsearch $bMotion_log_active $category] >= 0)} {
			set level [bMotion_log_level_string $level]
			regsub -nocase "bmotion: *(.+)" $message {\1} message
			putloglev d * "bMotion $level $category: $message"
			return
		}
	}
}

proc bMotion_log_level_int { level } {
	switch [string toupper $level] {
		"ERROR" { return 0 }
		"WARN"  { return 1 }
		"INFO"  { return 2 }
		"DEBUG" { return 3 }
		"TRACE" { return 4 }
		default { return 0 }
	}
}

proc bMotion_log_level_string { level } {
	switch $level {
		0 { return "ERROR" }
		1 { return "WARN " }
		2 { return "INFO " }
		3 { return "DEBUG" }
		4 { return "TRACE" }
		default { return "UNKWN" }
	}
}


proc bMotion_log_add_category { category } {
	global bMotion_log_categories BMOTION_LOG_LEVEL

	set category [string tolower $category]
	if {[lsearch $bMotion_log_categories $category] == -1} {
		set bMotion_log_categories [lsort [lappend bMotion_log_categories $category]]
		bMotion_log "logging" "DEBUG" "adding category $category"
	} else {
		bMotion_log "logging" "DEBUG" "not adding already known category $category"
	}
}

bMotion_log_add_category "logging"
