Pod::Spec.new do |spec|
  spec.name          = 'Aesthete'
  spec.module_name   = 'Aesthete'
  spec.version       = '0.0.3'
  spec.license       = 'MIT'
  spec.authors       = { 'incetro' => 'incetro@ya.ru', 'Lezya Alexander' => '1ezya007@gmail.com' }
  spec.homepage      = "https://github.com/Incetro/aesthete.git"
  spec.summary       = 'Network file manager service'
  spec.platforms     = { :ios => "12.0", :watchos => "7.0" }
  spec.swift_version = '4.0'                            
  spec.source        = { git: "https://github.com/Incetro/aesthete.git", tag: "#{spec.version}" }
  spec.source_files  = "Sources/Aesthete/**/*.{h,swift}"
  spec.dependency "incetro-observer-list"
end