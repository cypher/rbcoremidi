/*
 *  Copyright 2008 Markus Prinz
 *  Released unter an MIT licence
 *
 */

#include <ruby.h>
#include <CoreMIDI/MIDIServices.h>
#include <pthread.h>
#include <stdlib.h>

VALUE callback_proc = Qnil;

MIDIPortRef inPort = NULL;
MIDIClientRef midi_client = NULL;

pthread_mutex_t mutex;

CFMutableArrayRef midi_data = NULL;

VALUE mCoreMIDI = Qnil;
VALUE mCoreMIDIAPI = Qnil;

// We need our own data structure since MIDIPacket defines data to be a 256 byte array,
// even though it can be larger than that
typedef struct RbMIDIPacket_t {
    MIDITimeStamp timeStamp;
    UInt16 length;
    Byte* data;
} RbMIDIPacket;

// Forward declare free_objects
static void free_objects();

// The callback function that we'll eventually supply to MIDIInputPortCreate
static void RbMIDIReadProc(const MIDIPacketList* packetList, void* readProcRefCon, void* srcConnRefCon)
{
    if( pthread_mutex_lock(&mutex) != 0 )
    {
        // uh oh
        // Not much we can do
        return;
    }
    
    MIDIPacket* current_packet = (MIDIPacket*) packetList->packet;

    unsigned int j;
    for( j = 0; j < packetList->numPackets; ++j )
    {
        RbMIDIPacket* rb_packet = (RbMIDIPacket*) malloc( sizeof(RbMIDIPacket) );
        
        if( rb_packet == NULL )
        {
            fprintf(stderr, "Failed to allocate memory for RbMIDIPacket!\n");
            abort();
        }
        
        rb_packet->timeStamp = current_packet->timeStamp;
        rb_packet->length = current_packet->length;
        
        size_t size = sizeof(Byte) * rb_packet->length;
        rb_packet->data = (Byte*) malloc( size );
        
        if( rb_packet->data == NULL )
        {
            fprintf(stderr, "Failed to allocate memory for RbMIDIPacket data!\n");
            abort();
        }
        
        memcpy(rb_packet->data, current_packet->data, size);
        
        CFArrayAppendValue(midi_data, rb_packet);
        
        current_packet = MIDIPacketNext(current_packet);
    }
    
    pthread_mutex_unlock(&mutex);
}

// Checks for new data and copies it over if there is some.
static VALUE t_check_for_and_copy_new_data(VALUE self)
{
    if( pthread_mutex_trylock(&mutex) != 0 )
    {
        // no data for us yet
        return Qfalse;
    }
    
    // Switch out the arrays. Possibly evil
    CFArrayRef data = midi_data;
    midi_data = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    
    pthread_mutex_unlock(&mutex);
    
    // We'll use a Struct to store the data
    VALUE cMidiPacket = rb_const_get(mCoreMIDIAPI, rb_intern("MidiPacket"));
    
    VALUE rb_midi_data = rb_iv_get(self, "@midi_data");
    
    CFIndex idx = 0;
    CFIndex array_size = CFArrayGetCount(midi_data);
    const RbMIDIPacket* current_packet = NULL;
    
    for( ; idx < array_size; ++idx ) {
        current_packet = (const RbMIDIPacket*) CFArrayGetValueAtIndex(data, idx);
        
        VALUE byte_array = rb_ary_new2(current_packet->length);
        
        int i;
        for (i = 0; i < current_packet->length; ++i) {
            rb_ary_push(byte_array, INT2FIX(current_packet->data[i]));
        }
        
        VALUE midi_packet_args[2];
        // relies on sizeof(MIDITimeStamp) == sizeof(unsigned long long)
        midi_packet_args[0] = ULL2NUM(current_packet->timeStamp);
        midi_packet_args[1] = byte_array;
        
        rb_ary_push(rb_midi_data, rb_class_new_instance((sizeof(midi_packet_args)/sizeof(midi_packet_args[0])), midi_packet_args, cMidiPacket));
        
        // While we're at it..
        // Free the memory! Save the whales!
        free(current_packet->data);
    }
    
    // Free the memory! Save the whales! Part 2!
    CFRelease(data);
    
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

static void free_objects()
{
    pthread_mutex_destroy(&mutex);
    
    if( midi_data != NULL )
    {
        if( CFArrayGetCount(midi_data) > 0 )
        {
            int i;
            for( i = 0; i < CFArrayGetCount(midi_data); ++i )
            {
                free(((const RbMIDIPacket*) CFArrayGetValueAtIndex(midi_data, i))->data);
            }
        }
        
        CFRelease(midi_data);
    }
}

void Init_rbcoremidi()
{
    int mutex_init_result = pthread_mutex_init(&mutex, NULL);
    
    if( mutex_init_result != 0 )
    {
        rb_sys_fail("Failed to allocate mutex");
    }
    
    midi_data = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    
    if( midi_data == NULL )
    {
        free_objects();
        rb_sys_fail("Failed to allocate CFMutableArray");
    }
    
    // Poor Ruby programmers destructor
    if( atexit(free_objects) != 0 )
    {
        free_objects();
        rb_sys_fail("Failed to register atexit function");
    }
    
    mCoreMIDI = rb_define_module("CoreMIDI");
    mCoreMIDIAPI = rb_define_module_under(mCoreMIDI, "API");
    
    rb_define_singleton_method(mCoreMIDIAPI, "create_input_port", t_create_input_port, 3);
    rb_define_singleton_method(mCoreMIDIAPI, "get_sources", t_get_sources, 0);
    rb_define_singleton_method(mCoreMIDIAPI, "get_num_sources", t_get_num_sources, 0);
    rb_define_singleton_method(mCoreMIDIAPI, "check_for_and_copy_new_data", t_check_for_and_copy_new_data, 0);
    
    VALUE rb_midi_data = rb_ary_new();
    rb_iv_set(mCoreMIDIAPI, "@midi_data", rb_midi_data);
}
