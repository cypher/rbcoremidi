
require 'rbcoremidi.bundle'

module CoreMIDI
  module API
    MidiPacket = Struct.new(:timestamp, :data)
  end
  
  def self.sources
    API.get_sources
  end
  
  def self.number_of_sources
    API.get_num_sources
  end
  
  def self.create_input_port(client_name, port_name, &proc)
    # AFAIK this is the only way to pass the proc to a C function
    API.create_input_port(client_name, port_name, proc)
  end
end
