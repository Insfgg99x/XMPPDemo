//
//  ViewController.swift
//  XMPPDemo
//
//  Created by xgf on 2017/12/25.
//  Copyright © 2017年 xgf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        IMManager.shared.send("山羊同学，你好！")
    }
}

