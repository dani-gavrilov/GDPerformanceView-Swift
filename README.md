#GDPerformanceView-Swift
Shows FPS, CPU usage, app and iOS versions above the status bar and report FPS and CPU usage via delegate.

![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view.PNG?raw=true "Example PNG")
![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view_2.PNG?raw=true "Example PNG")
![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view_3.PNG?raw=true "Example PNG")
![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view_4.PNG?raw=true "Example PNG")

## Installation
Simply add GDPerformanceMonitoring folder with files to your project, or use CocoaPods.

### Carthage
```ruby
github "dani-gavrilov/GDPerformanceView-Swift" ~> 1.0.4
```

### Podfile
```ruby
platform :ios, '8.0'
use_frameworks!

target 'project_name' do
	pod 'GDPerformanceView-Swift', '~> 1.0.4'
end
```

## Usage

Simply start monitoring. Performance view will be added above the status bar automatically.
Also, you can configure appearance as you like or just hide the monitoring view and use its delegate.

### Start monitoring

Call to start or resume monitoring and show monitoring view.

```swift
GDPerformanceMonitor.sharedInstance.startMonitoring()
```

```swift
self.performanceView = GDPerformanceMonitor.init()
self.performanceView?.startMonitoring()
```

### Stop monitoring

Call when you're done with performance monitoring.

```swift
self.performanceView?.stopMonitoring()
```

Call to hide and pause monitoring.

```swift
self.performanceView?.pauseMonitoring()
```

### Configuration

Call to change appearance.

```swift
self.performanceView?.configure(configuration: { textLabel in
	textLabel?.backgroundColor = .black
	textLabel?.textColor = .white
	textLabel?.layer.borderColor = UIColor.black.cgColor
})
```

Call to change output information.

```swift
self.performanceView?.appVersionHidden = true

self.performanceView?.deviceVersionHidden = true
```

Call to hide monitoring view.

```swift
self.performanceView?.hideMonitoring()
```

### Start monitoring and configure

```swift
self.performanceView?.startMonitoring(configuration: { textLabel in
	textLabel?.backgroundColor = .black
	textLabel?.textColor = .white
	textLabel?.layer.borderColor = UIColor.black.cgColor
})
```

### Delegate

Set the delegate and implement its method.

```swift
self.performanceView?.delegate = self
```

```swift
func performanceMonitorDidReport(fpsValue: Float, cpuValue: Float) {
	print(fpsValue, cpuValue)
}
```

## Requirements
- iOS 8.0+

## License
GDPerformanceView is available under the MIT license. See the LICENSE file for more info.
