//
//  DataBase.swift
//  videoCollection
//
//  Created by leon on 2020/12/23.
//  Copyright © 2020 leon. All rights reserved.
//

import UIKit
import CocoaLumberjack
import FMDB

class DataBase: NSObject {
    static let shared = DataBase()
    fileprivate var fileName: String = "TVBS+.db" // sqlite name
    fileprivate var filePath: String = "" // sqlite path
    fileprivate var database: FMDatabase! // FMDBConnection
    fileprivate var queue: FMDatabaseQueue!
    
    private override init() {
        super.init()
        // 取得sqlite在documents下的路徑(開啟連線用)
        guard let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            DDLogInfo("path is nil.")
            return
        }
        filePath = documentPath.appendingPathComponent(fileName).path
        queue = FMDatabaseQueue(path: filePath)
    }
    
    /**
     Create SQLite and Table
     */
    func createTable() {
        self.queue.inDatabase { (db) in
            do {
                //alter Table
                if db.tableExists("favorite") && !db.columnExists("video_time", inTableWithName: "favorite") {
                    try db.executeUpdate("ALTER TABLE favorite ADD COLUMN video_time TEXT", values: nil)
                }
                
                try db.executeUpdate("CREATE TABLE IF NOT EXISTS favorite (video_id TEXT,title TEXT, image TEXT, publish TEXT, menu_id TEXT, menu_nm TEXT, create_date TEXT, video_time TEXT)", values: nil)
            } catch {
                DDLogInfo("Create Table failed:\(error.localizedDescription)")
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                    queue = FMDatabaseQueue(path: filePath)
                    self.createTable()
                } catch {
                    DDLogInfo("Delete Database failed:\(error.localizedDescription)")
                }
            }
        }
    }
    
    //todo
    /**
    Add favorite record.
    - Parameter menuID: String, videoID: String
    */
    func addFavorite(_ chosenList:ChosenList) {
        guard let item = chosenList.videoItem else { return }
        addFavoriteInVideoItem(item)
    }
    
    func addFavoriteInVideoItem(_ itemContent: VideoItemContent) {
        guard let videoID = itemContent.videoID,
              let title = itemContent.title,
              let image = itemContent.image,
              let publish = itemContent.publish,
              getVideoIDCnt(videoID) == 0 else { return }
              let menuID = itemContent.enName ?? ""
              let menuNm = itemContent.name ?? ""
             
        
        queue.inTransaction({ (db, rollback) in
            do {
                var videoTime = ""
                if let tvideoTime = itemContent.videoTime {
                    videoTime = tvideoTime
                }
                try db.executeUpdate("insert into favorite (video_id, title, image, publish, menu_id, menu_nm, video_time, create_date) values (?,?,?,?,?,?,?, (select datetime('now', 'localtime')))", values: [videoID, title, image, publish, menuID, menuNm, videoTime])
            } catch {
                rollback.pointee = true
                DDLogError("addFavorite:\(error.localizedDescription)")
            }
            SM.favoriteArr.append("\(videoID)")
        })
    }
    
    func getVideoIDCnt(_ videoID: String) -> Int {
        var cnt = 0
        queue.inTransaction({ (db, rollback) in
            do {
                let result:FMResultSet?
                result = try db.executeQuery("select count(*) cnt from favorite where video_id = ? ", values: [videoID])
                guard let rs = result else {
                    DDLogError("getVideoIDCnt result fail")
                    return
                }
                
                while rs.next() {
                    cnt = Int(rs.int(forColumn: "cnt"))
                }
                
                rs.close()
            } catch {
                DDLogError("queryHistorySearchRecord:\(error.localizedDescription)")
            }
        })
        return cnt
    }
    
    /**
    Delete favorite record.
    - Parameter menuID: String, videoID: String
    */
    func delFavorite(_ chosenList:ChosenList) {
        if let videoID = chosenList.videoItem?.videoID {
            delFavoriteWithVideoId(videoID)
        }
    }
    
    func delFavoriteWithVideoId(_ id: String) {
        queue.inTransaction({ (db, rollback) in
            do {
                try db.executeUpdate("delete from favorite where video_id = ?", values: [id])
            } catch {
                rollback.pointee = true
                DDLogError("delFavorite:\(error.localizedDescription)")
            }
            SM.favoriteArr = SM.favoriteArr.filter{$0 != "\(id)"}
        })
    }
    
    func unfavorite( newsData: ChosenList, completionHandler: (Bool) -> Void) {
        if let videoID = newsData.videoItem?.videoID {
            queue.inTransaction({ (db, rollback) in
                do {
                    try db.executeUpdate("delete from favorite where video_id = ?", values: [videoID])
                    SM.favoriteArr = SM.favoriteArr.filter{$0 != "\(videoID)"}
                    completionHandler(true)
                } catch {
                    rollback.pointee = true
                    completionHandler(false)
                    DDLogError("delFavorite:\(error.localizedDescription)")
                }
            })
        } else {
            completionHandler(false)
        }
    }
    
    //todo
    /**
    Query favorite records by menuID.
    - Parameter menuID: String
    - Returns: [String].
    */
    func queryFavoriteByMenuID(_ menuID:String) -> [ChosenList] {
        var rtnArr = [ChosenList]()
        queue.inDatabase { (db) in
            do {
                let rs = try db.executeQuery("select * from favorite order by create_date desc", values: [menuID])
                while rs.next() {
                    if let videoID = rs.string(forColumn: "video_id"), let title = rs.string(forColumn: "title"), let image = rs.string(forColumn: "image"), let publish = rs.string(forColumn: "publish"), let menuID = rs.string(forColumn: "menu_id"), let menuNM = rs.string(forColumn: "menu_nm"){
                        var videoTime = ""
                        if let tvideoTime = rs.string(forColumn: "video_time") {
                            videoTime = tvideoTime
                        }
                        if let data = VideoItemContent(JSON: ["video_id":videoID,"title":title,"image":image,"publish":publish,"en_name":menuID,"name":menuNM,"live":"0","video_time":videoTime]) {
                            let chosenList = ChosenList()
                            chosenList.cellLayout = .video
                            chosenList.videoItem = data
                            rtnArr.append(chosenList)
                        }
                    }
                }
                rs.close()
            } catch {
                DDLogError("queryFavoriteByMenuID:\(error.localizedDescription)")
            }
        }
        return rtnArr
    }
    
    /**
    Query favorite records.
    - Returns: [String].
    */
    func queryFavorite() -> [String] {
        var rtnArr = [String]()
        queue.inDatabase { (db) in
            do {
                let rs = try db.executeQuery("select video_id from favorite order by create_date desc", values: nil)
                while rs.next() {
                    if let videoID = rs.string(forColumn: "video_id") {
                        rtnArr.append("\(videoID)")
                    }
                }
                rs.close()
            } catch {
                DDLogError("queryFavorite:\(error.localizedDescription)")
            }
        }
        return rtnArr
    }
    
    /**
     Get connection
     */
    func openConnection() -> Bool {
        var isOpen: Bool = false
        database = FMDatabase(path: filePath)
        if database != nil {
            if database.open() {
                isOpen = true
            } else {
                DDLogError("Could not get the connection.")
            }
        }
        return isOpen
    }
}

