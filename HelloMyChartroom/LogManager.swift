//
//  LogManager.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/29.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import Foundation
import SQLite

class LogManager {
    var  messageIDs = [Int64]()
    static let LOG_TABLE_NAME = "Log"
    static let MESSAGEID_KEY = "MessageID"
    
    //SQLite support
    var db: Connection!
    var logTable = Table(LOG_TABLE_NAME)
    var messageColumn = Expression<String>(MESSAGE_KEY)
    var typeColumn = Expression<Int64>(TYPE_KEY)
    var usernameColum = Expression<String>(USERNAME_KEY)
    var idColum = Expression<Int64>(ID_KEY)
    var midColum = Expression<Int64>( MESSAGEID_KEY)
    
    init() {
        //Preapre DB filname/path
        let filemanager = FileManager.default
        guard let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        assertionFailure("Fail to get Caches folder path.")
        return
    }
    let finalFullPath = cachesURL.appendingPathComponent("log.sqlite").path
    var isNewDB = false //Check if this is the first time
        if !filemanager.fileExists(atPath: finalFullPath) {
            isNewDB = true
        }
        
       // Prepare connection for DB
        do {
            db = try Connection(finalFullPath)
        }catch{
            assertionFailure("Open DB Fail")
            return
        }
        
        //Creat table at the first time
        if isNewDB {
            do {
                let command = logTable.create { (builder) in
                    builder.column(midColum, primaryKey: true)
                    builder.column(messageColumn)
                    builder.column(typeColumn)
                    builder.column(usernameColum)
                    builder.column(idColum)
                }
                try db.run(command)
            }catch{
                assertionFailure("Fail to create table\(error)")
            }
        }else {
            //SELECT * FROM "log"
            do {
                for massage in try db.prepare(logTable) {
                    messageIDs.append(massage[midColum])
                }
            }catch{
                assertionFailure("Fail to execute prepare command: \(error)")
            }
            print("there are total\(messageIDs.count) messages in DB")
        }
    }
    
    
    var totalCount: Int {
        return messageIDs.count
    }
    
    func append(message: [String: Any]) {
        
        let messageText = message[MESSAGE_KEY] as? String ?? ""
        let type = message[TYPE_KEY] as? Int64 ?? 0
        let username = message[USERNAME_KEY] as? String ?? ""
        let id = message[ID_KEY] as? Int64 ?? 0
        
        let command = logTable.insert(messageColumn <- messageText, typeColumn <- type, usernameColum <- username, idColum <- id)
        
        do {
            let messageID = try db.run(command)
             messageIDs.append(messageID)
        }catch {
            assertionFailure("Fail to insert a message \(error)e")
        }
        
    }
    
      func getMessage(at: Int) -> [String: Any]? {
        
        guard at >= 0 && at < messageIDs.count else {
            assertionFailure("Invail index.")
            return nil
        }
            
            let targetMessageID = messageIDs[at]
            //SELECT * FROM "log" WHERE mid = xxx
            let results = logTable.filter(midColum == targetMessageID)
        
        //Pick the fist one
        do {
            guard let message = try db.pluck(results) else {
                assertionFailure("Fail to get the only result")
                return nil
            }
            return [MESSAGE_KEY: message[messageColumn], TYPE_KEY:Int (message[typeColumn]), USERNAME_KEY: message[usernameColum], ID_KEY:Int (message[idColum])]
        }catch {
            assertionFailure("Fail to get target message:\(error)")
        }
        return nil
        
        
    }
    
    //Mark: Photo Cache Suppot
    func loadImage(_ filename: String) -> UIImage? {
        
        let fileURL = urlFor(filename)
        return UIImage(contentsOfFile: fileURL.path)
        
    }
    func saveImage(_ filename: String, data: Data) {
        let fileURL = urlFor(filename)
        do {
            try data.write(to: fileURL)
        }catch {
            assertionFailure("Fail to write data to file: \(error)")

        }
        
    }
    private func urlFor(_ filename: String) -> URL {
        guard let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            assertionFailure("Fail to get caches url")
            abort()
        }
        let hashedFilename = String(format: "%d", filename.hashValue)
        return cachesURL.appendingPathComponent(hashedFilename)
    }
    
}
