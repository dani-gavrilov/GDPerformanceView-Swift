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

internal class GDWindowViewController: UIViewController {
    
    // MARK: Private Properties
    
    private var selectedStatusBarHidden: Bool = false
    
    private var selectedStatusBarStyle: UIStatusBarStyle = UIStatusBarStyle.default
    
    // MARK: Properties Overriders
    
    override var prefersStatusBarHidden: Bool {
        get {
            return self.selectedStatusBarHidden
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return self.selectedStatusBarStyle
        }
    }
    
    // MARK: Init Methods & Superclass Overriders
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Public Methods
    
    internal func configureStatusBarAppearance(prefersStatusBarHidden: Bool, preferredStatusBarStyle: UIStatusBarStyle) {
        self.selectedStatusBarHidden = prefersStatusBarHidden
        self.selectedStatusBarStyle = preferredStatusBarStyle
    }
    
}
