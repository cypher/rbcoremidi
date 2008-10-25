require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Parsing MIDI events' do
  def self.it_parses(data, expected)
    describe "the event created given data #{data.inspect}" do
      before(:each) do  
        @packet = CoreMIDI::Packet.parse(data)
      end

      it "is of type #{expected.class}" do
        @packet.class.should == expected.class
      end

      expected.members.each do |member|
        it "has a #{member} of #{expected.send(member)}" do
          @packet.send(member).should == expected.send(member)
        end
      end
    end
  end

  it_parses([0x90, 0x3C, 0x40], CoreMIDI::Events::NoteOn.new(0x00, 0x3C, 0x40)) # Channel 0, Middle C, half velocity
  it_parses([0x91, 0x3C, 0x40], CoreMIDI::Events::NoteOn.new(0x01, 0x3C, 0x40)) # Channel 1, Middle C, half velocity
  it_parses([0x80, 0x3C, 0x40], CoreMIDI::Events::NoteOff.new(0x00, 0x3C, 0x40)) # Channel 0, Middle C, half velocity
  it_parses([0x81, 0x3C, 0x40], CoreMIDI::Events::NoteOff.new(0x01, 0x3C, 0x40))  # Channel 1, Middle C, half velocity
  it_parses([0xC0, 0x01], CoreMIDI::Events::ProgramChange.new(0x00, 0x01)) # Channel 0, Preset #1
  it_parses([0xC1, 0x02], CoreMIDI::Events::ProgramChange.new(0x01, 0x02)) # Channel 1, Preset #2

  # This is technically a NoteOn event, but convention uses it most often in place of a note off event (setting velocity to 0)
  it_parses([0x90, 0x3C, 0x00], CoreMIDI::Events::NoteOff.new(0x00, 0x3C, 0x00))  # Channel 0, Middle C, no velocity

  it 'creates a NoteOn event when status byte was provided by the last packet'
end
