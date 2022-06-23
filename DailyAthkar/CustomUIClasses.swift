//
//  BorderdTextField.swift
//  UpLine Agent
//
//  Created by Mohamed ElSIfi on 6/4/17.
//  Copyright © 2017 App101. All rights reserved.
//

import UIKit


class BlurredView: UIButton {
    @IBInspectable var dark: Bool = true {
        didSet {
            let statusBlurEffect = UIBlurEffect(style: dark ? UIBlurEffect.Style.dark : UIBlurEffect.Style.regular)
            let statusBlurEffectView = UIVisualEffectView(effect: statusBlurEffect)
            statusBlurEffectView.frame = self.bounds
            statusBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.insertSubview(statusBlurEffectView, at: 0)
        }
    }
}

class RoundedButton: UIButton {
    @IBInspectable var filled: Bool = true {
        didSet {
            if(filled){
                self.backgroundColor = DA_STYLE.darkThemeColor
                self.tintColor = UIColor.white
                self.layer.borderWidth = 0
                
            }else{
                self.backgroundColor = UIColor.clear
                self.tintColor = DA_STYLE.darkThemeColor
                self.layer.borderWidth = 1.5
            }
        }
    }
    
    override var isEnabled: Bool{
        didSet{
            if(isEnabled){
                self.setTitleColor(self.currentTitleColor.withAlphaComponent(1), for: .normal)
                self.layer.borderColor = self.layer.borderColor?.copy(alpha: 1)
                
            }else{
                self.setTitleColor(self.currentTitleColor.withAlphaComponent(0.5), for: .disabled)
                self.layer.borderColor = self.layer.borderColor?.copy(alpha: 0.5)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 6
        self.layer.borderColor = DA_STYLE.darkThemeColor.cgColor
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if(self.filled){
                if backgroundColor!.cgColor.alpha == 0 {
                    if let theOldValue = oldValue{
                        backgroundColor = theOldValue
                    }
                }
            }
        }
    }
    
}



