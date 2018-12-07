
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sitemap_seo_checker"
  spec.version       = '0.1'
  spec.authors       = ["Thomas R. Koll"]
  spec.email         = ["tomk32@gmail.com"]

  spec.summary       = %q{Parse sitemap and display SEO relevant information}
  spec.description   = %q{SEO relevant information is hard to track across a larger website, this tool retrieves all this information and uses your sitemap.xml to get to those pages in the first place}
  spec.homepage      = "https://tomk32.de/sitemap-seo-checker"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
end
