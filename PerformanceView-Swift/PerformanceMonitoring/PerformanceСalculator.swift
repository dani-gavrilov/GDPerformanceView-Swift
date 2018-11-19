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

import QuartzCore

// MARK: Class Definition

/// Performance calculator. Uses CADisplayLink to count FPS. Also counts CPU and memory usage.
internal class PerformanceCalculator {
    
    // MARK: Structs
    
    private struct Constants {
        static let accumulationTimeInSeconds = 1.0
    }
    
    // MARK: Public Properties
    
    internal var onReport: ((_ performanceReport: PerformanceReport) -> ())?
    
    // MARK: Private Properties
    
    private var displayLink: CADisplayLink!
    private let linkedFramesList = LinkedFramesList()
    private var startTimestamp: TimeInterval?
    private var accumulatedInformationIsEnough = false
    
    // MARK: Init Methods & Superclass Overriders
    
    required internal init() {
        self.configureDisplayLink()
    }
}

// MARK: Public Methods

internal extension PerformanceCalculator {
    /// Starts performance monitoring.
    func start() {
        self.startTimestamp = Date().timeIntervalSince1970
        self.displayLink?.isPaused = false
    }
    
    /// Pauses performance monitoring.
    func pause() {
        self.displayLink?.isPaused = true
        self.startTimestamp = nil
        self.accumulatedInformationIsEnough = false
    }
}

// MARK: Timer Actions

private extension PerformanceCalculator {
    @objc func displayLinkAction(displayLink: CADisplayLink) {
        self.linkedFramesList.append(frameWithTimestamp: displayLink.timestamp)
        self.takePerformanceEvidence()
    }
}

// MARK: Monitoring

private extension PerformanceCalculator {
    func takePerformanceEvidence() {
        if self.accumulatedInformationIsEnough {
            let cpuUsage = self.cpuUsage()
            let fps = self.linkedFramesList.count
            let memoryUsage = self.memoryUsage()
            self.report(cpuUsage: cpuUsage, fps: fps, memoryUsage: memoryUsage)
        } else if let start = self.startTimestamp, Date().timeIntervalSince1970 - start >= Constants.accumulationTimeInSeconds {
            self.accumulatedInformationIsEnough = true
        }
    }
    
    func cpuUsage() -> Double {
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
        
        var totalUsageOfCPU: Double = 0.0
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
                totalUsageOfCPU = totalUsageOfCPU + Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
            }
        }
        return totalUsageOfCPU
    }
    
    func memoryUsage() -> MemoryUsage {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        var used: UInt64 = 0
        if result == KERN_SUCCESS {
            used = UInt64(taskInfo.resident_size)
        }
        
        let total = ProcessInfo.processInfo.physicalMemory
        return (used, total)
    }
}

// MARK: Configurations

private extension PerformanceCalculator {
    func configureDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(PerformanceCalculator.displayLinkAction(displayLink:)))
        self.displayLink.isPaused = true
        self.displayLink?.add(to: .current, forMode: .common)
    }
}

// MARK: Support Methods

private extension PerformanceCalculator {
    func report(cpuUsage: Double, fps: Int, memoryUsage: MemoryUsage) {
        let performanceReport = (cpuUsage: cpuUsage, fps: fps, memoryUsage: memoryUsage)
        self.onReport?(performanceReport)
    }
}
