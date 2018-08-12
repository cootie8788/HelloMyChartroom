//
//  ChatView.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/28.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import UIKit

class ChatView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //Constants
    let padding: CGFloat = 20.0
    //Variables
    var lastBubbleViewY: CGFloat = 0.0
    var allItems = [ChatItem]()
    
    func add(chatItem: ChatItem) {
        //Create and add bubble View
        let bubbleView = chatBubbleView(item: chatItem, maxChatViewWidth: self.frame.width, offsetY: lastBubbleViewY + padding)
        self.addSubview(bubbleView)
        //Adjust variabless
        lastBubbleViewY = bubbleView.frame.maxY
        self.contentSize = CGSize(width: self.frame.width, height: lastBubbleViewY)
        //keep chat item
        allItems.append(chatItem)
        
        // Scroll to bottom 如果有新訊息就會捲到最下面
        let leftBottomRect = CGRect(x: 0, y: lastBubbleViewY - 1, width: 1, height: 1)
        scrollRectToVisible(leftBottomRect, animated: true)
    }

}

class chatBubbleView: UIView {
    
     //Varibles and subViews
    var imageView: UIImageView?
    var textLabel: UILabel?
    var backgroundImageView: UIImageView?
    var currentY: CGFloat = 0.0
    
    //Constants from Chat View/
    let item: ChatItem
    let fullWidth: CGFloat
    var offsetY: CGFloat
    
    //Constants for display
    let sidePaddingRate: CGFloat = 0.02
    let maxBubbleWidthRate: CGFloat = 0.7
    let contentMargin: CGFloat = 10.0
    let bubbleTailWidth: CGFloat = 10.0
    let textFontSize: CGFloat = 16.0
    
    
    
    init(item: ChatItem, maxChatViewWidth: CGFloat, offsetY: CGFloat) {
        self.item = item
        self.fullWidth = maxChatViewWidth
        self.offsetY = offsetY
        super.init(frame: CGRect.zero)
        
        
        //Step1: Decide a basic frame
        self.frame = cuculateBasicFrame()
        //Step2: Decide imageview‘s frame.
        prepareImageView()
        //Step3: Decide text label's frame
        prepareTextLabel()
        //Step4: Decide Final Size of bubble view
         decideFinalSize()
        //Step5: Displat bubble view background
        prepareBackgroundImageView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    private func cuculateBasicFrame() -> CGRect {
        let sidePadding = fullWidth * sidePaddingRate
        let maxBubbleViewWidth = fullWidth * maxBubbleWidthRate
        let offsetX: CGFloat
        if item.formSelf {
            offsetX = fullWidth - sidePadding - maxBubbleViewWidth
        }else {
            offsetX = sidePadding
        }
        return CGRect(x: offsetX, y: offsetY, width: maxBubbleViewWidth, height: 20.0)
    }
    
    private func prepareImageView() {
        //Check if this item include image or not
        guard let image = item.image else {
            return
        }
        //Decide X and Y
        var x = contentMargin
        let y = contentMargin
        if !item.formSelf {
            x += bubbleTailWidth
        }
    
        //Decide width and height
        let displayWidth = min(image.size.width, self.frame.width, self.frame.width - 2 * contentMargin - bubbleTailWidth)
        let displayRatio = displayWidth / image.size.width
        let displayHeight = image.size.height * displayRatio
        //Decide final frame
        
        let displayFrame = CGRect(x: x, y: y, width: displayWidth, height: displayHeight)
        
        //Creat and prepare image View

        let photoImageView = UIImageView(frame: displayFrame)
        self.imageView = photoImageView
        imageView = UIImageView(frame: displayFrame)
        photoImageView.image = image
        photoImageView.layer.cornerRadius = 5.0
        photoImageView.layer.masksToBounds = true
        
        self.addSubview(photoImageView)
        currentY = photoImageView.frame.maxY
    }
    
    private func prepareTextLabel() {
        //Check if we should show text or not
        let text = item.message
        guard !text.isEmpty else {
            return
        }
        //Decide x and y
        //Decide X and Y
        var x = contentMargin
        let y = currentY + textFontSize / 2
        if !item.formSelf {
            x += bubbleTailWidth
        }
        
        
        //Decide width and height
          let displayWidth = self.frame.width - 2 * contentMargin - bubbleTailWidth
        
        //Decide final frame of text label
         let displayFtrame = CGRect(x: x, y: y, width: displayWidth, height: textFontSize)
        
        //Create and prepare text label
        let label = UILabel(frame: displayFtrame)
        self.textLabel = label
        label.font = UIFont.systemFont(ofSize: textFontSize)
        label.numberOfLines = 0 //important
        label.text = text
        label.sizeToFit() ////important
        
        
        self.addSubview(label)
        currentY = label.frame.maxY
        
    }
    
    private func decideFinalSize(){
        var finalWidth: CGFloat = 0.0
        let finalHeight : CGFloat = currentY + contentMargin
        //Get width of image View
        if let imageView = imageView {
            if item.formSelf {
                finalWidth = imageView.frame.maxX + contentMargin + bubbleTailWidth
            }else {
                finalWidth = imageView.frame.maxX + contentMargin
            }
            
        }
        //Compare with width of size
        if let label = textLabel {
            var tmpWidth: CGFloat
            if item.formSelf {
                tmpWidth = label.frame.maxX + contentMargin + bubbleTailWidth
            }else {
                tmpWidth = label.frame.maxX + contentMargin
    
            }
            finalWidth = max(finalWidth, tmpWidth)
            
        }
        // final.fromSelf
        if item.formSelf && self.frame.width > finalWidth {
            self.frame.origin.x += self.frame.width - finalWidth
        }
        self.frame.size = CGSize(width: finalWidth, height: finalHeight)
    }
    
    private func prepareBackgroundImageView() {
        let image: UIImage?
        if item.formSelf {
            let insets = UIEdgeInsets(top: 14, left: 14, bottom: 17, right: 28)
            image = UIImage(named: "fromMe.png")?.resizableImage(withCapInsets: insets)
        }else {
            let insets = UIEdgeInsets(top: 14, left: 22, bottom: 17, right: 20)
            image = UIImage(named: "fromOthers.png")?.resizableImage(withCapInsets: insets)
        }
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let imageView = UIImageView(frame: frame)
        self.backgroundImageView = imageView
        imageView.image = image
        self.addSubview(imageView)
        self.sendSubview(toBack: imageView)
    }

}

