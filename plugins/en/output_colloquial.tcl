## bMotion output plugin: colloquial
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

bMotion_plugin_add_output "colloq" bMotion_plugin_output_colloq 1 "en"


#    Attempt to make contractions etc similar to real people
#
proc bMotion_plugin_output_colloq { channel line } {
  global bMotionSettings
  
  set colloq_rate $bMotionSettings(colloq)
  set oldLine $line
  
  if [bMotion_plugin_output_colloq_chance $colloq_rate] { 
    regsub -all -nocase "should( have|\'ve| of)" $line "%VAR{colloq_shouldhave}" line
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] { 
    regsub -all -nocase "shouldn't( have|\'ve| of)" $line "%VAR{colloq_shouldhavenot}" line
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "sort of" $line "sorta" line
    regsub -all -nocase "something" $line "sommat" line
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "cheap" $line "cheep" line
    regsub -all -nocase "seam" $line "seem" line
    regsub -all -nocase "mean" $line "meen" line

  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "exactly" $line "exactily" line
    regsub -all -nocase "separate" $line "seperate" line
    regsub -all -nocase "definitely" $line "definately" line

  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase {[[:<:]]you[[:>:]]} $line "%VAR{colloq_you}" line
    regsub -all -nocase {[[:<:]]your[[:>:]]} $line "%VAR{colloq_your}" line
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    regsub -all -nocase "n't" $line "nt" line
  }

  if [bMotion_plugin_output_colloq_chance $colloq_rate] {
    if {![regexp "\.$" $line]} {
      append line "."
    }
  }

  #don't waste time updating if the line didn't change
  if {$line == $oldLine} {
    return $oldLine
  }

  return [bMotionDoInterpolation $line "" ""]
}

#random chance test
proc bMotion_plugin_output_colloq_chance { freq } {
  if {[rand 1000] <= $freq} {
    return 1
  }
  return 0
}

set colloq_shouldhave {
  "should've"
  "should of"
}

set colloq_shouldhave {
  "shouldnt've"
  "shouldn't of"
  "shouldnt of"
  "shouldnt have"
}

set colloq_you {
  "u"
  "ya"
}

set colloq_your {
  "ur"
}