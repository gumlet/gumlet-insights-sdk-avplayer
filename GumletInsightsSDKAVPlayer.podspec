
Pod::Spec.new do |spec|

 

  spec.name                 = "GumletInsightsSDKAVPlayer"
<<<<<<< HEAD
  spec.version              = "1.0.4"
=======
  spec.version              = "1.0.5"
>>>>>>> code revamp
  spec.summary              = "GumletInsightSDK  integration with AVPlayer for native iOS applications."

  spec.description          = 'GumletInsightSDK integration with AVPlayer for native iOS applications. This analytics enables you to get useful data about video usage in your apps.'

  spec.homepage             = "https://github.com/gumlet/gumlet-insights-sdk-avplayer"
  spec.social_media_url     = 'https://twitter.com/gumlethq'
 
  spec.license              = "MIT"
 
  spec.author               = { "Gumlet" => "support@gumlet.com" }
  
  spec.ios.deployment_target= "13.0"
  spec.swift_version        = "4.2"
 
  spec.source               = { :git => "https://github.com/gumlet/gumlet-insights-sdk-avplayer.git",
                                :tag => "#{spec.version}" }

  spec.source_files         = "GumletInsightsSDKAVPlayer/**/*.{h,m,swift}"
  spec.requires_arc         = true

end
