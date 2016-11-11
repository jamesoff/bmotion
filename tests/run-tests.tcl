package require tcltest
namespace import ::tcltest::*

::tcltest::configure -testdir tests
#::tcltest::configure -debug 3
#::tcltest::configure -verbose { body pass skip start error line }

runAllTests
