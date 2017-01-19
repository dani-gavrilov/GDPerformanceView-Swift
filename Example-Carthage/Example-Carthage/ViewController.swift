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

import GDPerformanceView

class ViewController: UITableViewController, GDPerformanceMonitorDelegate {
    
    // MARK: Private Properties
    
    private var performanceReports: Array<String> = []
    
    private let cellReuseIdentifier: String = "performanceReportCell"
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GDPerformanceMonitor.sharedInstance.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private Methods
    
    func configurePerformanceReport(cell: UITableViewCell, at indexPath: IndexPath) {
        let index = indexPath.row
        if (index >= self.performanceReports.count) {
            return
        }
        
        let reportString = self.performanceReports[index]
        cell.textLabel?.text = reportString
    }
    
    // MARK: Protocols Implementations
    // MARK: UITableViewDelegate & UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.performanceReports.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: self.cellReuseIdentifier)
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.configurePerformanceReport(cell: cell, at: indexPath)
    }
    
    // MARK: GDPerformanceMonitorDelegate
    
    func performanceMonitorDidReport(fpsValue: Int, cpuValue: Float) {
        let reportString = String(format: "FPS : %d; CPU : %.1f%%", fpsValue, cpuValue)
        
        self.tableView.beginUpdates()
        
        let insertIndexPath = IndexPath.init(row: 0, section: 0)
        self.tableView.insertRows(at: [insertIndexPath], with: .right)
        
        self.performanceReports.insert(reportString, at: 0)
        
        if (self.performanceReports.count > 10) {
            self.performanceReports.removeLast()
            
            let deleteIndexPath = IndexPath.init(row: 9, section: 0)
            self.tableView.deleteRows(at: [deleteIndexPath], with: .left)
        }
        
        self.tableView.endUpdates()
    }
}
