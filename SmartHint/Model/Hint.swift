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

/**
 You can choose between two styles.
    - A banner which gets displayed right below the targeted view. The banner takes up the entire screen width. Banners have an interactive gesture enabled by default.
    - A callout which gets displayed right below the targeted view. Callouts are customizable in size and have an optionnal pointer pointing toward the target.
 */
public enum HintStyle: Hashable {
    case banner(BannerPosition)
    case callout(CallOutPointerStyle? = .triangle)
    case alert
    var associatedValue: Any? {
        switch self {
        case .banner(let position):
            return position
        case .callout(let pointerType):
            return pointerType
        case .alert:
            return nil
        }
    }
}
///The available animation styles. You must pass an animation duration as associated value.
public enum AnimationStyle {
    case fade(Double)
    case slideLeft(Double)
    case slideRight(Double)
    case fromTop(Double)
    case fromBottom(Double)
    case noAnimation
    
    var reversed: AnimationStyle {
        switch self {
        case .fade(_), .noAnimation:
            return .noAnimation
        case .slideLeft(let duration):
            return .slideRight(duration)
        case .slideRight(let duration):
            return .slideLeft(duration)
        case .fromTop(let duration):
            return .fromBottom(duration)
        case .fromBottom(let duration):
            return .fromTop(duration)
        }
    }
}

public class Hint {
    
    private lazy var _textField: UITextField = {
        let field = UITextField()
        field.tintColor = self.textColor
        field.backgroundColor = self.buttonsColor
        field.textAlignment = .center
        field.clipsToBounds = true
        field.layer.cornerRadius = K.getValue(for: .buttonsCornerRadius)
        return field
    }()
    
    var id: String?
    
    /**
     The  textField which can get displayed in an AlertView.
     
     If you want to display a textfield inside an AlertView use the hasTextField property's closure.
     */
    public var textField: UITextField {
        return _textField
    }
    
    var style: HintStyle = .callout(.triangle)
    
    ///Use this callback property to retreive the actual displayed view. 
    public var hintView: ((_ view: UIView)->())?
    
    /**
     The entry and exit animation style. Exit style if the invert of the enry style. Ex: if you choose from top as an entry animation, the view will be dismissed sliding upward.
     */
    public var animationStyle: AnimationStyle = .fade(0.3)
    
    /**
     Actions available with you hint view. Adding an action adds a button in the view. One button takes the entire with, two buttons the width is halved and three actions or more the buttons simply get stacked
     */
    public var actions: [HintAction] = []
    
    ///Title applies only to alert views
    public var title: String?
    
    ///The message which gets displayed in the hint view
    public var message: String?
    
    ///The view's background color
    public var backgroundColor: UIColor? = .systemGray4
    
    ///By default the color is the same as the background color with an alpha value of 0.2
    public var buttonsColor: UIColor?
    
    ///By default set to label
    public var textColor: UIColor? = .label
    
    ///The margin between the targeted view and the hint view.
    public var marginFromView: CGFloat = 5
    
    ///The requested size of the hint view. Note that in the case of banners only the height is taken into acount. When banner have interactiveGesture enabled view 'expended' size of the view is computed automaticaly.
    public var size: CGSize = CGSize(width: 220, height: 60)
    
    ///The image to display on the left hand side of banners. Callouts don't support images.
    public var image: UIImage?
    
    /**
     An optionnal timeout which defines a life expectancy for the view. When time is up, the view dissapears automaticaly with no further user action.
     */
    public var timeOut: TimeInterval?
    
    /**
     Only apply to banners. Banners can hide their buttons and only reveal them upon a drag down on the view. Set this value to false if you want to see button by default.
     */
    public var enableInteractiveGestureForActions = true
       
    /**
    Only applies to alerts. Decide whether you want to display a textfield in the alert view. The callback gives you access to the textField on which you can assign a delegate .Default value for thhis parameter is false
     */
    public var hasTextField:((_ textField: UITextField)->Bool)? = { textField in
        false
    }
    
    /**
     Defines wether the hint view is modal or not. When set to true the user can't dismiss the view by tapping away.
     */
    public var isModal = false
    
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
        let buttonBaseHeight:CGFloat = K.getValue(for: .buttonsHeight)
        if actions.count == 0 {
            return self.size.height
        }else if actions.count == 2{
            return self.size.height + (enableInteractiveGestureForActions ? 0 : buttonBaseHeight + 10)
        }else{
            return self.size.height + (enableInteractiveGestureForActions ? 0 : CGFloat(actions.count - 1) * (buttonBaseHeight + 5) + (buttonBaseHeight + 10))
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
