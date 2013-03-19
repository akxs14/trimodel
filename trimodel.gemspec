Gem::Specification.new do |s|
  s.name        = "trimodel"
  s.version     = "0.0.2"
  s.date        = "2013-03-19"
  s.summary     = "A negotiator between 3 models"
  s.description = <<-eos
      A gem that enables transparent relationships 
      between 2 models associated through a third one.
    eos
  s.authors     = ["Angelos Kapsimanis"]
  s.email       = "angelos.kapsimanis@gmail.com"
  s.files       = ["trimodel.rb", 
                   "lib/trimodel/engine.rb",
                   "lib/generators/trimodel/new_generator.rb",
                   "lib/generators/trimodel/delete_generator.rb"]
  s.homepage    = "https://github.com/akxs14/trimodel"
end
