
require 'rbcoremidi.bundle'

module CoreMIDI

  def sources
    API.sources
  end
  
  def number_of_sources
    API.get_num_sources
  end
  
  def create_input_port(client_name, port_name, &proc)
    # AFAIK this is the only way to pass the proc to a C function
    API.create_input_port(client_name, port_name, proc)
  end
end
