# bMotion redis import
#
# Hello!
# This script reads existing bMotion data and imports it into redis
#
# Run it from the bMotion directory, not from tools/
# Run it with tclsh, like this: tclsh tools/redis_import.tcl
# Your tclsh may have a version number on it so it would be called
# something like "tclsh8.5" instead.
#
# You can run this script multiple times without causing problems.
# You can run this script while the bot is running without causing problems.

proc wrong_dir { } {
	puts "Please run this from the bMotion root directory (e.g. eggdrop/scripts/bmotion)."
	puts "Use an invocation like 'tclsh tools/redis_import.tcl'"
	exit
}

puts "bMotion redis importer"
puts "----------------------\n"

# Check we're in the right place
if {![file isdirectory "local"]} {
	wrong_dir
}

if {![file isdirectory "modules"]} {
	wrong_dir
}

set redis_available 0
catch {
	source modules/extra/redis/redis.tcl
	set r [redis]
	puts "redis initialised :)"
	set redis_available 1
}

if {$redis_available == 0} {
	puts "redis not available, aborting"
	exit
}

puts ""
puts "Importing facts..."

set fh [open local/facts/facts.txt r]
set line [gets $fh]
set count 0
while {![eof $fh]} {
	set line [string trim $line]
	if {$line != ""} {
		regexp {([^,]+),([^ ]+) (.+)} $line matches type item fact
		incr count
		$r set "fact:$type:item" $fact
		set line [gets $fh]
	}
}
close $fh

puts "Imported $count facts."

puts ""
puts "Importing abstracts..."

set abstract_dirs [glob -directory local/abstracts *]
puts "Found [llength $abstract_dirs] languages."

foreach dir $abstract_dirs {
	set lang [file tail $dir]
	puts -nonewline "  Importing from $lang..."
	set files [list]
	catch {
		set files [glob -directory $dir *.txt]
	}
	puts "  Found [llength $files] files."
	set count 0
	set items 0
	foreach f $files {
		incr count
		set fh [open $f r]
		set abstract [file rootname [file tail $f]]
		set line [gets $fh]
		while {![eof $fh]} {
			set line [string trim $line]
			if {$line != ""} {
				incr items
				$r set "abstract:$lang:$abstract" "$line"
			}
			set line [gets $fh]
		}
	}
	puts "  $items items imported from $count abstracts."
	puts ""
}
 puts "\n~fin~"

