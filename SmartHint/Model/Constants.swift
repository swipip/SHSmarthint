//
//  Constants.swift
//  SmartHint
//
//  Created by Gautier Billard on 09/02/2021.
//

import UIKit
public enum ConstantName {
    case buttonsHeight
    case buttonsCornerRadius
    case buttonsTitleColor
    case hintViewCornerRadius
    case interactionAnimationSpeed
    case showAnimationSpeed
    case alertWidth
    case alertSpacing
    case messageFont
    case messageTextColor
    case titleFont
}
struct K {
    
    static var constants: [ConstantName:Any] = [
        .buttonsHeight:CGFloat(40),
        .buttonsCornerRadius:CGFloat(5),
        .buttonsTitleColor:UIColor.label,
        .hintViewCornerRadius:CGFloat(5),
        .interactionAnimationSpeed:Double(0.2),
        .showAnimationSpeed:Double(0.3),
        .alertWidth:CGFloat(260),
        .alertSpacing:CGFloat(10),
        .messageFont:UIFont.systemFont(ofSize: 17,weight: .regular),
        .messageTextColor:UIColor.label,
        .titleFont:UIFont.systemFont(ofSize: 18,weight: .semibold)
    ]
    
    static func getValue<T>(for constant: ConstantName) -> T {
        if let value = constants[constant] as? T {
            return value
        }else{
            let value = constants[constant] as Any
            let _ = NSError(domain: "", code: 1, userInfo: [String(describing: constants):value])
            fatalError("The requested value either does not exist or is not of the requested type")
        }
    }
    
    static func setValue(_ value: Any, forKey key: ConstantName) {
        constants[key] = value
    }
    
}
