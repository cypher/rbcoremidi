require 'coremidi/rbcoremidi.bundle'
require 'coremidi/constants'

module CoreMIDI
  module API
    MidiPacket = Struct.new(:timestamp, :data)
  end

  # Unused, but left here for documentation
  def self.number_of_sources
    API.get_num_sources
  end

  class Packet
    def self.parse(data)
      check = lambda {|byte, filter| byte & filter == filter }
      if check[data[0], Constants::NOTE_ON]
        if data[2] == 0
          Events::NoteOff.new(data[0] & Constants::CHANNEL, data[1], data[2])
        else
          Events::NoteOn.new(data[0] & Constants::CHANNEL, data[1], data[2])
        end
      elsif check[data[0], Constants::NOTE_OFF]
        Events::NoteOff.new(data[0] & Constants::CHANNEL, data[1], data[2])
      end
    end
  end

  module Events
    class NoteOn < Struct.new(:channel, :pitch, :velocity)
    end

    class NoteOff < Struct.new(:channel, :pitch, :velocity)
    end
  end

  class Input
    def self.register(client_name, port_name, source)
      raise "name must be a String!" unless client_name.class == String

      client = API.create_client(client_name) 
      port = API.create_input_port(client, port_name)
      API.connect_source_to_port(API.get_sources.index(source), port)

      while true
        API.peek do |data|
          data.each do |packet|
            yield(Packet.parse(packet.data))
          end
        end
        sleep 0.001
      end
    end
  end
end
