//
//  MailProvider.swift
//  videoCollection
//
//  Created by Eddie on 2021/12/5.
//  Copyright © 2021 Eddie. All rights reserved.
//

import UIKit
import MessageUI
import CocoaLumberjack

class MailProvider: NSObject {
    
    var title: String?
    var subject: String = ""
    var recipients: [String] = []
    var body: String = ""
    var isSendLog = false
    
    class func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func addMailVC() {
        let mcVC = MFMailComposeViewController()
        mcVC.title = title
        mcVC.setSubject(subject)
        mcVC.setToRecipients(recipients)
        if isSendLog {
            if let logsData = addLogs() {
                mcVC.addAttachmentData(logsData, mimeType: "application/zip", fileName: "\(CACHES_PATH)/logs.zip")
            }
        }
        mcVC.setMessageBody(body, isHTML: true)
        guard let topVC = UIApplication.topViewController() else { return DDLogError("topVC is nil.") }
        topVC.present(mcVC, animated: true, completion: nil)
    }
    
    
    private func addLogs() -> Data? {
        let savePath = "\(CACHES_PATH)/logs.zip"
        let source   = "\(CACHES_PATH)/Logs"
        if US.createZip(savePath: savePath, source: source) {
            if let logsData = NSData(contentsOfFile: savePath) {
                return logsData  as Data
            }
        }
        return nil
    }
}

extension MailProvider: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var resultTitle :String = ""
        var resultMsg :String = ""
        switch result {
        case .cancelled:
            break
        case .saved:
            resultTitle = "郵件已保存"
            resultMsg   = "你的郵件已保存為草稿。"
            break
        case .sent:
            resultTitle = "郵件已寄出"
            resultMsg   = "你的郵件已成功送出。"
            break
        case .failed:
            resultTitle = "郵件發送失敗"
            resultMsg   = "抱歉，郵件發送失敗，請再試一次。"
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
        if resultTitle != "" {
            let alertView = UIAlertController(title: resultTitle, message: resultMsg, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertView.addAction(cancelAction)
            guard let topVC = UIApplication.topViewController() else { return DDLogError("topVC is nil.") }
            topVC.present(alertView, animated: true, completion: nil)
        }
    }
}
