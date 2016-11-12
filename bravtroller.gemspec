$:.push File.expand_path('../lib', __FILE__)

require "bravtroller/version"

Gem::Specification.new do |gem|
  gem.name    = 'bravtroller'
  gem.version = Bravtroller::VERSION

  gem.summary = "Controller for the Bravia KDL-50W700B"
  gem.description = "Controller for the Bravia KDL-50W700B supporting WOL and IRCC (Remote Control emulation). Likely supports other Sony devivces that expose the same services"

  gem.authors  = ['Christopher Mullins']
  gem.email    = 'chris@sidoh.org'
  gem.homepage = 'http://github.com/sidoh/bravtroller'
  gem.license = 'MIT'

  gem.add_dependency('easy_upnp', '~> 1.1')

  gem.add_development_dependency('rake', '~> 10.4')

  ignores  = File.readlines(".gitignore").grep(/\S+/).map(&:chomp)
  dotfiles = %w[.gitignore]

  all_files_without_ignores = Dir["**/*"].reject { |f|
    File.directory?(f) || ignores.any? { |i| File.fnmatch(i, f) }
  }

  gem.files = (all_files_without_ignores + dotfiles).sort
  gem.bindir        = "bin"
  gem.executables   = ["bravtroller"]

  gem.require_path = "lib" 
end
