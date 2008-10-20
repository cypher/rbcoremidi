require 'mkmf'
$CPPFLAGS += " -I/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/Headers"
$LDFLAGS += " -framework CoreMIDI"

create_makefile('rbcoremidi')
