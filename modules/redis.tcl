set bMotion_has_redis 0
set bMotion_redis ""

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

if {[info tclversion] < 8.5} {
	putlog "bMotion: redis support requires TCL 8.5 or higher"
} else { 
	catch {
		source $bMotionModules/extra/redis/redis.tcl
		set bMotion_redis [redis $bMotionSettings(redis_server) $bMotionSettings(redis_port)]
		if {$bMotionSettings(redis_auth) != ""} {
			$bMotion_redis auth $bMotionSettings(redis_auth)
		}
		$bMotion_redis select $bMotionSettings(redis_database)
		putlog "bMotion: redis enabled"
		set bMotion_has_redis 1
	}
	
}

# clear the password variable so it's not sitting around for people to find
set bMotionSettings(redis_auth) ""
