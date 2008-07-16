/*
 *  Copyright 2008 Markus Prinz
 *  Released unter an MIT licence
 *
 */

#include <ruby.h>
#include <CoreMIDI/CoreMIDI.h>


VALUE callback_proc = Qnil;

MIDIPortRef inPort = NULL;
MIDIClientRef client = NULL;

static void RbMIDIReadProc(const MIDIPacketList* packetList, void* readProcRefCon, void* srcConnRefCon)
{
    
}

void Init_rbcoremidi (void)
{
  // Add the initialization code of your module here.
}
