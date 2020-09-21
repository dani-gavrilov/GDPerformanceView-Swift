Pod::Spec.new do |s|
  s.name         = "GDPerformanceView-Swift"
  s.version      = "2.1.0"
  s.summary      = "Shows FPS, CPU and memory usage, device model, app and iOS versions above the status bar and report FPS, CPU and memory usage via delegate."
  s.homepage     = "https://github.com/dani-gavrilov/GDPerformanceView-Swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Gavrilov Daniil" => "daniilmbox@gmail.com" }
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/dani-gavrilov/GDPerformanceView-Swift.git", :tag => s.version.to_s }
  s.source_files = "GDPerformanceView-Swift/GDPerformanceMonitoring/*.swift"
  s.frameworks = "UIKit", "Foundation", "QuartzCore"  
  s.requires_arc = true
  s.swift_versions = ['4.2', '5.0']
end
