# vim: fdm=indent fdn=1
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2009
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


# built-in processing, %VAR
# syntax: %VAR{abstract}
#         %VAR{abstract:options}
# options: a comma-separated list of options
#          strip: remove a/an/the/some from the beginning of the abstract
#          owner: make possessive
#          plural: make plural
#          verb: verbise
# Not all combinations of options are a good idea

proc bMotion_plugin_output_VAR { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_VAR $channel $line"
	global BMOTION_MIXIN_NONE BMOTION_MIXIN_REVERSE BMOTION_MIXIN_DEFAULT BMOTION_MIXIN_BOTH
	global BMOTION_MIXIN_MALE BMOTION_MIXIN_FEMALE
	
	set line [string map { "%noun" "%VAR{sillyThings}" } $line]

	# transform %VAR{abstract}{strip} to new form
	regsub {%VAR\{([^\}]+)\}\{strip\}} $line "%VAR{\\1:strip}" line

	if {[regexp -nocase {(%VAR\{([^\}:]+)(:([^\}]+))?\}(\{strip\})?)} $line matches whole_thing abstract 1 options clean]} {
		global $abstract

		bMotion_putloglev 1 * "options for $abstract are $options"

		# check options
		if {$options != ""} {
			set options_list [split $options ","]
		} else {
			set options_list [list]
		}
		bMotion_putloglev 1 * "options list is $options_list"

		if {$clean == "{strip}"} {
			lappend options_list "clean"
		}

		set mixin_type $BMOTION_MIXIN_DEFAULT

		if {[lsearch $options_list "revmixin"] > -1} {
			bMotion_putloglev 1 * "mixin type for $abstract is reverse"
			set mixin_type $BMOTION_MIXIN_REVERSE
		} elseif {[lsearch $options_list "nomixin"] > -1} {
			bMotion_putloglev 1 * "mixin type for $abstract is none"
			set mixin_type $BMOTION_MIXIN_NONE
		} elseif {[lsearch $options_list "bothmixin"] > -1} {
			bMotion_putloglev 1 * "mixin type for $abstract is both"
			set mixin_type $BMOTION_MIXIN_BOTH
		} elseif {[lsearch $options_list "malemixin"] > -1} {
			bMotion_putloglev 1 * "mixin type for $abstract is male"
			set mixin_type $BMOTION_MIXIN_MALE
		} elseif {[lsearch $options_list "femalemixin"] > -1} {
			bMotion_putloglev 1 * "mixin type for $abstract is female"
			set mixin_type $BMOTION_MIXIN_FEMALE
		}

		#see if we have a new-style abstract available
		set newText [bMotion_abstract_get $abstract $mixin_type]
		set replacement ""
		if {$newText == ""} {
			bMotion_putloglev d * "abstract '$abstract' doesn't exist in new abstracts system!"
			#insert old style
			if [catch {
				set var [subst $$abstract]
				set replacement [pickRandom $var]
			}] {
				bMotion_putloglev d * "Unable to handle %VAR{$abstract}"
				return ""
			}
		} else {
			set replacement $newText
		}

		if {[lsearch $options_list "strip"] == -1} {
			if {$abstract == "sillyThings"} {
				if {[rand 100] > 90} {
					set mode [rand 2]
					switch $mode {
						0 {
							set prefixes [list]
							set replacement [bMotion_strip_article $replacement]
							if [regexp -nocase "s$" $replacement] {
								set prefixes [list "des " "les "]
							} elseif [regexp -nocase "^\[aeiouy\]" $replacement] {
								set prefixes [list "d'" "l'"]
							} else {
								set prefixes [list "de la " "du " "la " "le " "un " "une "]
							}
							set prefix [pickRandom $prefixes]
							set replacement "$prefix$replacement"
						}
						1 {
							regsub "((an?|the|some|his|her|their) )?" $replacement "\\1%VAR{noun_prefix} " replacement
							set replacement [string trim $replacement]
						}
					}
				}
			}
		}

		foreach option $options_list {
			switch $option {
				"prev" {
					set replacement [bMotion_plugins_settings_get "output:VAR" "last" $channel "$abstract"]
				}
				"prevtriplet" {
					set replacement [bMotion_plugins_settings_get "output:VAR" "last:pretriplet" $channel $abstract]
				}
				"strip" {
					set replacement [bMotion_strip_article $replacement]
				}
				"verb" {
					set replacement [bMotionMakeVerb $replacement]
				}
				"past" {
					set replacement [bMotion_make_past_tense $replacement]
				}
				"presentpart" {
					set replacement [bMotion_make_present_participle $replacement]
				}
				"present" {
					set replacement [bMotion_make_simple_present $replacement]
				}
				"plural" {
					bMotion_putloglev 1 * "pluralising $replacement"
					set replacement [bMotionMakePlural $replacement]
					if {[rand 100] > 90} {
						set replacement [bMotion_strip_article $replacement]
						putlog "plural: options list is $options_list"
					}
				}
				"title" {
					set replacement [string totitle $replacement]
				}
				"camel" {
					bMotion_putloglev 3 * "camelising $replacement"
					set newreplacement ""
					foreach word $replacement {
						set word [string totitle $word]
						#TODO: generalise
						if {[string range $word 0 3] == "%var"} {
							set word [string replace $word 0 3 "%VAR"]
						}
						bMotion_putloglev 4 * "camelise: adding $word to output"
						append newreplacement "$word "
					}
					set replacement [string trim $newreplacement]
				}
				"owner" {
					set replacement [bMotionMakePossessive $replacement]
				}
				"removeowner" {
					regsub -nocase "'s?$" $replacement "" replacement
				}
				"underscore" {
					set replacement [string map { " " "_" } $replacement]
				}
				"caps" {
					set replacement [string toupper $replacement]
				}
				"triplet" {
					bMotion_plugins_settings_set "output:VAR" "last:pretriplet" $channel $abstract $replacement
					set temp [bMotion_find_triplet $replacement]
					if {$temp == ""} {
						putlog "triplet is blank"
						return ""
					}
					set replacement $temp
				}
				"like" {
					bMotion_putloglev d * "Learning to like $replacement during %VAR expansion"
					bMotion_abstract_add "_bmotion_like" $replacement
				}
				"dislike" {
					bMotion_putloglev d * "Learning to dislike $replacement during %VAR expansion"
					bMotion_abstract_add "_bmotion_dislike" $replacement
				}
				"lower" {
					set replacement [string tolower $replacement]
				}
			}
			bMotion_putloglev 1 * "current replacement is $replacement"
		}

		set location [string first $whole_thing $line]
		if {$location == -1} {
			# something's broken
			putlog "bMotion: error parsing $whole_thing in $line, unable to insert $replacement"
			return ""
		}

		bMotion_plugins_settings_set "output:VAR" "last" $channel $abstract $replacement
		set line [string replace $line $location [expr $location + [string length $matches] - 1] $replacement]

		# check if what we swapped in gave us a %noun
		set line [string map { "%noun" "%VAR{sillyThings}" } $line]
	}

	return $line
}

proc bMotion_find_triplet { word } {
  set start 0
	if {[string length $word] < 3} {
		return ""
	}

	set results [list]

	while {[regexp -start $start -nocase -indices {([^aeiou ][aeiou][^aeiou ])} $word matches a]} {
		lappend results [string range $word [lindex $a 0] [lindex $a 1]]
		set start [lindex $a 1]
	}

	if {[llength $results] == 0} {
		return ""
	}

	return [pickRandom $results]
}

bMotion_plugin_add_output "VAR" bMotion_plugin_output_VAR 1 "en" 3
