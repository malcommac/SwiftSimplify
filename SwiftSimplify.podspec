#
# Be sure to run `pod lib lint SwiftSimplify.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SwiftSimplify"
  s.version          = "0.1.0"
  s.summary          = "Tiny high-performance Swift polyline simplification library"
  s.description      = <<-DESC
                       	SwiftSimplify is a tiny high-performance Swift polyline simplification ported from Simplify.js.
			It uses a combination of Douglas-Peucker and Radial Distance algorithms. It uses generics, works with Swift 1.2.
			Polyline simplification dramatically reduces the number of points in a polyline while retaining its shape, giving 
			a huge performance boost when processing it and also reducing visual noise. For example, it's essential when 	
			rendering a 70k-points line chart or a map route in the browser using Canvas or SVG.
                       DESC
  s.homepage         = "https://github.com/malcommac/SwiftSimplify"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "daniele margutti" => "me@danielemargutti.com" }
  s.source           = { :git => "https://github.com/malcommac/SwiftSimplify.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/danielemargutti'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SwiftSimplify' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit', 'CoreLocation'
end
