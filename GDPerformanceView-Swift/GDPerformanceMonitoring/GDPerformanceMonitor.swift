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

public class GDPerformanceMonitor: NSObject {
    
    // MARK: Public Properties
    
    /**
     GDPerformanceMonitorDelegate delegate.
     */
    public weak var delegate: GDPerformanceMonitorDelegate? {
        didSet {
            self.performanceView?.performanceDelegate = self.delegate
        }
    }
    
    /**
     Change it to hide or show application version from monitoring view. Default is false.
     */
    public var appVersionHidden: Bool = false {
        didSet {
            self.performanceView?.appVersionHidden = self.appVersionHidden
        }
    }
    
    /**
     Change it to hide or show device iOS version from monitoring view. Default is false.
     */
    public var deviceVersionHidden: Bool = false {
        didSet {
            self.performanceView?.deviceVersionHidden = self.deviceVersionHidden
        }
    }
    
    /**
     Instance of GDPerformanceMonitor as singleton.
     */
    public static let sharedInstance: GDPerformanceMonitor = GDPerformanceMonitor.init()
    
    // MARK: Private Properties
    
    private var performanceView: GDPerformanceView?
    
    private var performanceViewPaused: Bool = false
    
    private var performanceViewHidden: Bool = false
    
    private var performanceViewStopped: Bool = false
    
    private var prefersStatusBarHidden: Bool = false
    
    private var preferredStatusBarStyle: UIStatusBarStyle = UIStatusBarStyle.default
    
    // MARK: Init Methods & Superclass Overriders
    
    /**
     Creates and returns instance of GDPerformanceMonitor.
     */
    public override init() {
        super.init()
        
        self.subscribeToNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notifications & Observers
    
    @objc private func applicationDidBecomeActive(notification: NSNotification) {
        if self.performanceViewPaused {
            return
        }
        
        self.startOrResumeMonitoring()
    }
    
    @objc private func applicationWillResignActive(notification: NSNotification) {
        self.performanceView?.pauseMonitoring()
    }
    
    // MARK: Public Methods
    
    /**
     Overrides prefersStatusBarHidden and preferredStatusBarStyle properties to return the desired status bar attributes.
     
     Default prefersStatusBarHidden is false, preferredStatusBarStyle is UIStatusBarStyle.default.
     */
    public func configureStatusBarAppearance(prefersStatusBarHidden: Bool, preferredStatusBarStyle: UIStatusBarStyle) {
        self.prefersStatusBarHidden = prefersStatusBarHidden
        self.preferredStatusBarStyle = preferredStatusBarStyle
        
        self.checkAndApplyStatusBarAppearance(prefersStatusBarHidden: prefersStatusBarHidden, preferredStatusBarStyle: preferredStatusBarStyle)
    }
    
    /**
     Starts or resumes performance monitoring, initialize monitoring view if not initialized and shows monitoring view. Use configuration block to change appearance as you like.
     */
    public func startMonitoring(configuration: (UILabel?) -> Void) {
        self.performanceViewPaused = false
        self.performanceViewHidden = false
        self.performanceViewStopped = false
        
        self.startOrResumeMonitoring()
        
        let textLabel = self.performanceView?.textLabel()
        configuration(textLabel)
    }
    
    /**
     Starts or resumes performance monitoring, initialize monitoring view if not initialized and shows monitoring view.
     */
    public func startMonitoring() {
        self.performanceViewPaused = false
        self.performanceViewHidden = false
        self.performanceViewStopped = false
        
        self.startOrResumeMonitoring()
    }
    
    /**
     Pauses performance monitoring and hides monitoring view.
     */
    public func pauseMonitoring() {
        self.performanceViewPaused = true
        
        self.performanceView?.pauseMonitoring()
    }
    
    /**
     Hides monitoring view.
     */
    public func hideMonitoring() {
        self.performanceViewHidden = true
        
        self.performanceView?.hideMonitoring()
    }
    
    /**
     Stops and removes monitoring view. Call when you're done with performance monitoring.
     */
    public func stopMonitoring() {
        self.performanceViewStopped = true
        
        self.performanceView?.stopMonitoring()
        self.performanceView = nil
    }
    
    /**
     Use configuration block to change appearance as you like.
     */
    public func configure(configuration: (UILabel?) -> Void) {
        let textLabel = self.performanceView?.textLabel()
        configuration(textLabel)
    }
    
    // MARK: Private Methods
    // MARK: Default Setups
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GDPerformanceMonitor.applicationDidBecomeActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GDPerformanceMonitor.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    // MARK: Monitoring
    
    private func startOrResumeMonitoring() {
        if self.performanceView == nil {
            self.setupPerformanceView()
        } else {
            self.performanceView?.resumeMonitoring(shouldShowMonitoringView: !self.performanceViewHidden)
        }
        
        if UIApplication.shared.applicationState == UIApplicationState.active {
            self.performanceView?.addMonitoringViewAboveStatusBar()
        }
    }
    
    private func setupPerformanceView() {
        if self.performanceViewStopped {
            return
        }
        
        self.performanceView = GDPerformanceView.init()
        self.performanceView?.appVersionHidden = self.appVersionHidden
        self.performanceView?.deviceVersionHidden = self.deviceVersionHidden
        self.performanceView?.performanceDelegate = self.delegate
        self.checkAndApplyStatusBarAppearance(prefersStatusBarHidden: self.prefersStatusBarHidden, preferredStatusBarStyle: self.preferredStatusBarStyle)
        
        if self.performanceViewPaused {
            self.performanceView?.pauseMonitoring()
        }
        if self.performanceViewHidden {
            self.performanceView?.hideMonitoring()
        }
    }
    
    // MARK: Other Methods
    
    private func checkAndApplyStatusBarAppearance(prefersStatusBarHidden: Bool, preferredStatusBarStyle: UIStatusBarStyle) {
        if self.performanceView?.prefersStatusBarHidden != prefersStatusBarHidden || self.performanceView?.preferredStatusBarStyle != preferredStatusBarStyle {
            self.performanceView?.prefersStatusBarHidden = prefersStatusBarHidden
            self.performanceView?.preferredStatusBarStyle = preferredStatusBarStyle
            
            self.performanceView?.configureRootViewController()
        }
    }
    
}
