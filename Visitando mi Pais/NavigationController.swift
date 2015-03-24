//
//  NavigationController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/24/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barStyle = UIBarStyle.Default
        self.navigationBar.barTintColor = self.UIColorFromRGB(0x209624)
        self.navigationBar.tintColor = UIColor.whiteColor()

    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
