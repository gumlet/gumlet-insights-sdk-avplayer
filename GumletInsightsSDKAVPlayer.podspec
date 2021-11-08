Pod::Spec.new do |spec|

 
  spec.name         = "GumletInsightsSDKAVPlayer"
  spec.version      = "1.0.0"
  spec.summary      = "Gumlet Insight SDK AVPlayer integration with AVPlayer for native iOS applications."

  
  spec.description  = <<-DESC
    Gumlet Insight SDK AVPlayer integration with AVPlayer for native iOS applications. This analytics enables you to get useful data about video usage in your apps.
                   DESC

  spec.homepage     = "http://gumlet.com"
  spec.license         = "MIT"
  spec.author       = { "Gumlet" => "support@gumlet.com" }
  spec.source = { :git => "https://github.com/gumlet/gumlet-insights-sdk-avplayer", :tag => "#{spec.version}" }
  spec.source_files  =  "GumletInsightsSDKAVPlayer/**/*.{h,m,swift}"
  spec.swift_version = "4.2"
  spec.requires_arc = true
  spec.ios.deployment_target = "13.0"
  vendored_frameworks = "GumletInsightsSDKAVPlayer.xcframework"



end
