//
//  Extensions.swift
//
//  Created by Mohamed ElSIfi on 5/17/17.
//  Copyright © 2017 . All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func maskWith(color: UIColor){
        self.image = self.image?.maskWith(color: color)
    }
    
}

extension UIImage {
    
        var noir: UIImage {
            let context = CIContext(options: nil)
            let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
            currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            let output = currentFilter.outputImage!
            let cgImage = context.createCGImage(output, from: output.extent)!
            let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
            
            return processedImage
        }
    
    
    func trim() -> UIImage {
        let newRect = self.cropRect
        if let imageRef = self.cgImage!.cropping(to: newRect) {
            return UIImage(cgImage: imageRef)
        }
        return self
    }
    
    var cropRect: CGRect {
        let cgImage = self.cgImage
        let context = createARGBBitmapContextFromImage(inImage: cgImage!)
        if context == nil {
            return CGRect.zero
        }
        
        let height = CGFloat(cgImage!.height)
        let width = CGFloat(cgImage!.width)
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context?.draw(cgImage!, in: rect)
        
        //let data = UnsafePointer<CUnsignedChar>(CGBitmapContextGetData(context))
        guard let data = context?.data?.assumingMemoryBound(to: UInt8.self) else {
            return CGRect.zero
        }
        
        var lowX = width
        var lowY = height
        var highX: CGFloat = 0
        var highY: CGFloat = 0
        
        let heightInt = Int(height)
        let widthInt = Int(width)
        //Filter through data and look for non-transparent pixels.
        for y in (0 ..< heightInt) {
            let y = CGFloat(y)
            for x in (0 ..< widthInt) {
                let x = CGFloat(x)
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */
                
                if data[Int(pixelIndex)] == 0  { continue } // crop transparent
                
                if data[Int(pixelIndex+1)] > 0xE0 && data[Int(pixelIndex+2)] > 0xE0 && data[Int(pixelIndex+3)] > 0xE0 { continue } // crop white
                
                if (x < lowX) {
                    lowX = x
                }
                if (x > highX) {
                    highX = x
                }
                if (y < lowY) {
                    lowY = y
                }
                if (y > highY) {
                    highY = y
                }
                
            }
        }
        
        return CGRect(x: lowX, y: lowY, width: highX - lowX, height: highY - lowY)
    }
    
    func createARGBBitmapContextFromImage(inImage: CGImage) -> CGContext? {
        
        let width = inImage.width
        let height = inImage.height
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
        let context = CGContext (data: bitmapData,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: 8,      // bits per component
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        return context
    }
    
    func imageByMakingWhiteBackgroundTransparent(image: UIImage) -> UIImage? {
        
        //Create transparent mask
        let colorMasking: [CGFloat] = [240, 255, 235, 255, 235, 255]
        UIGraphicsBeginImageContext(image.size)
        
        //Add mask to image and return result
        if let maskedImageRef = image.cgImage?.copy(maskingColorComponents: colorMasking) {
            UIGraphicsGetCurrentContext()!.translateBy(x: 0.0, y: image.size.height)
            UIGraphicsGetCurrentContext()!.scaleBy(x: 1.0, y: -1.0)
            UIGraphicsGetCurrentContext()?.draw(maskedImageRef, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
        
        return self
    }
    
    
    func maskWith(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x:0, y:0, width:newSize.width, height:newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
    func resizedImageWithinRectWithoutAspectRatio(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        
        let newSize = CGSize(width: size.width/widthFactor, height: size.height/heightFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
    
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let newHeight = self.size.height
        UIGraphicsBeginImageContext(CGSize(width: newHeight, height: newHeight))
        let center = (newHeight - newWidth) / 2
        self.draw(in: CGRect(x: center, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
    
    
}

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}




extension String {
    
    var localized: String {
        return NSLocalizedString(self.lowercased(), comment:"")
    }
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}



public extension UIViewController{
    func showToast(message:String, long : Bool = false, completion:MBProgressHUDCompletionBlock?){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.minShowTime = long ? 4 : 1.5
        hud.label.text = message
        hud.label.numberOfLines = 0
        hud.completionBlock = completion
        hud.hide(animated: true)
    }
}


import ObjectiveC
var AssociatedObjectHandle: UInt8 = 0
public extension UIView {
    
    
    var stringTag:String {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        
        // You can change these values, so that you won't have to write a long function
        let defaultRepeatCount = 3
        let defaultTotalDuration = 0.3
        let defaultTranslation = -3
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        animation.repeatCount = count ?? Float(defaultRepeatCount)
        animation.duration = (duration ?? defaultTotalDuration)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? defaultTranslation
        layer.add(animation, forKey: "shake")
        
    }
    
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    
}

extension UIButton {
    func setTitleWithoutAnimation(title: String?) {
        UIView.setAnimationsEnabled(false)
        
        setTitle(title, for: .normal)
        
        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}




extension UILabel {
    
   
    var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if (self.font.fontName.range(of:"bold") == nil && self.font.fontName.range(of:"Bold") == nil) {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
    
    var substituteFontNameBold : String {
        get { return self.font.fontName }
        set {
            
            if (self.font.fontName.range(of:"bold") != nil || self.font.fontName.range(of:"Bold") != nil) {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
}

