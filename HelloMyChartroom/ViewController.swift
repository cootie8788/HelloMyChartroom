//
//  ViewController.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/27.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var chatView: ChatView!
    let communicator = Commnuicator.shared
    let logManager = LogManager()
    
    let retriveLock = NSLock()
    var shouldRetriveAgin = false

    var lastMessageID = 1
    var incomingMessages = [[String: Any]]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // Ask user's permission to acess photos libary
        PHPhotoLibrary.requestAuthorization { (status) in
            print("PHPotoLibrary.requestAuthorization: \(status.rawValue)")
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(doRefreshJob), name: .didReceiveRemoteMessage, object: nil)
        
        //Load last meaage ID from userdefaults
        lastMessageID = UserDefaults.standard.integer(forKey: LASTMESSAGE_ID_KEY)
        if lastMessageID <= 0 {//Workaround for the first time App launch
            lastMessageID = 1
        }
        #if DEBUG
//        lastMessageID = 1 // Hardcode fot test only
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let startIndex: Int = {
            var result = logManager.totalCount - 20
            if result < 0 {
                result = 0
            }
            return result
        }()
        for i in 0..<(logManager.totalCount - startIndex){
            guard let message = logManager.getMessage(at: startIndex + i) else {
                assertionFailure("Fail to get message")
                continue
            }
            
            incomingMessages.append(message)
            
        }
        handleIncomingMessage()//imaportand
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendTextBtnPressed(_ sender: Any) {
        // !message.isEmpty else
        guard let message = inputTextField.text, message.isEmpty == false else{
            return
        }
        //Dismiss keyboard
        inputTextField.resignFirstResponder()
        //send Text Message
        communicator.sendTexMessage(message) { (error, result) in
            if let error = error {
                print("sendTextMessage Fail: \(error)")
                return
            }else if let result = result {
                print("sendTextMessage OK: \(result)")
                self.doRefreshJob()
            }
        }
    }
    
    @IBAction func sendPhotoBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Chose photo from:", message: nil, preferredStyle: .alert)
        let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.launchPicker(forType: .photoLibrary)
        }
        let camera = UIAlertAction(title: "Carmera", style: .default) { (action) in
            self.launchPicker(forType: .camera)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func refreshBtnPressed(_ sender: Any) {
        doRefreshJob()
    }
    
    @objc
    func doRefreshJob() {
        
        
        //Critucal section
//        objc_sync_enter(self)
//        //
//        objc_sync_exit(self)
        
        //Prevent multi-executes
        guard retriveLock.try() else {
            shouldRetriveAgin = true
            return
        }
        
        
        communicator.retriveMessage(fromID: lastMessageID) { (error, result) in
            if let error = error {
                print("sendTextMessage Fail: \(error)")
                self.unlockRetriveLock()
                return
            }
            guard let result = result else {
                assertionFailure("Invalid result")
                self.unlockRetriveLock()
                return
            }
            
             guard let messages = result[MESSAGES_KEY] as? [[String: Any]] else {
                print("No messages array exist")
                self.unlockRetriveLock()
                return
                
            }
            
            guard messages.count > 0 else {
                print("NO new message")
                self.unlockRetriveLock()
                return
            }
            // Get and update last messageID
            if let lastItem = messages.last, let newLastMessgeID = lastItem[ID_KEY] as? Int {
                self.lastMessageID = newLastMessgeID
                //Save into userdefaults
                let userDefaults = UserDefaults.standard
                userDefaults.set(newLastMessgeID, forKey: LASTMESSAGE_ID_KEY)
                userDefaults.synchronize()
            }
            //Save messages into log manager
            for message in messages {
            self.logManager.append(message: message)
            }
             self.incomingMessages += messages
             self.handleIncomingMessage()
        }
        
     
    }
    
    func unlockRetriveLock() {
        retriveLock.unlock()
        //Retrive again fi here is amy messsage received during current retrive
        retriveLock.unlock()
        if shouldRetriveAgin {
            shouldRetriveAgin = false
            doRefreshJob()
        }
    }
    
    
    func handleIncomingMessage() {
        //Get the first one and check if incomingMessage is Emapty
        guard let item = incomingMessages.first else {
            unlockRetriveLock()
            return
        }
        incomingMessages.removeFirst()
        let message = item[MESSAGE_KEY] as? String ?? ""
        let type = ChatItemType(rawValue: item[TYPE_KEY] as? Int ?? 0) ?? ChatItemType.text
        let usename = item[USERNAME_KEY]as? String ?? ""
        let id = item[ID_KEY]as? Int ?? 0
        let fromSelf = (usename == MY_NAME)
        
        let finalMssage = "\(usename): \(message) (\(id)"
        
        var chatItem = ChatItem(message: finalMssage, type: type, username: usename, id: id, image: nil, formSelf: fromSelf)
        
        if type == .text {//Text Message
            //Show text message
            chatView.add(chatItem: chatItem)
            handleIncomingMessage()
        }else if type == .photo {//Poto Message
            //Download Photo and Show photo message
            //Check if we can pick the photo from Local cache
//            let image = self.logManager.loadImage(message)
//            if let image = image {
            if let image = self.logManager.loadImage(message) {
                chatItem.image = image
                self.chatView.add(chatItem: chatItem)
                self.handleIncomingMessage() // imaportant
                return
            }
            
            communicator.downloadPhoto(message) { (error, data) in
                if let error = error {
                    print("Download Phoo Fail: \(error)")
                }else if let data = data {
                    chatItem.image = UIImage(data: data)
                    self.chatView.add(chatItem: chatItem)
                    //Save image
                    self.logManager.saveImage(message, data: data)
                }
                self.handleIncomingMessage()//important
            }
        }else {
            handleIncomingMessage()
        }
    }
    //MARK: -UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTextBtnPressed(self)
        return false
    }
    //MARk UIImagePickerController & Protocol Methods
    func launchPicker(forType: UIImagePickerControllerSourceType) {
        //Check if this is a vaild source Type
        guard UIImagePickerController.isSourceTypeAvailable(forType) else {
            print("Invaild source Type")
            return
        }
        let picker = UIImagePickerController()
     //   picker.mediaTypes = ["public.image", "public.movie"]
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        picker.sourceType = forType
        picker.delegate = self
        
        present(picker, animated: true)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("didFinishPickingMediaWithInfo: \(info)")
        guard let type = info[UIImagePickerControllerMediaType] as? String else {
            assertionFailure("Invalid type.")
            return
        }
        if type == (kUTTypeImage as String) {
          guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                assertionFailure("No Orinagl Image")
                return
            }
            print("Original Image: \(originalImage.size)")
//            let pngData = UIImagePNGRepresentation(originalImage)
//            let jpnData = UIImageJPEGRepresentation(originalImage,0.8)
//            print("pngData: \(pngData!.count) bytes.jpgData: \(jpnData!.count) bytes")
            
            //Resize originalImage
            guard let resizedImage = originalImage.resize(maxWidthHeight: 1000)
                else {
                    assertionFailure("Fail to resize image ")
                    return
            }
            print("Resize Image: \(resizedImage.size)")
//            let pngData2 = UIImagePNGRepresentation(originalImage)
//            let jpnData2 = UIImageJPEGRepresentation(originalImage, 0.8)
//            print("pngData: \(pngData2!.count) bytes.jpgData: \(jpnData2!.count) bytes")
            guard let jpnData = UIImageJPEGRepresentation(originalImage, 0.8) else {
                assertionFailure("Fail to generrate JPG File")
                return
            }

            communicator.sendPhotoMessage(jpnData) { (error, result) in
                if let error = error {
                    print("sendPhotoMessage Fail: \(error)")
                    return
                }else if let result = result {
                    print("sendPhotoMessage OK: \(result)")
                    self.doRefreshJob()
                }
            }
            
            
        }else if type == (kUTTypeMovie as String) {
            //
        }
        picker.dismiss(animated: true)
    }
    
}


