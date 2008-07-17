
require 'rbcoremidi.bundle'

module CoreMIDI

  def sources
    API.sources
  end
  
  def number_of_sources
    API.get_num_sources
  end
  
  def create_input_port(client_name, port_name, &proc)
    API.create_input_port(client_name, port_name, proc)
  end
end
