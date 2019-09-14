Pod::Spec.new do |s|
  s.name         = "SwiftSimplify"
  s.version      = "1.1.0"
  s.summary      = "High-performance Swift polyline simplification library ported from Javascript's Simplify.js"
  s.description  = <<-DESC
    SwiftSimplify is a tiny high-performance Swift polyline simplification library ported from Javascript's Simplify.js. Original work come from Leaflet, a JS interactive maps library by Vladimir Agafonkin. It uses a combination of Douglas-Peucker and Radial Distance algorithms. Works both on browser and server platforms.
  DESC
  s.homepage     = "https://github.com/malcommac/SwiftSimplify"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "hello@danielemargutti.com" }
  s.social_media_url   = "https://twitter.com/danielemargutti"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/malcommac/SwiftSimplify.git", :tag => s.version.to_s }
  s.source_files = 'Sources/**/*.swift'
  s.frameworks  = "Foundation", "UIKit", "CoreLocation"
  s.swift_version = "5.0"
end
