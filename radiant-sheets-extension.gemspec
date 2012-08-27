# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-sheets-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-sheets-extension"
  s.version     = RadiantSheetsExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Radiant CMS Dev Team"]
  s.email       = ["radiant@radiantcms.org"]
  s.homepage    = "http://radiantcms.org/"
  s.summary     = %q{Sheets for Radiant CMS}
  s.description = %q{Manage CSS and Javascript content in Radiant CMS as Sheets, a subset of Pages.}

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]
  
  s.add_dependency 'sass', '~>3.2.1'
  s.add_dependency 'coffee-script', '~>2.2.0'
end