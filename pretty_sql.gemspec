# frozen_string_literal: true

require_relative "lib/pretty_sql/version"
require_relative "pretty_sql/railtie" if defined?(Rails)

Gem::Specification.new do |spec|
  spec.name = "pretty_sql"
  spec.version = PrettySql::VERSION
  spec.authors = ["Sam ODonnell"]
  spec.email = ["samuel.odonnell23@gmail.com"]

  spec.summary = "Pretty SQL"
  spec.description = "Pretty SQL"
  spec.homepage = "https://github.com/samuel-odonnell/pretty_sql"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/samuel-odonnell/pretty_sql"
  spec.metadata["changelog_uri"] = "https://github.com/samuel-odonnell/pretty_sql/CHANGELOG.md"

  spec.add_dependency "activesupport", ">= 7.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
