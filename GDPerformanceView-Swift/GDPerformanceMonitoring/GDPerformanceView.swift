//
// Copyright © 2017 Gavrilov Daniil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import QuartzCore

internal class GDPerformanceView: UIWindow {
    
    // MARK: Public Properties
    
    /**
     GDPerformanceMonitorDelegate delegate.
     */
    internal weak var performanceDelegate: GDPerformanceMonitorDelegate?
    
    /**
     Override this properties to return the desired status bar attributes.
     
     Default prefersStatusBarHidden is false, preferredStatusBarStyle is UIStatusBarStyle.default.
     */
    internal var prefersStatusBarHidden: Bool = false
    
    internal var preferredStatusBarStyle: UIStatusBarStyle = UIStatusBarStyle.default
    
    /**
     Change it to hide or show application version from monitoring view. Default is false.
     */
    internal var appVersionHidden: Bool = false {
        didSet {
            self.configureVersionsString()
        }
    }
    
    /**
     Change it to hide or show device iOS version from monitoring view. Default is false.
     */
    internal var deviceVersionHidden: Bool = false {
        didSet {
            self.configureVersionsString()
        }
    }
    
    // MARK: Private Properties
    
    private var displayLink: CADisplayLink?
    
    private var monitoringTextLabel: GDMarginLabel = GDMarginLabel()
    
    private var screenUpdatesCount: Int = 0
    
    private var screenUpdatesBeginTime: CFTimeInterval = 0.0
    
    private var averageScreenUpdatesTime: CFTimeInterval = 0.018
    
    private var versionsString: String = ""
    
    // MARK: Init Methods & Superclass Overriders
    
    internal init() {
        super.init(frame: GDPerformanceView.windowFrame())
        
        self.setupWindowAndDefaultVariables()
        self.setupDisplayLink()
        self.setupTextLayers()
        self.subscribeToNotifications()
        self.configureVersionsString()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutWindow()
    }
    
    override func becomeKey() {
        self.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.isHidden = false
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notifications & Observers
    
    @objc private func applicationWillChangeStatusBarFrame(notification: NSNotification) {
        DispatchQueue.main.async {
            self.layoutWindow()
        }
    }
    
    // MARK: Public Methods
    
    /**
     Returns weak monitoring text label.
     */
    internal func textLabel() -> UILabel? {
        weak var weakTextLabel = self.monitoringTextLabel
        return weakTextLabel
    }
    
    /**
     Pauses performance monitoring and hides monitoring view.
     */
    internal func pauseMonitoring() {
        self.displayLink?.isPaused = true
        
        self.monitoringTextLabel.removeFromSuperview()
    }
    
    /**
     Resumes performance monitoring and shows monitoring view.
     */
    internal func resumeMonitoring(shouldShowMonitoringView: Bool) {
        self.displayLink?.isPaused = false
        
        if shouldShowMonitoringView {
            self.addSubview(self.monitoringTextLabel)
        }
    }
    
    /**
     Hides monitoring view.
     */
    internal func hideMonitoring() {
        self.monitoringTextLabel.removeFromSuperview()
    }
    
    /**
     Adds monitoring view above the status bar.
     */
    internal func addMonitoringViewAboveStatusBar() {
        if !self.isHidden {
            return
        }
        
        self.isHidden = false
    }
    
    /**
     Configures root view controller with prefersStatusBarHidden and preferredStatusBarStyle.
     */
    internal func configureRootViewController() {
        let rootViewController = GDWindowViewController()
        rootViewController.configureStatusBarAppearance(prefersStatusBarHidden: self.prefersStatusBarHidden, preferredStatusBarStyle: self.preferredStatusBarStyle)
        
        self.rootViewController = rootViewController
    }
    
    /**
     Stops and removes monitoring view. Call when you're done with performance monitoring.
     */
    internal func stopMonitoring() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    // MARK: Private Methods
    // MARK: Default Setups
    
    private func setupWindowAndDefaultVariables() {
        let rootViewController = GDWindowViewController()
        
        self.rootViewController = rootViewController
        self.windowLevel = UIWindowLevelStatusBar + 1.0
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.isHidden = true
    }
    
    private func setupDisplayLink() {
        self.displayLink = CADisplayLink.init(target: self, selector: #selector(displayLinkAction(displayLink:)))
        self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    private func setupTextLayers() {
        self.monitoringTextLabel.textAlignment = NSTextAlignment.center
        self.monitoringTextLabel.numberOfLines = 2
        self.monitoringTextLabel.backgroundColor = .black
        self.monitoringTextLabel.textColor = .white
        self.monitoringTextLabel.clipsToBounds = true
        self.monitoringTextLabel.font = UIFont.systemFont(ofSize: 8.0)
        self.monitoringTextLabel.layer.borderWidth = 1.0
        self.monitoringTextLabel.layer.borderColor = UIColor.black.cgColor
        self.monitoringTextLabel.layer.cornerRadius = 5.0
        
        self.addSubview(self.monitoringTextLabel)
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GDPerformanceView.applicationWillChangeStatusBarFrame(notification:)), name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame, object: nil)
    }
    
    // MARK: Monitoring
    
    @objc private func displayLinkAction(displayLink: CADisplayLink) {
        if self.screenUpdatesBeginTime == 0.0 {
            self.screenUpdatesBeginTime = displayLink.timestamp
        } else {
            self.screenUpdatesCount += 1
            
            let screenUpdatesTime = displayLink.timestamp - self.screenUpdatesBeginTime
            
            if screenUpdatesTime >= 1.0 {
                let updatesOverSecond = screenUpdatesTime - 1.0
                let framesOverSecond = Int(updatesOverSecond / self.averageScreenUpdatesTime)
                
                self.screenUpdatesCount -= framesOverSecond
                if self.screenUpdatesCount < 0 {
                    self.screenUpdatesCount = 0
                }
                
                self.takeReadings()
            }
        }
    }
    
    private func takeReadings() {
        let fps = self.screenUpdatesCount
        let cpu = self.cpuUsage()
        
        self.screenUpdatesCount = 0
        self.screenUpdatesBeginTime = 0.0
        
        self.report(fpsUsage: fps, cpuUsage: cpu)
        self.updateMonitoringLabel(fpsUsage: fps, cpuUsage: cpu)
    }
    
    private func cpuUsage() -> Float {
        let basicInfoCount = MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size
        
        var kern: kern_return_t
        
        var threadList = UnsafeMutablePointer<thread_act_t>.allocate(capacity: 1)
        var threadCount = mach_msg_type_number_t(basicInfoCount)
        
        var threadInfo = thread_basic_info.init()
        var threadInfoCount: mach_msg_type_number_t
        
        var threadBasicInfo: thread_basic_info
        var threadStatistic: UInt32 = 0
        
        kern = withUnsafeMutablePointer(to: &threadList) {
            #if swift(>=3.1)
                return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                    task_threads(mach_task_self_, $0, &threadCount)
                }
            #else
                return $0.withMemoryRebound(to: (thread_act_array_t?.self)!, capacity: 1) {
                    task_threads(mach_task_self_, $0, &threadCount)
                }
            #endif
        }
        if kern != KERN_SUCCESS {
            return -1
        }
        
        if threadCount > 0 {
            threadStatistic += threadCount
        }
        
        var totalUsageOfCPU: Float = 0.0
        
        for i in 0..<threadCount {
            threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            kern = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threadList[Int(i)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }
            if kern != KERN_SUCCESS {
                return -1
            }
            
            threadBasicInfo = threadInfo as thread_basic_info
            
            if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                totalUsageOfCPU = totalUsageOfCPU + Float(threadBasicInfo.cpu_usage) / Float(TH_USAGE_SCALE) * 100.0
            }
        }
        
