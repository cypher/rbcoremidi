/*
 *  Copyright 2008 Markus Prinz
 *  Released unter an MIT licence
 *
 */

#include <ruby.h>
#include <CoreMIDI/MIDIServices.h>
#include <pthread.h>

VALUE callback_proc = Qnil;

MIDIPortRef inPort = NULL;
MIDIClientRef midi_client = NULL;

pthread_mutex_t mutex;

// The callback function that we'll eventually supply to MIDIInputPortCreate
static void RbMIDIReadProc(const MIDIPacketList* packetList, void* readProcRefCon, void* srcConnRefCon)
{
    pthread_mutex_lock(&mutex);
    
    /*
     MIDIPacket *packet = (MIDIPacket *)pktlist->packet;	// remove const (!)
     for (unsigned int j = 0; j < pktlist->numPackets; ++j) {
     for (int i = 0; i < packet->length; ++i) {
     //				printf("%02X ", packet->data[i]);
     
     // rechannelize status bytes
     if (packet->data[i] >= 0x80 && packet->data[i] < 0xF0)
     packet->data[i] = (packet->data[i] & 0xF0) | gChannel;
     }
     
     //			printf("\n");
     packet = MIDIPacketNext(packet);
     */
    
    pthread_mutex_unlock(&mutex);
}

static VALUE t_check_for_new_data(VALUE self)
{
    if( pthread_mutex_trylock(&mutex) != 0 )
    {
        // no data for us yet
        return Qfalse;
    }
    
    
    pthread_mutex_unlock(&mutex);
    
    return Qtrue;
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
static VALUE t_get_sources(VALUE self)
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

void Init_rbcoremidi()
{
    int mutex_init_result = pthread_mutex_init(&mutex, NULL);
    
    if( mutex_init_result != 0 )
    {
        rb_sys_fail("Failed to allocate mutex");
    }
    
    mCoreMIDI = rb_define_module("CoreMIDI");
    mCoreMIDIAPI = rb_define_module_under(mCoreMIDI, "API");
    
    rb_define_singleton_method(mCoreMIDIAPI, "create_input_port", t_create_input_port, 3);
    rb_define_singleton_method(mCoreMIDIAPI, "get_sources", t_get_sources, 0);
    rb_define_singleton_method(mCoreMIDIAPI, "get_num_sources", t_get_num_sources, 0);
}
