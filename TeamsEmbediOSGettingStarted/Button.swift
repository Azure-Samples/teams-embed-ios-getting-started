//
//  Button.swift
//  TeamsEmbediOSGettingStarted
//
//  Created by Raimond Sinivee on 4/14/21.
//

import UIKit

class Button : UIButton {
    
    public init(text: String) {
        super .init(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        self.backgroundColor = .black
        self.setTitle(text, for: .normal)
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func enable() {
        self.isEnabled = true
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    public func disable() {
        self.isEnabled = false
        self.setTitleColor(UIColor.gray, for: .normal)
        self.layer.borderColor = UIColor.gray.cgColor
    }
}
