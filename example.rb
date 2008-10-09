require 'coremidi'

# Start archaeopteryx 
# Start GarageBand (just to make sure it's all working)

# Open MIDI Patch Bay.app
# Create a new input (anyname)
# Create a new output (anyname)
# GarageBand will announce that it has found a new input
# You should have sound, yay

# Now run this script


class ExampleMidiConsumer
  include CoreMIDI

  def initialize
    puts CoreMIDI.sources

    # Names are arbitrary
    client = CoreMIDI.create_client("SB")
    port = CoreMIDI.create_input_port(client, "PortA")
    connect_source_to_port(0, port) # 0 is index into CoreMIDI.sources array
  end

  def capture
    while true
     if data = new_data?
       puts data.inspect
     end
   end
  end
end

c = ExampleMidiConsumer.new
c.capture
