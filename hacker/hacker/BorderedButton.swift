//
//  BorderedButton.swift
//  hacker
//
//  Created by yesway on 2017/1/13.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit
@IBDesignable
class BorderedButton: UIView {
    
    typealias buttonTouchInsideEvent = (_ senderB: UIButton) -> ()
    // MARK: Internals views
    var button : UIButton = UIButton(frame: CGRect.zero)
    let animationDuration = 0.15
    
    // MARK: Callback
    var onButtonTouch: buttonTouchInsideEvent!
    
    @IBInspectable var borderColor: UIColor = UIColor.HNColor() {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.5 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderCornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = borderCornerRadius
        }
    }
    
    @IBInspectable var labelColor: UIColor = UIColor.HNColor() {
        didSet {
            self.button.setTitleColor(labelColor, for: UIControlState())
        }
    }
    
    @IBInspectable var labelText: String = "Default" {
        didSet {
            self.button.setTitle(labelText, for: UIControlState())
        }
    }
    
    @IBInspectable var labelFontSize: CGFloat = 11.0 {
        didSet {
            self.button.titleLabel?.font = UIFont.systemFont(ofSize: labelFontSize)
        }
    }

    
    required init?(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
        self.setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.isUserInteractionEnabled = true
        
        self.button.addTarget(self, action: #selector(BorderedButton.onPress(_:)), for: .touchDown)
        self.button.addTarget(self, action: #selector(BorderedButton.onRealPress(_:)), for: .touchUpInside)
        self.button.addTarget(self, action: #selector(BorderedButton.onReset(_:)), for: .touchUpInside)
        self.button.addTarget(self, action: #selector(BorderedButton.onReset(_:)), for: .touchUpOutside)
        self.button.addTarget(self, action: #selector(BorderedButton.onReset(_:)), for: .touchDragExit)
        self.button.addTarget(self, action: #selector(BorderedButton.onReset(_:)), for: .touchCancel)
    }

    // MARK: views setup
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.borderColor = UIColor.HNColor()
        self.labelColor = UIColor.HNColor()
        self.borderWidth = 0.5
        self.borderCornerRadius = 5.0
        self.labelFontSize = 11.0
        
        self.button.frame = self.bounds
        self.button.titleLabel?.textAlignment = .center
        self.button.backgroundColor = UIColor.clear
        
        self.addSubview(self.button)
    }
    
    // MARK: Actions
    func onPress(_ sender: AnyObject) {
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.labelColor = UIColor.white
            self.backgroundColor = UIColor.HNColor()
        })
    }
    
    func onReset(_ sender: AnyObject) {
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.labelColor = UIColor.HNColor()
            self.backgroundColor = UIColor.clear
        })
    }
    
    func onRealPress(_ sender: AnyObject) {
        self.onButtonTouch(sender as! UIButton)
    }
}
