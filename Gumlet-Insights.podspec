Pod::Spec.new do |spec|

 
  spec.name         = "Gumlet-Insights"
  spec.version      = "1.0.0"
  spec.summary      = "Gumlet Insights SDK integration with AVPlayer for native iOS applications."

  
  spec.description  = <<-DESC
    Gumlet Insights SDK integration with AVPlayer for native iOS applications. This analytics enables you to get useful data about video usage in your apps.
                   DESC

  spec.homepage     = "http://gumlet.com"
  spec.license         = "MIT"
  spec.author       = { "Gumlet" => "support@gumlet.com" }
  spec.ios.deployment_target = "13.0"
  spec.swift_version = "4.2"
  spec.source = { :git => "https://github.com/gumlet/gumlet-insights-avplayer.git", :tag => "#{spec.version}" }
  spec.source_files  =  "GumletInsightsAVPlayer/**/*.{h,m,swift}"
  spec.requires_arc = true

 
end