        return totalUsageOfCPU
    }
    
    // MARK: Other Methods
    
    class func windowFrame() -> CGRect {
        var frame = CGRect.zero
        if let window = UIApplication.shared.delegate?.window {
            frame = CGRect(x: 0.0, y: 0.0, width: window!.bounds.width, height: 20.0)
        }
        return frame
    }
    
    private func report(fpsUsage: Int, cpuUsage: Float) {
        self.performanceDelegate?.performanceMonitorDidReport(fpsValue: fpsUsage, cpuValue: cpuUsage)
    }
    
    private func updateMonitoringLabel(fpsUsage: Int, cpuUsage: Float) {
        let monitoringString = String(format: "FPS : %d CPU : %.1f%%", fpsUsage, cpuUsage)
        
        self.monitoringTextLabel.text = monitoringString + self.versionsString
        self.layoutTextLabel()
    }
    
    private func layoutTextLabel() {
        let windowWidth = self.bounds.width
        let windowHeight = self.bounds.height
        let labelSize = self.monitoringTextLabel.sizeThatFits(CGSize(width: windowWidth, height: windowHeight))
        
        self.monitoringTextLabel.frame = CGRect(x: (windowWidth - labelSize.width) / 2.0, y: (windowHeight - labelSize.height) / 2.0, width: labelSize.width, height: labelSize.height)
    }
    
    private func layoutWindow() {
        self.frame = GDPerformanceView.windowFrame()
        self.layoutTextLabel()
    }
    
    private func configureVersionsString() {
        if !self.appVersionHidden || !self.deviceVersionHidden {
            var applicationVersion = "<null>"
            var applicationBuild = "<null>"
            if let infoDictionary = Bundle.main.infoDictionary {
                if let versionNumber = infoDictionary["CFBundleShortVersionString"] {
                    applicationVersion = versionNumber as! String
                }
                if let buildNumber = infoDictionary["CFBundleVersion"] {
                    applicationBuild = buildNumber as! String
                }
            }
            
            let systemVersion = UIDevice.current.systemVersion
            
            if !self.appVersionHidden && !self.deviceVersionHidden {
                versionsString = "\napp v\(applicationVersion) (\(applicationBuild)) iOS v\(systemVersion)"
            } else if !self.appVersionHidden {
                versionsString = "\napp v\(applicationVersion) (\(applicationBuild))"
            } else if !self.deviceVersionHidden {
                versionsString = "\niOS v\(systemVersion)"
            }
        } else {
            self.versionsString = ""
        }
    }
    
}
