Pod::Spec.new do |spec|

  spec.name         = "ExaironMessenger.Framework.IOSSDK"
  spec.version      = "1.0.1"
  spec.summary      = "This is the ExaironMessenger.Framework.IOSSDK"
  spec.description  = "This framework creade by Exairon. ExaironMessenger.Framework.IOSSDK"

  spec.homepage     = "http://exairon.com"
  spec.license      = "MIT"

  spec.author       = { "Enes Toprak" => "etoprak174@gmail.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/Exairon/ExaironMessenger.Framework.IOSSDK.git", :tag => spec.version.to_s }
  
  spec.swift_versions = "5.0"
  spec.source_files  = "ExaironMessenger.Framework.IOSSDK/**/*.{swift}"
end
