$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require File.dirname(__FILE__) + '/../ext/rbcoremidi.bundle'
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
      klass = {
        Constants::NOTE_ON        => lambda {|data| (data[Events::NoteOn.members.index("velocity")] == 0) ? Events::NoteOff : Events::NoteOn },
        Constants::NOTE_OFF       => Events::NoteOff,
        Constants::PROGRAM_CHANGE => Events::ProgramChange
      }.detect {|constant, klass|
        data[0] & Constants::TYPE == constant 
      }

      raise("Unknown MIDI packet") if klass.nil? # TODO: Events::Unknown

      klass = klass.last
      klass = klass.call(data) if klass.respond_to?(:call)

      klass.new(data[0] & Constants::CHANNEL, *data[1..-1])
    end
  end

  module Events
    class NoteOn < Struct.new(:channel, :pitch, :velocity)
    end

    class NoteOff < Struct.new(:channel, :pitch, :velocity)
    end

    class ProgramChange < Struct.new(:channel, :preset)
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
