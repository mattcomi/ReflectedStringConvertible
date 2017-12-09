Pod::Spec.new do |s|
  s.name = "ReflectedStringConvertible"
  s.version = "1.2.0"
  s.summary = "A protocol that allows any class to be printed as if it were a struct or a JSON object."

  s.homepage = "https://github.com/mattcomi/ReflectedStringConvertible"  
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Matt Comi" => "mattcomi@gmail.com" }

  s.source = { :git => "https://github.com/mattcomi/ReflectedStringConvertible.git", :tag => "#{s.version}"} 
  s.source_files = "ReflectedStringConvertible/*.{swift}"
  s.requires_arc = true
  
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.10'
end