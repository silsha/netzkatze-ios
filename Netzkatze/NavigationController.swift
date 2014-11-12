//
//  NavigationController.swift
//  Netzkatze
//
//  Created by silsha on 12/11/14.
//  Copyright (c) 2014 silsha. All rights reserved.
//

import Foundation
import UIKit


class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.Black
        self.navigationBar.tintColor = UIColor.whiteColor()
    }
}

