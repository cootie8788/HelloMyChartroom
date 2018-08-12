//
//  UIImage+Resize.swift
//  HelloMyChartroom
//
//  Created by 林沂諺 on 2018/6/29.
//  Copyright © 2018年 AppleCode. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resize(maxWidthHeight: CGFloat) -> UIImage? {
        // Check if cutrrent image is already amaller than maxWidthHeight?
        if self.size.width <= maxWidthHeight
            && self.size.height <= maxWidthHeight {
            return self
        }
        //Decide final size
        let finalSize: CGSize
        if self.size.width >= self.size.height {
            let ratio = self.size.width / maxWidthHeight
             finalSize = CGSize(width: maxWidthHeight, height: self.size.height / ratio)
        }else {//Height> width
            let ratio = self.size.height / maxWidthHeight
            finalSize = CGSize(width: self.size.width / ratio , height: maxWidthHeight)
        }
        
        //Generate a  new Image
        UIGraphicsBeginImageContext(finalSize)
        let drawRect = CGRect(x: 0, y: 0 , width: finalSize.width, height: finalSize.height)
        self.draw(in: drawRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext() //重要
        return result
        
    }
    
    
    
}
