## bMotion plugin: sucks
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



bMotion_plugin_add_complex "sucks" {sucks?$} 30 bMotion_plugin_complex_sucks "en"



proc bMotion_plugin_complex_sucks { nick host handle channel text } {

  if [regexp -nocase {([^ ]+) ((is|si|==) (teh|the)? )?sucks?} $text matches item] {
    if {$item == "=="} {
      return 0
    }
    bMotionDoAction $channel $item "%VAR{sucks}"
  }
}


bMotion_abstract_register "sucks"
bMotion_abstract_add "sucks" "%% = %VAR{PROM}"


