Pod::Spec.new do |s|
  s.name = "ReflectedStringConvertible"
  s.version = "1.0.0"
  s.summary = "A protocol that extends `CustomStringConvertible` to add a detailed textual representation to any class."

  s.homepage = "https://github.com/mattcomi/ReflectedStringConvertible"  
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Matt Comi" => "mattcomi@gmail.com" }

  s.source = { :git => "https://github.com/mattcomi/ReflectedStringConvertible.git", :tag => "#{s.version}"} 
  s.source_files = "ReflectedStringConvertible/*.{swift}"
  s.requires_arc = true
  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
end