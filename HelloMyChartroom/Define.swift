//
//  Define.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/28.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import Foundation

// JSON Keys
let ID_KEY = "id"
let USERNAME_KEY = "UserName"
let MESSAGES_KEY = "Messages"
let MESSAGE_KEY = "Message"
let DEVICETOKEN_KEY = "DeviceToken"
let GROUPNAME_KEY = "GroupName"
let LASTMESSAGE_ID_KEY  = "LastMessageID"
let TYPE_KEY = "Type"
let DATA_KEY = "data"
let RESULT_KEY = "result"



extension  Notification.Name {
    static let didReceiveRemoteMessage = Notification.Name("didReceiveRemoteMessage")
    
    
    
}
