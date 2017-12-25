//
//  AppDelegate.swift
//  XMPPDemo
//
//  Created by xgf on 2017/12/25.
//  Copyright © 2017年 xgf. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IMManager.shared.connect()
        return true
    }
}

