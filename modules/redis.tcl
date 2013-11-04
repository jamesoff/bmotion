set bMotion_has_redis 0
set bMotion_redis ""

if {[info tclversion] < 8.5} {
	putlog "bMotion: redis support requires TCL 8.5 or higher"
} else { 
	catch {
		source $bMotionModules/extra/redis/redis.tcl
		set bMotion_redis [redis]
		putlog "bMotion: redis enabled"
		set bMotion_has_redis 1
	}
}

proc bMotion_redis_available { } {
	global bMotion_has_redis
	return $bMotion_has_redis
}

proc bMotion_redis_cmd args {
	global bMotion_has_redis
	if {!$bMotion_has_redis} {
		return ""
	}
	global bMotion_redis
	return [$bMotion_redis {*}$args]
}

