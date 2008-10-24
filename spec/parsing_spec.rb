require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Parsing MIDI events' do
  describe 'given data for a note on event' do
    it 'creates a NoteOn event on channel 0' do
      packet = CoreMIDI::Packet.parse([0x90, 0x3C, 0x40]) # Channel 0, Middle C, half velocity
      packet.is_a?(CoreMIDI::Events::NoteOn).should == true
      packet.channel.should == 0x00
      packet.pitch.should == 0x3C
      packet.velocity.should == 0x40
    end

    it 'creates a NoteOn event on channel 1' do
      packet = CoreMIDI::Packet.parse([0x91, 0x3C, 0x40]) # Channel 0, Middle C, half velocity
      packet.is_a?(CoreMIDI::Events::NoteOn).should == true
      packet.channel.should == 0x01
      packet.pitch.should == 0x3C
      packet.velocity.should == 0x40
    end

    it 'creates a NoteOn event when status byte was provided by the last packet'
  end

  describe 'given data for a note off event' do
    it 'creates a NoteOff event on channel 0' do
      packet = CoreMIDI::Packet.parse([0x80, 0x3C, 0x40]) # Channel 0, Middle C, half velocity
      packet.is_a?(CoreMIDI::Events::NoteOff).should == true
      packet.channel.should == 0x00
      packet.pitch.should == 0x3C
      packet.velocity.should == 0x40
    end

    it 'creates a NoteOff event on channel 1' do
      packet = CoreMIDI::Packet.parse([0x81, 0x3C, 0x40]) # Channel 0, Middle C, half velocity
      packet.is_a?(CoreMIDI::Events::NoteOff).should == true
      packet.channel.should == 0x01
      packet.pitch.should == 0x3C
      packet.velocity.should == 0x40
    end

    it 'creates a NoteOff event for data that is actually NoteOn with volume 0' do
      packet = CoreMIDI::Packet.parse([0x90, 0x3C, 0x00]) # Channel 0, Middle C, half velocity
      packet.is_a?(CoreMIDI::Events::NoteOff).should == true
      packet.channel.should == 0x00
      packet.pitch.should == 0x3C
      packet.velocity.should == 0x00
    end
  end

  describe 'given data for a program change event' do
    it 'creates a ProgramChange event on channel 0' do
      packet = CoreMIDI::Packet.parse([0xC0, 0x01]) # Channel 0, Preset #1
      packet.is_a?(CoreMIDI::Events::ProgramChange).should == true
      packet.channel.should == 0x00
      packet.preset.should == 0x01
    end

    it 'creates a ProgramChange event on channel 1' do
      packet = CoreMIDI::Packet.parse([0xC1, 0x02]) # Channel 1, Preset #2
      packet.is_a?(CoreMIDI::Events::ProgramChange).should == true
      packet.channel.should == 0x01
      packet.preset.should == 0x02
    end
  end
end
