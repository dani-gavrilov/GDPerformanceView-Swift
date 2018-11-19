Pod::Spec.new do |s|
  s.name         = "GDPerformanceView-Swift"
  s.version      = "2.0.0"
  s.summary      = "Shows FPS, CPU usage and memory, device model, app and iOS versions above the status bar and report FPS, CPU and memory usage via delegate."
  s.homepage     = "https://github.com/dani-gavrilov/GDPerformanceView-Swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Gavrilov Daniil" => "daniilmbox@gmail.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/dani-gavrilov/GDPerformanceView-Swift.git", :tag => "2.0.0" }
  s.source_files = "PerformanceView-Swift/PerformanceMonitoring/*.swift"
  s.frameworks = "UIKit", "Foundation", "QuartzCore"  
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
end
