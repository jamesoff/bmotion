set bMotion_metakit_available 1

if { [catch { package require Mk4tcl }]} {
	putlog "bMotion: Metakit is not installed"
	set bMotion_metakit_available 0
}

if { $bMotion_metakit_available } {
	set open [mk::file open]
	if {[llength open] > 0} {
		mk::file close bmotion
	}

	mk::file open bmotion $bMotionLocal/bMotion.db
	putlog "bMotion: metakit enabled"
}

proc bMotion_has_metakit { } {
	global bMotion_metakit_available
	return $bMotion_metakit_available
}

proc bMotion_metakit_update { tag table cond_field cond_key update_field update_value } {
	# Select row(s) with cond_field == cond_key
	# and update them to have update_field = update_value
	global bMotion_metakit_available
	if {!$bMotion_metakit_available} {
		return 0
	}
	
	bMotion_putloglev 2 * "metakit: updating $tag.$table to have $update_field=$update_value where $cond_field=$cond_key"

	set rows [mk::select $tag.$table $cond_field $cond_key]
	bMotion_putloglev 2 * "metakit: rows matching $cond_field=$cond_key for update: $rows ([llength $rows])"
	if {[llength $rows] == 0} {
		# insert instead
		bMotion_putloglev 2 * "metakit: inserting new row instead of updating"
		mk::row append $tag.$table $cond_field $cond_key $update_field $update_value
		mk::file commit $tag
		return 1
	}

	foreach i $rows {
		bMotion_putloglev 2 * "metakit: updating row $tag.$table!$i"
		mk::set $tag.$table!$i $update_field $update_value
	}
	mk::file commit $tag

	return [llength rows]
}


proc bMotion_metakit_get_single { tag table cond_field cond_key field } {
	# Fetch the value for a single row
	# If multiple rows match, return nothing
	if [bMotion_has_metakit] {
		bMotion_putloglev 2 * "metakit: select $field from $table where $cond_field = $cond_key limit 1"
		set rows [mk::select $tag.$table -exact $cond_field $cond_key]
		if {[llength rows] == 1} {
			set rownum [lindex 0]
			set value [mk::get $tag.$table!$rownum $field]
			bMotion_putloglev 2 * "metakit: --> $value"
			return $value
		} else {
			bMotion_putloglev 2 * "metakit: [llength $rows] matches so not returning anything"
			return ""
		}
	} else {
		return ""
	}
}

proc bMotion_metakit_dump { tag table } {
	# Dump a table to the partyline
	# Strictly a debugging command :)
	if [bMotion_has_metakit] {
		putlog "Dumping metakit $tag.$table..."
		mk::loop c $tag.$table { putlog [ mk::get $c ] }
	}
}
