# $Id$
#

###############################################################################
# This is a bMotion module
# Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_abstract_register "prom_first"
bMotion_abstract_batchadd "prom_first" [list "arse" "cack" "piss" "shit" "fuck" "turd" "minge" "crap" "vadge" "shat" "clit" "cum" "wank" "flid" "quim" "jizz" "cream" "pube" "spank"]

bMotion_abstract_register "prom_second"
bMotion_abstract_batchadd "prom_second" [list "puma" "whistle" "shaver" "glass" "flute" "rifle" "flower" "desk" "curtain" "wheel" "door" "coin" "speaker" "lamp" "radio" "twix" "action" "account" "pump" "tea" "pot" "square" "robe" "apple" "cave" "lantern" "drawer" "card" "pants" "bible" "lighthouse" "chair" "stairs" "emperor" "bank"]

bMotion_abstract_register "PROM"
bMotion_abstract_add "PROM" "%VAR{prom_first}-%VAR{prom_second}"