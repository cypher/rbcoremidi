/*
 *  Copyright 2008 Markus Prinz
 *  Released unter an MIT licence
 *
 */

#include <ruby.h>
#include <CoreMIDI/MIDIServices.h>

VALUE callback_proc = Qnil;

MIDIPortRef inPort = NULL;
MIDIClientRef midi_client = NULL;

// The callback function that we'll eventually supply to MIDIInputPortCreate
static void RbMIDIReadProc(const MIDIPacketList* packetList, void* readProcRefCon, void* srcConnRefCon)
{
    // Nothing to see here (yet)
    
}

// Create a new Input Port and saves the Ruby Callback proc.
static VALUE t_create_input_port(VALUE self, VALUE client_name, VALUE port_name, VALUE proc)
{    
    CFStringRef client_str = CFStringCreateWithCString(kCFAllocatorDefault, RSTRING(client_name)->ptr, kCFStringEncodingASCII);
    MIDIClientCreate(client_str, NULL, NULL, &midi_client);
    CFRelease(client_str);
    
    CFStringRef port_str = CFStringCreateWithCString(kCFAllocatorDefault, RSTRING(port_name)->ptr, kCFStringEncodingASCII);
    MIDIInputPortCreate(midi_client, port_str, RbMIDIReadProc, NULL, &inPort);
    CFRelease(port_str);
    
    callback_proc = proc;
    
    return Qtrue;
}

// Return an array of all available sources, filled with the names of the sources
static VALUE t_sources(VALUE self)
{    
    int number_of_sources = MIDIGetNumberOfSources();
    
    VALUE source_ary = rb_ary_new2(number_of_sources);
    
    int idx;
    for(idx = 0; idx < number_of_sources; ++idx)
    {
        MIDIEndpointRef src = MIDIGetSource(idx);
        CFStringRef pname;
        char name[64];
        
        MIDIObjectGetStringProperty(src, kMIDIPropertyName, &pname);
        CFStringGetCString(pname, name, sizeof(name), 0);
        CFRelease(pname);
        
        rb_ary_push(source_ary, rb_str_new2(name));
    }
    
    return source_ary;
}

static VALUE t_get_num_sources(VALUE self)
{
    return INT2FIX(MIDIGetNumberOfSources());
}

VALUE mCoreMIDI = Qnil;
VALUE mCoreMIDIAPI = Qnil;

void Init_rbcoremidi (void)
{
    mCoreMIDI = rb_define_module("CoreMIDI");
    mCoreMIDIAPI = rb_define_module_under(cCoreMIDI, "API");
    
    rb_define_method(mCoreMIDIAPI, "create_input_port", t_create_input_port, 3);
    rb_define_method(mCoreMIDIAPI, "get_sources", t_get_sources, 0);
    rb_define_method(mCoreMIDIAPI, "get_num_sources", t_get_num_sources, 0);
}
