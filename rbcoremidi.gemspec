Gem::Specification.new do |s|
  s.name = %q{rbcoremidi}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Xavier Shay"]
  s.date = %q{2008-10-20}
  s.description = %q{A gem that provides MIDI in to ruby via OSX CoreMIDI}
  s.email = %q{contact@rhnh.net}
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "examples/example.rb", "ext/extconf.rb", "ext/rbcoremidi.c", "lib/coremidi", "lib/coremidi/constants.rb", "lib/coremidi.rb", "spec/parsing_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://github.com/xaviershay/rbcoremidi}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A gem that provides MIDI in to ruby via OSX CoreMIDI}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
