###config

## enable?
set bMotion_stats_enabled 1

## what can we send?
# this is the bot's nick
set bMotion_stats_send(botnick) 1
# the admin info ('admin' in config)
set bMotion_stats_send(admin) 1
# the network name ('network' in config)
set bMotion_stats_send(network) 1
# bmotion's gender/orientation
set bMotion_stats_send(bminfo) 1

##server (leave this)
set bMotion_stats_server "sakaki.jamesoff.net"
set bMotion_stats_port 1337

proc bMotion_stats_send { } {
	global bMotion_stats_server bMotion_stats_port
	global bMotion_stats_enabled

	if {!$bMotion_stats_enabled} {
		return 0
	}
	
	set idx [connect $bMotion_stats_server $bMotion_stats_port]
	if {$idx} {
	  putlog "bMotion: successfully connected to stats server $bMotion_stats_server"
	  control $idx bMotion_stats_handler
	} else {
	  putlog "bMotion: unable to connect to stats server :("
	}
}

proc bMotion_stats_code { text } {
	set code ""
	regexp {^([0-9]+) } $text match code
	return $code
}

proc bMotion_stats_handler { idx text } {
	global bMotion_stats_id bMotion_stats_key
	global bMotion_stats_send bMotionVersion
	
	if {$text == ""} {
		putlog "bMotion: stats server disconnected me"
	}
	
	#putlog "got $text from connection"
	set code [bMotion_stats_code $text]
	#putlog "code is $code"
	if {$code == 250} {
		putlog "bMotion: communicating with stats server..."
		putidx $idx "bm_ver: $bMotionVersion"
		putidx $idx "egg_ver: unknown"
		putidx $idx "tcl_ver: [info patchlevel]"

		#optional stuff
		if {$bMotion_stats_send(botnick)} {
			global botnick
			putidx $idx "botnick: $botnick"
		}

		if {$bMotion_stats_send(admin)} {
			global admin
			putidx $idx "owner: $admin"
		}

		if {$bMotion_stats_send(network)} {
			global network
			putidx $idx "network: $network"
		}

		if {$bMotion_stats_send(bminfo)} {
			global bMotionInfo
			putidx $idx "bm_gender: $bMotionInfo(gender)"
			putidx $idx "bm_orient: $bMotionInfo(orientation)"
		}
		
		if {$bMotion_stats_id != ""} {
			#we have an id already, send it
			putidx $idx "id: $bMotion_stats_id"
			putidx $idx "key: $bMotion_stats_key"
		}
		putidx $idx "done"
	}

	if {$code == 251} {
		bMotion_putloglev 1 * "server is creating a new ID for me"
	}

	if {$code == 252} {
		if [regexp "252 id: (.+)" $text matches id] {
			bMotion_putloglev 1 * "my new id is $id"
			set bMotion_stats_id $id
		}
		if [regexp "252 key: (.+)" $text matches key] {
			bMotion_putloglev 1 * "my new key is $key"
			set bMotion_stats_key $key
		}
	}

	if {$code == 253} {
		bMotion_putloglev 1 * "server has saved my stats"
		bMotion_stats_write
	}

	if {$code == 230} {
		bMotion_putloglev 1 * "communication complete"
		putlog "bMotion: stats sent successfully"
		return 1
	}

	if {$code == 550} {
		bMotion_putloglev 1 * "error: no sql, aborting"
		putlog "bMotion: stats failed to send"
		return 1
	}

	if {$code == 510} {
		bMotion_putloglev 1 * "error: server didn't like our input, aborting"
		putlog "bMotion: stats failed to send"
		return 1
	}

	if {$code == 551} {
		bMotion_putloglev 1 * "error: server couldn't generate an id, aborting"
		putlog "bMotion: stats failed to send"
		return 1
	}

	if {$code == 552} {
		bMotion_putloglev 1 * "error: server couldn't save stats, aborting"
		putlog "bMotion: stats failed to send"
		return 1
	}
		
	return 0
}

proc bMotion_stats_check { force } {
	global bMotionModules bMotion_stats_id bMotion_stats_key

	set line ""
	
	catch {
		set fileHandle [open "$bMotionModules/stats.txt" "r"]
		set line [gets $fileHandle]
	} 
	
	if {$line != ""} {
		set ts $line 
		set now [clock seconds]
		set diff [expr $now - $ts]
		if {$force || ($diff > 604800)} {
			putlog "bMotion: last stats run was $diff seconds ago, resending..."
			#one week difference
			set bMotion_stats_id [gets $fileHandle]
			set bMotion_stats_key [gets $fileHandle]
			bMotion_stats_send
		}
		close $fileHandle
	} else {
		#no file
		putlog "bMotion: sending stats..."
		bMotion_stats_send
	}
}

proc bMotion_stats_write { } {
	global bMotion_stats_id bMotion_stats_key bMotionModules	
	set fileHandle [open "$bMotionModules/stats.txt" "w"]

	puts $fileHandle [clock seconds]
	puts $fileHandle $bMotion_stats_id
	puts $fileHandle $bMotion_stats_key
	close $fileHandle
}

proc bMotion_stats_delbind { } {
	#find our bind and delete it from the timeline
	set binds [binds time]
	foreach bind $binds {
		if {[lindex $bind 4] == "bMotion_stats_auto"} {
			#this is us
			unbind time - [lindex $bind 2] bMotion_stats_auto
		}
	}
}

proc bMotion_stats_auto { minute hour day month year } {
	bMotion_stats_check 0
}

#init
set bMotion_stats_id ""
set bMotion_stats_key ""

#check daily to see if we should send stats
bMotion_stats_delbind
set min [expr int(rand() * 58 + 1)]
set hour [expr int(rand() * 22 + 1)]
bind time - "$min $hour * * *" bMotion_stats_auto

#make sure we're synced
bMotion_stats_check 0

