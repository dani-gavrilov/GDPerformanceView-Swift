//
// Copyright © 2016 Gavrilov Daniil
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
    public weak var delegate: GDPerformanceMonitorDelegate?
    
    /**
     Change it to hide or show application version from monitoring view. Default is false.
     */
    public var appVersionHidden: Bool = false {
        didSet {
            self.configureVersionsString()
        }
    }
    
    /**
     Change it to hide or show device iOS version from monitoring view. Default is false.
     */
    public var deviceVersionHidden: Bool = false {
        didSet {
            self.configureVersionsString()
        }
    }
    
    // MARK: Private Properties
    
    private var displayLink: CADisplayLink?
    private var monitoringTextLabel: GDMarginLabel = GDMarginLabel()
    
    private var lastFPSUsageValue: CGFloat = 0.0
    private var displayLinkLastTimestamp: CFTimeInterval = 0.0
    private var lastUpdateTimestamp: CFTimeInterval = 0.0
    
    private var versionsString: String = ""
    
    // MARK: Init Methods & Superclass Overriders
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupWindowAndDefaultVariables()
        self.setupDisplayLink()
        self.setupTextLayers()
        self.subscribeToNotifications()
        self.configureVersionsString()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            let statusBarFrame = UIApplication.shared.statusBarFrame
            self.frame = CGRect(x: 0.0, y: 0.0, width: statusBarFrame.width, height: statusBarFrame.height)
            self.layoutTextLabel()
        }
    }
    
    // MARK: Public Methods
    
    /**
     Returns weak monitoring text label.
     */
    public func textLabel() -> UILabel? {
        weak var weakTextLabel = self.monitoringTextLabel
        return weakTextLabel
    }
    
    /**
     Pauses performance monitoring and hides monitoring view.
     */
    public func pauseMonitoring() {
        self.displayLink?.isPaused = true
        
        self.monitoringTextLabel.removeFromSuperview()
    }
    
    /**
     Resumes performance monitoring and shows monitoring view.
     */
    public func resumeMonitoring(shouldShowMonitoringView: Bool) {
        self.displayLink?.isPaused = false
        
        if shouldShowMonitoringView {
            self.addSubview(self.monitoringTextLabel)
        }
    }
    
    /**
     Hides monitoring view.
     */
    public func hideMonitoring() {
        self.monitoringTextLabel.removeFromSuperview()
    }
    
    /**
     Adds monitoring view above the status bar.
     */
    public func addMonitoringViewAboveStatusBar() {
        if !self.isHidden {
            return
        }
    
        self.isHidden = false
    }
    
    /**
     Stops and removes monitoring view. Call when you're done with performance monitoring.
     */
    public func stopMonitoring() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    // MARK: Private Methods
    // MARK: Default Setups
    
    private func setupWindowAndDefaultVariables() {
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = UIColor.clear
        
        self.rootViewController = rootViewController
        self.windowLevel = UIWindowLevelStatusBar + 1.0
        self.backgroundColor = UIColor.clear
        self.isHidden = true
    }
    
    private func setupDisplayLink() {
        self.displayLink = CADisplayLink.init(target: self, selector: #selector(displayLinkAction(displayLink:)))
        self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    private func setupTextLayers() {
        self.monitoringTextLabel.textAlignment = NSTextAlignment.center
        self.monitoringTextLabel.numberOfLines = 2
        self.monitoringTextLabel.backgroundColor = UIColor.black
        self.monitoringTextLabel.textColor = UIColor.white
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
        var fps: CGFloat = round(CGFloat(1.0) / CGFloat((displayLink.timestamp - self.displayLinkLastTimestamp)))
        if self.lastFPSUsageValue != 0.0 {
            fps = (self.lastFPSUsageValue + fps) / 2.0
        }
        
        self.lastFPSUsageValue = fps
        self.displayLinkLastTimestamp = displayLink.timestamp
        
        let timestampSinceLastUpdate = self.displayLinkLastTimestamp - self.lastUpdateTimestamp
        if timestampSinceLastUpdate >= 1.0 {
            self.lastFPSUsageValue = 0.0
            self.lastUpdateTimestamp = self.displayLinkLastTimestamp
            
            let cpu = self.cpuUsage()
            
            self.report(fpsUsage: fps, cpuUsage: cpu)
            self.updateMonitoringLabel(fpsUsage: fps, cpuUsage: cpu)
        }
    }
    
    private func cpuUsage() -> CGFloat {
        let basicInfoCount = MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size
        
        var kern: kern_return_t
        
        var threadList = UnsafeMutablePointer<thread_act_t>.allocate(capacity: 1)
        var threadCount = mach_msg_type_number_t(basicInfoCount)
        
        var threadInfo = thread_basic_info.init()
        var threadInfoCount: mach_msg_type_number_t
        
        var threadBasicInfo: thread_basic_info
        var threadStatistic: UInt32 = 0
        
        kern = withUnsafeMutablePointer(to: &threadList) {
            $0.withMemoryRebound(to: (thread_act_array_t?.self)!, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadCount)
            }
        }
        if kern != KERN_SUCCESS {
            return -1
        }
        
        if threadCount > 0 {
            threadStatistic += threadCount
        }
        
        var totalUsageOfCPU: CGFloat = 0
        
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
                totalUsageOfCPU = totalUsageOfCPU + CGFloat(threadBasicInfo.cpu_usage) / CGFloat(TH_USAGE_SCALE) * 100.0
            }
        }
        
        return totalUsageOfCPU
    }
    
    // MARK: Other Methods
    
    private func report(fpsUsage: CGFloat, cpuUsage: CGFloat) {
        self.delegate?.performanceMonitorDidReport(fpsValue: Float(fpsUsage), cpuValue: Float(cpuUsage))
    }
    
    private func updateMonitoringLabel(fpsUsage: CGFloat, cpuUsage: CGFloat) {
        let monitoringString = String(format: "FPS : %.1f; CPU : %.1f%%", fpsUsage, cpuUsage)
        
        self.monitoringTextLabel.text = monitoringString + self.versionsString
        self.layoutTextLabel()
    }
    
    private func layoutTextLabel() {
        let windowWidth = self.bounds.width
        let windowHeight = self.bounds.height
        let labelSize = self.monitoringTextLabel.sizeThatFits(CGSize(width: windowWidth, height: windowHeight))
        
        self.monitoringTextLabel.frame = CGRect(x: (windowWidth - labelSize.width) / 2.0, y: (windowHeight - labelSize.height) / 2.0, width: labelSize.width, height: labelSize.height)
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
                versionsString = "\napp v\(applicationVersion) (\(applicationBuild)); iOS v\(systemVersion)"
            } else if !self.appVersionHidden {
                versionsString = "\napp v\(applicationVersion) (\(applicationBuild))"
            } else if !self.deviceVersionHidden {
                versionsString = "\niOS v\(systemVersion)"
            }
        } else {
            self.versionsString = "";
        }
    }
    
}
