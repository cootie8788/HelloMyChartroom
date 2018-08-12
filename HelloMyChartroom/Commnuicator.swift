//
//  Commnuicator.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/27.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import Foundation
import Alamofire

typealias DoneHandler = (_ error:Error?, _ result:[String: Any]?) -> Void
typealias DownloadDoneHandler = (_ error:Error?, _ result:Data?) -> Void
let GROUPNAME = "CP101"
let MY_NAME = "十甲劉德華"



class Commnuicator {
    
    // Constants
    static let BASEURL = "http://class.softarts.cc/PushMessage/"
    let UPDATEDEVICETOKEN_URL = BASEURL + "updateDeviceToken.php"
    let RETRIVE_MESSAGES_URL = BASEURL + "retriveMessages2.php"
    let SEND_MESSAGE_URL = BASEURL + "sendMessage.php"
    let SEND_PHOTOMESSAGE_URL = BASEURL + "sendPhotoMessage.php"
    let PHOTO_BASE_URL = BASEURL + "photos/"
    
    
    //Singleton instance
    static let shared = Commnuicator()
    
    private init() {
        
    }
    
    //Variables\
    var accessToken = ""
    //提供回報Token 功能
    func updateDeviceToken(_ deviceToken: String, doneHandler: @escaping DoneHandler)  {
        
        let parameters = [GROUPNAME_KEY: GROUPNAME, USERNAME_KEY: MY_NAME, DEVICETOKEN_KEY: deviceToken]
        
        
        doPost(UPDATEDEVICETOKEN_URL, parameters: parameters, doneHandler: doneHandler)
        
    }
    
    func sendTexMessage (_ message: String, doneHandler: @escaping DoneHandler)  {
        
        let parameters = [GROUPNAME_KEY: GROUPNAME, USERNAME_KEY: MY_NAME, MESSAGE_KEY: message]
        
        
        doPost(SEND_MESSAGE_URL, parameters: parameters, doneHandler: doneHandler)
        
    }
    
    func downloadPhoto(_ filename: String, doneHandler: @escaping DownloadDoneHandler) {
        let finalURLString = PHOTO_BASE_URL + filename
        Alamofire.request(finalURLString).responseData { (response) in
            switch response.result {
            case .success(let data):
                print("Download OK: \(data.count) bytes")
                doneHandler(nil, data)
            case .failure(let error):
                print("Download Fail: \(error)")
                doneHandler(error, nil)
            }
        }

        
    }
    
    func sendPhotoMessage (_ data: Data, doneHandler: @escaping DoneHandler)  {
        
        let parameters = [GROUPNAME_KEY: GROUPNAME, USERNAME_KEY: MY_NAME]
        
        
        doPost(SEND_PHOTOMESSAGE_URL, parameters: parameters, data: data,  doneHandler: doneHandler)
        
    }
    
    func retriveMessage (fromID: Int, doneHandler: @escaping DoneHandler)  {
        
//        let parameters = [GROUPNAME_KEY: GROUPNAME, LASTMESSAGE_ID_KEY: fromID] as [String : Any]
        let parameters: [String : Any] = [GROUPNAME_KEY: GROUPNAME, LASTMESSAGE_ID_KEY: fromID]
        
        
        doPost(RETRIVE_MESSAGES_URL, parameters: parameters, doneHandler: doneHandler)
        
    }
    private func doPost(_ urlString: String, parameters:[String:Any], data:Data, doneHandler: @escaping DoneHandler) {
         let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        Alamofire.upload(multipartFormData: { (formdata) in
            formdata.append(jsonData, withName: DATA_KEY)
            formdata.append(data, withName: "fileToUpload", fileName: "image,jpg", mimeType: "image/jpg")
        }, to: urlString, method: .post) { (encodingResult) in
            switch encodingResult {
            case .success(let request, _, _):
                request.responseJSON { (response) in
                    self.handleJSONResponse(response, doneHandler: doneHandler)
                }
                print("Econd ok.")
            case .failure(let error):
                print("Encoding Fail: \(error)")
                doneHandler(error, nil)
            }
        }
    
    }
    
    
    private func doPost(_ urlString: String, parameters:[String:Any], doneHandler: @escaping DoneHandler) {
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let finalParameters = [DATA_KEY: jsonString]
        
        Alamofire.request(urlString, method: .post, parameters: finalParameters, encoding: URLEncoding.default).responseJSON { (response) in
            
        self.handleJSONResponse(response, doneHandler: doneHandler)
            
        }
        
    }
    
    private func handleJSONResponse(_ response: DataResponse<Any>, doneHandler: DoneHandler) {
        switch response.result {
        case .success(let json):
            print("Get Respond: \(json)")
            //Check if server result is true of false
            guard let finalJSON = json as? [String: Any] else {
                // fail due to invalid json
                let error = NSError(domain: "Server respond is not dictionary", code: -1, userInfo: nil)
                doneHandler(error, nil)
                return
            }
            guard let serverResult = finalJSON[RESULT_KEY] as? Bool else  {
                // fail due to invaild json
                let error = NSError(domain: "Server respond don't include result", code: -1, userInfo: nil)
                doneHandler(error, nil)
                return
            }
            if serverResult {
                //Real sucess
                doneHandler(nil, finalJSON)
            }else {
                //Server result fail
                let error = NSError(domain: "Server respond result fail", code: -1, userInfo: nil)
                doneHandler(error, finalJSON)
                
            }
        case .failure(let error):
            print("Fail with Error: \(error)")
            doneHandler(error, nil)
        }
        
    }

}

