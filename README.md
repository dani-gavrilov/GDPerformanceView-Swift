#GDPerformanceView-Swift
Shows FPS, CPU usage, app and iOS versions above the status bar and report FPS and CPU usage via delegate.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage) 
[![Pod Version](https://img.shields.io/badge/Pod-1.2.0-6193DF.svg)](https://cocoapods.org/)
![Swift Version](https://img.shields.io/badge/xCode-8.2+-blue.svg) 
![Swift Version](https://img.shields.io/badge/iOS-8.0+-blue.svg) 
![Swift Version](https://img.shields.io/badge/Swift-3.0+-orange.svg)
![Plaform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)
![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg) 

![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view.PNG?raw=true "Example PNG")
![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view_2.PNG?raw=true "Example PNG")
![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view_3.PNG?raw=true "Example PNG")
![Alt text](https://github.com/dani-gavrilov/GDPerformanceView/blob/master/performance_view_4.PNG?raw=true "Example PNG")

## Installation
Simply add GDPerformanceMonitoring folder with files to your project, or use CocoaPods.

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/GDPerformanceView.framework` to an iOS project.

```ruby
github "dani-gavrilov/GDPerformanceView-Swift" ~> 1.1.2
```
Don't forget to import GDPerformanceView by adding: 

```swift
import GDPerformanceView
```

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `GDPerformanceView` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'project_name' do
	pod 'GDPerformanceView-Swift', '~> 1.1.2'
end
```
Don't forget to import GDPerformanceView by adding: 

```swift
import GDPerformanceView_Swift
```

## Usage example

Simply start monitoring. Performance view will be added above the status bar automatically.
Also, you can configure appearance as you like or just hide the monitoring view and use its delegate.

You can find example projects [here](https://github.com/dani-gavrilov/GDPerformanceViewExamples)

#### Start monitoring

Call to start or resume monitoring and show monitoring view.

```swift
GDPerformanceMonitor.sharedInstance.startMonitoring()
```

```swift
self.performanceView = GDPerformanceMonitor.init()
self.performanceView?.startMonitoring()
```

#### Stop monitoring

Call when you're done with performance monitoring.

```swift
self.performanceView?.stopMonitoring()
```

Call to hide and pause monitoring.

```swift
self.performanceView?.pauseMonitoring()
```

#### Configuration

Call to change appearance.

```swift
self.performanceView?.configure(configuration: { (textLabel) in
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

Call to change status bar appearance.

```swift
self.performanceView?.configureStatusBarAppearance(prefersStatusBarHidden: false, preferredStatusBarStyle: .lightContent)
```

#### Start monitoring and configure

```swift
self.performanceView?.startMonitoring(configuration: { (textLabel) in
	textLabel?.backgroundColor = .black
	textLabel?.textColor = .white
	textLabel?.layer.borderColor = UIColor.black.cgColor
})
```

#### Delegate

Set the delegate and implement its method.

```swift
self.performanceView?.delegate = self
```

```swift
func performanceMonitorDidReport(fpsValue: Int, cpuValue: Float) {
	print(fpsValue, cpuValue)
}
```

## Requirements
- iOS 8.0+
- xCode 8.2+

## License
GDPerformanceView is available under the MIT license. See the LICENSE file for more info.
