//
//  IMManager.swift
//  XMPPDemo
//
//  Created by xgf on 2017/12/25.
//  Copyright © 2017年 xgf. All rights reserved.
//

import UIKit
import XMPPFramework

class IMManager: NSObject ,XMPPStreamDelegate ,XMPPRosterDelegate,XMPPRosterMemoryStorageDelegate,XMPPIncomingFileTransferDelegate,XMPPOutgoingFileTransferDelegate,UIAlertViewDelegate{

    static let shared = IMManager.init()
    private var stream:XMPPStream = XMPPStream.init()
    private var roster:XMPPRoster = XMPPRoster.init(rosterStorage: XMPPRosterMemoryStorage.init())
    private var incomeFileTransfer:XMPPIncomingFileTransfer = XMPPIncomingFileTransfer.init()
    private var outputFileTransfer:XMPPOutgoingFileTransfer = XMPPOutgoingFileTransfer.init()
    private var friendApplyPresence:XMPPPresence?
    
    //request gateway
    //then connect
    func connect() {
        //whxia
        //iosdev
        let jid = XMPPJID(user: "iosdev", domain: "caigouku.com", resource: "jb")
        stream.hostName = "caigouku.com"
        stream.hostPort = 5222
        stream.myJID = jid
        let streamQueue = DispatchQueue.init(label: "stream",
                                             qos: .default,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .inherit,
                                             target: nil)
        stream.addDelegate(self, delegateQueue: streamQueue)
        
        let reconnect = XMPPReconnect.init()
        reconnect.activate(stream)
        reconnect.autoReconnect = true
    
        let autoping = XMPPAutoPing.init()
        autoping.pingInterval = 4.8*60//heart beat 4.8min
        autoping.respondsToQueries = true
        autoping.activate(stream)
        
        let memerystore = XMPPRosterMemoryStorage.init()
        roster = XMPPRoster.init(rosterStorage: memerystore!)
        roster.activate(stream)
        let rosterQueue = DispatchQueue.init(label: "roster",
                                             qos: .default,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .inherit,
                                             target: nil)
        roster.addDelegate(self, delegateQueue: rosterQueue)
        roster.autoFetchRoster = true
        roster.autoAcceptKnownPresenceSubscriptionRequests = true//close auto accept friend apply
        
        let archivingstore = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        let storeQueue = DispatchQueue.init(label: "store",
                                             qos: .default,
                                             attributes: .concurrent,
                                             autoreleaseFrequency: .inherit,
                                             target: nil)
        let archiving = XMPPMessageArchiving.init(messageArchivingStorage: archivingstore, dispatchQueue: storeQueue)
        archiving?.activate(stream)
        
        let incomeFileQueue = DispatchQueue.init(label: "incomeFile",
                                            qos: .default,
                                            attributes: .concurrent,
                                            autoreleaseFrequency: .inherit,
                                            target: nil)
        incomeFileTransfer = XMPPIncomingFileTransfer.init(dispatchQueue: incomeFileQueue)
        incomeFileTransfer.activate(stream)
        incomeFileTransfer.addDelegate(self, delegateQueue: incomeFileQueue)
        incomeFileTransfer.autoAcceptFileTransfers = true
        
        let outgoingFileQueue = DispatchQueue.init(label: "outgoingFile",
                                                 qos: .default,
                                                 attributes: .concurrent,
                                                 autoreleaseFrequency: .inherit,
                                                 target: nil)
        outputFileTransfer = XMPPOutgoingFileTransfer.init(dispatchQueue: outgoingFileQueue)
        outputFileTransfer.activate(stream)
        outputFileTransfer.addDelegate(self, delegateQueue: outgoingFileQueue)
        
        do{ try stream.connect(withTimeout: TimeInterval(30)) } catch _ {}
    }
}
//MARK:send
extension IMManager {
    //send text
    func send(text:String) {
        let targetId = XMPPJID(user: "whxia", domain: "caigouku.com", resource: nil)
        let message = XMPPMessage.init(type: "chat", to: targetId)
        message.addBody(text)
        stream.send(message)
    }
    //send file
    func send(file:String) {
        let url = URL.init(fileURLWithPath: file)
        var data:Data? = nil
        do{
            try data = Data.init(contentsOf: url)
        }catch let error {
            print(#function + error.localizedDescription)
        }
        guard data != nil else {
            return
        }
        //iosdev
        //whxia
        let targetId = XMPPJID(user: "whxia", domain: "caigouku.com", resource: nil)
        outputFileTransfer.send(data!, toRecipient: targetId)
    }
}
//MARK:connect
extension IMManager {
    func xmppStream(_ sender: XMPPStream, socketDidConnect socket: GCDAsyncSocket) {
        print("socket did connect")
    }
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("xml did disconnect")
    }
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("xml did connect")
        do{
            //iosDev189
            //xiaCGK1991
            try stream.authenticate(withPassword: "iosDev189")
        } catch let error{
            print(#function + error.localizedDescription)
        }
    }
}
//MARK:message
extension IMManager {
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("new msg: \(message.name ?? "")\(message.body ?? "")")
    }
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("message send success")
    }
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("msg send error")
    }
}
//MARK:login
extension IMManager {
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("login success")
        let presence = XMPPPresence.init()
        presence.addChild(DDXMLNode.element(withName: "status", stringValue: "在线") as! DDXMLNode)
        presence.addChild(DDXMLNode.element(withName: "show", stringValue: "xa") as! DDXMLNode)
        stream.send(presence)
    }
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("login failed: \(error)")
    }
}
//MARK:friends
extension IMManager {
    func xmppRoster(_ sender: XMPPRoster, didReceivePresenceSubscriptionRequest presence: XMPPPresence) {
        let msg = presence.from?.bare ?? "" + "May i make a friend with you?"
        let alert = UIAlertView.init(title: "Tip", message: msg, delegate: self, cancelButtonTitle: "Reject", otherButtonTitles: "Agree")
        alert.show()
    }
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        guard presence.from != nil else {
            return
        }
        if presence.type == "unsubscribe" {//friend delete
            roster.removeUser(presence.from!)//remove from contact
        }
    }
    func xmppRosterDidBeginPopulating(_ sender: XMPPRoster, withVersion version: String) {
        //start sync friend list
    }
    func xmppRosterDidEndPopulating(_ sender: XMPPRoster) {
        //friend sync end(has been saved in coredata)
        NotificationCenter.default.post(Notification.init(name: Notification.Name.init("XMPPRosterDidChangeNotification")))
    }
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterItem item: DDXMLElement) {
        //receive every friend
    }
    func xmppRosterDidChange(_ sender: XMPPRosterMemoryStorage!) {
        NotificationCenter.default.post(Notification.init(name: Notification.Name.init("XMPPRosterDidChangeNotification")))
    }
    //MARK:UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        guard friendApplyPresence != nil, friendApplyPresence?.from != nil else {
            return
        }
        if buttonIndex == 0 {
            roster.rejectPresenceSubscriptionRequest(from: friendApplyPresence!.from!)
        }else{
            roster.acceptPresenceSubscriptionRequest(from: friendApplyPresence!.from!, andAddToRoster: true)
        }
    }
}
//MARK:incoming file
extension IMManager {
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer!, didReceiveSIOffer offer: XMPPIQ!) {
        sender.acceptSIOffer(offer)
    }
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer!, didSucceedWith data: Data!, named name: String!) {
        let paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let url = URL(fileURLWithPath: paths.last as! String).appendingPathComponent(name)
        do {
            try data.write(to: url, options: [])
        }catch let error as NSError {
            print("Could not sendFile \(error), \(error.userInfo)")
        }
        print("Data was written to the path: " + url.absoluteString)
    }
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer!, didFailWithError error: Error!) {
        print("incoming file transfer failed with error:\(error.localizedDescription)")
    }
}
//MARK:outgoing file
extension IMManager {
    func xmppOutgoingFileTransfer(_ sender: XMPPOutgoingFileTransfer!, didFailWithError error: Error!) {
        print("outgoing file transfer failed with error:\(error.localizedDescription)")
    }
    func xmppOutgoingFileTransferDidSucceed(_ sender: XMPPOutgoingFileTransfer!) {
        print("outgoinf file send success")
    }
    func xmppOutgoingFileTransferIBBClosed(_ sender: XMPPOutgoingFileTransfer!) {
        print(#function)
    }
}
