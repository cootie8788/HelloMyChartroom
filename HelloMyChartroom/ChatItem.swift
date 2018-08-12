//
//  ChatItem.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/28.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import UIKit



enum ChatItemType: Int {
    case text = 0
    case photo = 1
}

struct ChatItem {
    let message: String
    let type: ChatItemType
    let username: String
    let id: Int
    
    //Optional variables
    var image: UIImage?
    var formSelf = false

}
