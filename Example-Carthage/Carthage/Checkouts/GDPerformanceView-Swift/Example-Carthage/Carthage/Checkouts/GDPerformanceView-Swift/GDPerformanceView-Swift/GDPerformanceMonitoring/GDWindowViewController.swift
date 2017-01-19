//
//  GDWindowViewController.swift
//  GDPerformanceView-Swift
//
//  Created by Daniil Gavrilov on 15.01.17.
//  Copyright © 2017 Daniil Gavrilov. All rights reserved.
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
