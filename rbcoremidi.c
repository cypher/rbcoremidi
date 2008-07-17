/*
 *  Copyright 2008 Markus Prinz
 *  Released unter an MIT licence
 *
 */

#include <ruby.h>
#include <CoreMIDI/MIDIServices.h>

VALUE callback_proc = Qnil;

MIDIPortRef inPort = NULL;
MIDIClientRef client = NULL;

static void RbMIDIReadProc(const MIDIPacketList* packetList, void* readProcRefCon, void* srcConnRefCon)
{
    
}

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

VALUE cCoreMIDI = Qnil;
VALUE mCoreMIDIAPI = Qnil;

void Init_rbcoremidi (void)
{
    cCoreMIDI = rb_define_class("CoreMIDI", rb_cObject);
    mCoreMIDIAPI = rb_define_module_under(cCoreMIDI, "API");
    
    rb_define_method(mCoreMIDIAPI, "get_sources", t_get_sources, 0);
    rb_define_method(mCoreMIDIAPI, "get_num_sources", t_get_num_sources, 0);
}
