Gem::Specification.new do |s|
  s.name = "myy-color"
  s.version = "0.0.1"
  s.authors = ["Myy"]
  s.email = ["color@miouyouyou.fr"]
  s.homepage = "https://github.com/Miouyouyou/myy-color"
  s.summary = "a basic RGBA decoder/encoder"
  s.description = <<-desc.strip.gsub(/\s+/, ' ')
    MyyColor provides basic color encoding and decoding facilities,
    which are mainly used for converting BMP to OpenGL raw texture
    format.
  desc
  s.rubyforge_project = "myy-color"
  s.files = Dir['LICENSE', 'README', 'myy-color.gemspec', 'lib/**', 'bin/myy_bmp2raw']
  s.executables = %w(myy_bmp2raw)
  s.license = 'MIT'
end
