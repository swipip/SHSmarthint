//
//  Hint.swift
//  SmartHint
//
//  Created by Gautier Billard on 04/02/2021.
//

import UIKit

public enum BannerPosition {
    case top
    case bottom
}

public enum CallOutPointerStyle {
    case noPointer
    case triangle
//    case dot
}

public enum HintStyle: Hashable {
    case banner(BannerPosition)
    case callout(CallOutPointerStyle? = .triangle)
    var associatedValue: Any? {
        switch self {
        case .banner(let position):
            return position
        case .callout(let pointerType):
            return pointerType
        }
    }
}

public enum AnimationStyle {
    case fade
    case slideLeft
    case slideRight
    case fromTop
    case fromBottom
    case noAnimation
    
    var reversed: AnimationStyle {
        switch self {
        case .fade, .noAnimation:
            return .noAnimation
        case .slideLeft:
            return .slideRight
        case .slideRight:
            return .slideLeft
        case .fromTop:
            return .fromBottom
        case .fromBottom:
            return .fromTop
        }
    }
}

public class Hint {
    var style: HintStyle = .callout(.triangle)
    public var animationStyle: AnimationStyle = .fade
    public var actions: [HintAction] = []
    public var message: String?
    public var backgroundColor: UIColor? = .systemGray4
    public var textColor: UIColor? = .label
    public var marginFromView: CGFloat = 5
    public var size: CGSize = CGSize(width: 220, height: 60)
    public var image: UIImage?
    public var timeOut: TimeInterval?
    public var enableInteractiveGestureForActions = true
        
    var hasActions:Bool {
        if self.actions.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    var numberOfActions: Int {
        self.actions.count
    }
    
    var height: CGFloat {
        if actions.count == 0 {
            return self.size.height
        }else if actions.count == 2{
            return self.size.height + (enableInteractiveGestureForActions ? 0 : 50)
        }else{
            return self.size.height + (enableInteractiveGestureForActions ? 0 : CGFloat(actions.count - 1) * 45 + 50)
        }
    }
    
    public init(style: HintStyle, actions: [HintAction] = [], message: String? = nil) {
        self.actions = actions
        self.message = message
        self.style = style
    }
    
    public func addAction(_ action: HintAction) {
        actions.append(action)
    }
}
