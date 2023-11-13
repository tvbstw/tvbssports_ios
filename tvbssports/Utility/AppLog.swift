//
//  AppLog.swift
//  supertastemvp
//
//  Created by Eddie on 2020/3/5.
//  Copyright © 2020年 Eddie. All rights reserved.
//

import UIKit
import CocoaLumberjack

/**
 Applog save document.
 */
class AppLog: NSObject {
    static let shared = AppLog()
    let fileLogger = DDFileLogger()
    
    #if DEBUG
        static let ddLogLevel = DDLogLevel.verbose;
    #else
        static let ddLogLevel = DDLogLevel.info;
    #endif
    
    override init() {
        super.init()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        fileLogger.logFormatter = AppLogFormatter()
        fileLogger.maximumFileSize = UInt64(1024 * 1024 * 4)
    }
    
    class func config() {
        /// set formatter
        let appLogformatter = AppLogFormatter()
        
        ///TTY = Xcode console
        DDTTYLogger.sharedInstance?.logFormatter = appLogformatter
        DDTTYLogger.sharedInstance?.colorsEnabled = true
        DDTTYLogger.sharedInstance?.setForegroundColor(UIColor.green, backgroundColor: nil, for: DDLogFlag.info)
        DDLog.add(DDTTYLogger.sharedInstance!)
        
        ///ASL = App,e System Logs
        //DDASLLogger.sharedInstance.logFormatter = appLogformatter
        //DDLog.add(DDASLLogger.sharedInstance)
        //DDLog.add(AppLog.shared.fileLogger!)
    }
    
}


/**
 Applog Format.
*/
class AppLogFormatter: NSObject, DDLogFormatter {
    let formatter = DateFormatter()
    
    override init() {
        super.init()
        formatter.dateFormat = "yy-MM-dd HH:mm:ss"
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
        let correctDate = formatter.string(from: logMessage.timestamp)
        var logLevel:String?
        let flag = logMessage.flag
        
        switch flag {
        case DDLogFlag.error :
            logLevel = "[ERROR]"
        case DDLogFlag.warning :
            logLevel = "[WARNING]"
        case DDLogFlag.info :
            logLevel = "[INFO]"
        case DDLogFlag.debug :
            logLevel = "[DEBUG]"
        default:
            logLevel = "[VBOSE]"
        }
        
        let formatStr = String.init(format: "%@ %@ %@ %@ [line %lu] %@", correctDate, logLevel ?? "", logMessage.fileName, logMessage.function ?? "", logMessage.line, logMessage.message)
        
        return formatStr
        
    }
    
}
