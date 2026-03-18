# frozen_string_literal: true

require_relative "lib/algebra_suite/version"

Gem::Specification.new do |spec|
  spec.name = "algebra_suite"
  spec.version = AlgebraSuite::VERSION
  spec.authors = ["ansavaa","Smiles-creator"]
  spec.email = ["почта Ани","bulavinova07s@gmail.com"]

  spec.summary = "Библиотека для упрощения булевой алгебры и операций с матрицами."
  spec.description = "Algebra Suite предоставляет инструменты для работы с булевыми выражениями и линейной алгеброй (матрицы)."
  spec.homepage = "https://github.com/Smiles-creator/algebra_suite"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
