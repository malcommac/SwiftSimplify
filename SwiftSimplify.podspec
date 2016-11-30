Pod::Spec.new do |spec|
  spec.name             = 'SwiftSimplify'
  spec.version          = '0.2.0'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/malcommac/SwiftSimplify'
  spec.authors          = { "daniele margutti" => "me@danielemargutti.com" }
  spec.summary          = 'Tiny high-performance Swift polyline simplification library'
  spec.source           = { :git => "https://github.com/malcommac/SwiftSimplify.git", :tag => '0.2.0' }
  spec.source_files     = 'Pod/Classes/**/*'
  spec.framework        = 'CoreLocation'
  spec.requires_arc     = true
  spec.ios.deployment_target = '8.0'
end
