//
//  IMManager.swift
//  XMPPDemo
//
//  Created by xgf on 2017/12/25.
//  Copyright © 2017年 xgf. All rights reserved.
//

import UIKit
import XMPPFramework

class IMManager: NSObject ,XMPPStreamDelegate {

    static let shared = IMManager.init()
    private var stream:XMPPStream = XMPPStream.init()
    private let queue = DispatchQueue.init(label: "stream", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    //gateway
    func connect() {
        
        let jid = XMPPJID(user: "iosdev", domain: "caigouku.com", resource: "jb")
        stream.hostName = "caigouku.com"
        stream.hostPort = 5222
        stream.myJID = jid
        stream.addDelegate(self, delegateQueue: queue)
        let reconnect = XMPPReconnect.init()
        reconnect.activate(stream)
        reconnect.autoReconnect = true
        do{ try stream.connect(withTimeout: TimeInterval(30)) } catch _ {}
    }
    func send(_ content:String) {
        let targetId = XMPPJID(user: "yangwenq", domain: "caigouku.com", resource: nil)
        let message = XMPPMessage.init(type: "chat", to: targetId)
        message.addBody(content)
        stream.send(message)
    }
    //MARK:XMPPStreamDelegate
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("连接断开")
    }
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("连接成功")
        do{ try stream.authenticate(withPassword: "iosDev189") } catch{}
    }
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("收到消息：\(message)")
    }
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("消息发送成功")
    }
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("消息发送失败")
    }
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("登录成功")
    }
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("登录失败：\(error)")
    }
}
