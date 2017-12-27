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
        let titles = ["text","file"]
        for i in 0...1 {
            let btn = UIButton.init(type: .roundedRect)
            btn.frame = CGRect.init(x: Int(self.view.center.x - 30), y: 100+60*i, width: 60, height: 40)
            btn.setTitle(titles[i], for: .normal)
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(btnDidClick(_:)), for: .touchUpInside)
            btn.layer.cornerRadius = 4
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 0.5
            view.addSubview(btn)
        }
    }
    @objc private func btnDidClick(_ sender:UIButton) {
        let index = sender.tag - 100
        if index == 0 {
            sendText()
        }else{
            sendFile()
        }
    }
    private func sendText() {
        IMManager.shared.send(text: "Hello，I'm iosdev -.-")
    }
    private func sendFile() {
        let path = Bundle.main.path(forResource: "test", ofType: "png")
        guard path != nil else {
            return
        }
        IMManager.shared.send(file: path!)
    }
}

