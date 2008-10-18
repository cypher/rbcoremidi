$LOAD_PATH.unshift('lib/')
require 'coremidi'

# Start archaeopteryx 
# Start GarageBand (just to make sure it's all working)

# Open MIDI Patch Bay.app
# Create a new input (anyname)
# Create a new output (anyname)
# GarageBand will announce that it has found a new input
# You should have sound, yay

# Now run this script

midi_thread = Thread.new do
  CoreMIDI::Input.register("Test", "Test", "Out") do |event|
    puts event.inspect
  end
end

gets # Stop on enter
