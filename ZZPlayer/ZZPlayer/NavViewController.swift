//
//  NavViewController.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/8/28.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }

    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }

    override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }
}
