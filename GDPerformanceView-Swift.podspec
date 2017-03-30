Pod::Spec.new do |s|
  s.name         = "GDPerformanceView-Swift"
  s.version      = "1.2.0"
  s.summary      = "Shows FPS, CPU usage, app and iOS versions above the status bar and report FPS and CPU usage via delegate."
  s.homepage     = "https://github.com/dani-gavrilov/GDPerformanceView-Swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Gavrilov Daniil" => "daniilmbox@gmail.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/dani-gavrilov/GDPerformanceView-Swift.git", :tag => "1.2.0" }
  s.source_files = "GDPerformanceView-Swift/GDPerformanceMonitoring/*.swift"
  s.frameworks = "UIKit", "Foundation", "QuartzCore"  
  s.requires_arc = true
end
