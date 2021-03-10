//
//  SmartHint.swift
//  YMMHintManager
//
//  Created by Gautier Billard on 04/02/2021.
//

import UIKit

public class SmartHint {
    var identifier: String = UUID().uuidString
    static var instances: [SmartHint] = [] {
        didSet {
            instances.filter({$0.controller == nil}).forEach { (instance) in
                instance.removeHint(instance)
            }
        }
    }
    
    private var modalController: UIViewController?
    weak var controller: UIViewController?
    
    init(_ controller: UIViewController) {
        self.controller = controller
    }
    
    private (set) var autoDimissTimer: Timer?
    private (set) var targetPoint: CGPoint?
    var hintView: HintView?
    private (set) var hint: Hint?
    private var hintTapped:(()->())?
    private let animationSpeed: Double = K.getValue(for: .showAnimationSpeed)
    // MARK: Hint view life cycle
    
    private func addModalLayerIfNeeded(_ completion: @escaping()->()) {
        guard hint?.isModal ?? false else {completion();return}
        let vc = UIViewController()
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: false, completion: {
            self.modalController = vc
            completion()
        })
        
    }
    
    fileprivate func addHintToController(_ view: UIView) {
        let controller = modalController == nil ? self.controller : modalController
        var controllerView: UIView
        if let nav = controller?.navigationController {
            controllerView = nav.view
        }else{
            controllerView = controller?.view ?? UIView()
        }
        controllerView.addSubview(view)
    }
    
    fileprivate func show(hint: Hint, _ view: UIView, animated: Bool, delay: Double) {
        guard animated == true else {
            view.alpha = 1
            return}
        let offset: CGPoint =  CGPoint(x: view.frame.width + hint.marginFromView, y: view.frame.height)
        switch hint.animationStyle {
        case .noAnimation:
            view.alpha = 1
        case .fade:
            UIView.animate(withDuration: animationSpeed) {
                view.alpha = 1
            }
        case .slideLeft:
            view.transform = CGAffineTransform(translationX: -offset.x, y: 0)
        case .slideRight:
            view.transform = CGAffineTransform(translationX: +offset.x, y: 0)
        case .fromTop:
            view.transform = CGAffineTransform(translationX: 0, y: -offset.y)
        case .fromBottom:
            view.transform = CGAffineTransform(translationX: 0, y: +offset.y)
        }
        
        UIView.animate(withDuration: animationSpeed) {
            view.transform = .identity
            view.alpha = 1
        }
    }
    
    private func dismissHint(_ view: HintView, animated: Bool,enforceStyle: AnimationStyle? = nil, delayAlpha: Bool = false,_ completion:(()->())? = nil) {
        if animated == false {
            removeHint(self)
            self.modalController?.dismiss(animated: false, completion: nil)
        }else{
            if let hint = hint {
                var offset:CGPoint = .zero
                let style = enforceStyle == nil ? hint.animationStyle : enforceStyle
                switch style {
                case .fromTop:
                    offset = CGPoint(x: 0, y: -(hint.size.height + hint.marginFromView))
                case .fromBottom:
                    offset = CGPoint(x: 0, y: (hint.size.height + hint.marginFromView))
                case .slideLeft:
                    offset = CGPoint(x: -(view.frame.width + hint.marginFromView), y: 0)
                case .slideRight:
                    offset = CGPoint(x: (view.frame.width + hint.marginFromView), y: 0)
                case .noAnimation:
                    view.alpha = 0
                    self.modalController?.dismiss(animated: false, completion: nil)
                    completion?()
                default:
                    UIView.animate(withDuration: animationSpeed) {
                        view.alpha = 0
                    } completion: { (_) in
                        self.modalController?.dismiss(animated: false, completion: nil)
                        completion?()
                    }
                    return
                }
                
                UIView.animate(withDuration: animationSpeed) {
                    view.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                    if delayAlpha == false {
                        view.alpha = 0
                    }
                } completion: { (_) in
                    if delayAlpha == false {
                        self.modalController?.dismiss(animated: false, completion: nil)
                        completion?()
                    }
                }
                if delayAlpha {
                    UIView.animate(withDuration: animationSpeed, delay: 0.2) {
                        view.alpha = 0
                    } completion: { _ in
                        self.modalController?.dismiss(animated: false, completion: nil)
                        completion?()
                    }
                }
            }
        }
        
    }
    
    // MARK: Hint construction

    private func getBanner(_ hint: Hint,to target: UIView? = nil, at targetPoint: CGPoint? = nil) -> HintBuilder? {
        
        guard let position = hint.style.associatedValue as? BannerPosition else {return nil}
        
        var origin: CGPoint = CGPoint(x: hint.marginFromView, y: 0)
        
        if let target = target {
            let targetOrigin = target.getAsboluteOriginPoint(relativeTo: controller?.view ?? UIView())
            switch position {
            case .bottom:
                origin.y = targetOrigin.y + target.frame.height + hint.marginFromView
            case .top:
                origin.y = targetOrigin.y - hint.height - hint.marginFromView
            }
        }else if let targetPoint = targetPoint{
            switch position {
            case .bottom:
                origin.y = targetPoint.y + hint.marginFromView
            case .top:
                origin.y = targetPoint.y - hint.height - hint.marginFromView
            }
        }
        
        let width = UIScreen.main.bounds.size.width - hint.marginFromView*2
        let rect = CGRect(origin: origin, size: CGSize(width: width, height: hint.height))
        return HintBuilder(hint: hint, hintRect: rect, pointerHorizontalPosition: 0)
    }
    
    private func getCallout(_ hint: Hint,to target: UIView? = nil, at targetPoint: CGPoint? = nil) -> HintBuilder? {
        var viewIsDisplayedAtTheBottomOfTheScreen = false
        
        var targetBottomAnchor: CGPoint = .zero
        var triangleHeadXPoint: CGFloat = .zero
        let screenBounds = UIScreen.main.bounds
        var targetOrigin: CGPoint = .zero
        
        if let target = target {
            targetOrigin = target.getAsboluteOriginPoint(relativeTo: controller?.view ?? UIView())
            targetBottomAnchor = CGPoint(x: targetOrigin.x, y: targetOrigin.y + target.frame.size.height + hint.marginFromView)
            triangleHeadXPoint = target.frame.width / 2
        }else if let targetPoint = targetPoint {
            triangleHeadXPoint = hint.size.width / 2
            targetBottomAnchor = CGPoint(x: targetPoint.x - (hint.size.width / 2) , y: targetPoint.y + hint.marginFromView)
        }
        
        ///Triangle head is not centered
        if triangleHeadXPoint < 25 {
            targetBottomAnchor.x -= (25 - triangleHeadXPoint)
        }
        
        ///hint is offsetted on the trailling
        if targetBottomAnchor.x + hint.size.width > (screenBounds.width - 5) {
            let currentOffset = targetBottomAnchor.x + hint.size.width - screenBounds.width
            targetBottomAnchor.x -= (currentOffset + 5)
            if let target = target {
                triangleHeadXPoint = targetOrigin.x + target.frame.width/2 - targetBottomAnchor.x
            }else{
                triangleHeadXPoint = targetOrigin.x + (currentOffset + 5)
            }
            
        }
        
        ///hint is offsetted on the leading
        if targetBottomAnchor.x < 5 {
            targetBottomAnchor.x = 5
            triangleHeadXPoint = targetOrigin.x + (target?.frame.width ?? 0)/2 - targetBottomAnchor.x
        }
        
        ///hint view is outside screen bounds at the bottom
        if targetBottomAnchor.y + hint.size.height > screenBounds.height {
            targetBottomAnchor.y = targetOrigin.y - hint.height - hint.marginFromView
            viewIsDisplayedAtTheBottomOfTheScreen = true
        }
        
        let actions = hint.actions.count
        var additionnalHeight: CGFloat = 0
        if actions == 1 {
            additionnalHeight = 50
        }else if actions == 2 {
            additionnalHeight = 50
        }else if actions > 0 {
            additionnalHeight = CGFloat(50 + (actions - 1) * 45)
        }
        let height = hint.actions.count > 0 ? hint.size.height + additionnalHeight : hint.size.height
        
        let rect = CGRect(x: targetBottomAnchor.x, y: targetBottomAnchor.y, width: hint.size.width, height: height)
        
        return HintBuilder(hint: hint,hintRect: rect, pointsUpward: viewIsDisplayedAtTheBottomOfTheScreen, pointerHorizontalPosition: triangleHeadXPoint)
        
    }
    
    private func setUpHint(hint: Hint, to target: UIView?, at targetPoint: CGPoint?) {
        self.hint = hint
        
        var view: HintView?
        var delayForDismissalOfExisting: Double = 0
        
        switch hint.style {
        case .banner:
            guard let builder = getBanner(hint, to: target,at: targetPoint) else {return}
            view = BannerView(builder: builder)
            (view as! BannerView).didDismissView = {[weak self] in
                self?.dismissHint(view!, animated: true)
            }
        case .callout:
            let hint = hint
            hint.enableInteractiveGestureForActions = false
            guard let builder = getCallout(hint, to: target,at: targetPoint) else {return}
            view = Callout(with: builder)
        case .alert:
            guard let controller = controller else {return}
            let width:CGFloat = K.getValue(for: .alertWidth) - 20
            let height = AlertView.getHestimatedHeight(hint)
            let xOrigin = (controller.view.frame.width - width)/2
            let yOrigin = (controller.view.frame.height - height)/2
            let builder = HintBuilder(hint: hint, hintRect: CGRect(x: xOrigin, y: yOrigin, width: width, height: height), pointerHorizontalPosition: 0)
            view = AlertView(builder)
        }

        guard let safeView = view else {return}
        
        hint.hintView?(safeView)
        
        if let existingBanner = checkForExistingHintView(safeView.frame) {
            delayForDismissalOfExisting = 0.1
            guard let view = existingBanner.hintView else {return}
            dismissHint(view,
                        animated: true,
                        enforceStyle: hint.animationStyle.reversed,
                        delayAlpha: true) { [weak self,weak existingBanner] in
                
                    self?.removeHint(existingBanner)
                
            }
        }
        
        safeView.accessibilityIdentifier = UUID().uuidString
        safeView.alpha = 0
        
        hintView = safeView
        
        addModalLayerIfNeeded() {
            self.addHintToController(safeView)
            self.show(hint: hint, safeView, animated: true,delay: delayForDismissalOfExisting)
            self.addAutomaticDismissalIfNeeded(hint, view: safeView)
        }
        
        safeView.didTapView = { [weak self] in
            self?.hintTapped?()
            guard let view = self?.hintView else {return}
            self?.dismissHint(view, animated: true) { [weak self] in
                self?.removeHint(self)
            }
        }
        
    }
    
    private func addAutomaticDismissalIfNeeded(_ hint: Hint, view: HintView) {
        guard let timeOut = hint.timeOut else {return}
        autoDimissTimer = Timer.scheduledTimer(withTimeInterval: timeOut, repeats: false) { [weak self] (_) in
            self?.autoDimissTimer?.invalidate()
            self?.dismissHint(view,animated: true) { [weak self] in
                self?.removeHint(self)
            }
        }
        if let view = view as? BannerView {
            view.didExpandView = { [weak self] in
                self?.autoDimissTimer?.invalidate()
            }
        }
    }
    
    private func checkForExistingHintView(_ rect: CGRect) -> SmartHint? {
        let instances = SmartHint.instances
        for instance in instances {
            if instance.hintView?.frame.origin == rect.origin {
                let instance = SmartHint.instances.filter({$0.hintView?.accessibilityIdentifier == instance.hintView?.accessibilityIdentifier}).first
                instance?.autoDimissTimer?.invalidate()
                return instance
            }
        }
        return nil
    }
    
    private func removeHint(_ instance: SmartHint?) {
        instance?.hintView?.removeFromSuperview()
        instance?.hintView = nil
        SmartHint.instances.removeAll { [weak instance] (shInstance) -> Bool in
            if shInstance.identifier == instance?.identifier {
                return true
            }else{
                return false
            }
        }
    }
    
    // MARK: Interface
    
    public func setDefaultValue(_ value: Any, forKey key: ConstantName) {
        K.setValue(value, forKey: key)
    }
    
    public func addHint(hint: Hint, at targetPoint: CGPoint, _ tapped: (()->())? = nil) {
        setUpHint(hint: hint, to: nil, at: targetPoint)
        hintTapped = {tapped?()}
    }
    
    public func addHint(hint: Hint, to target: UIView, _ tapped: (()->())? = nil) {
        setUpHint(hint: hint, to: target, at: nil)
        hintTapped = {tapped?()}
    }
    
    public func dismissAllHints(animated: Bool) {
        SmartHint.instances.forEach { (instance) in
            guard let view = instance.hintView else {return}
            view.hint.textField.resignFirstResponder()
            instance.dismissHint(view,animated: animated) { [weak self] in
                self?.removeHint(self)
            }
        }
        SmartHint.instances.removeAll()
    }
    
}

public extension UIViewController {
    
    var sh: SmartHint {
        let instance = SmartHint(self)
        SmartHint.instances.append(instance)
        return instance
    }
    
}

extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

extension UIView {
    func getAsboluteOriginPoint(relativeTo view: UIView) -> CGPoint {
    
        let origin = self.superview?.convert(self.frame.origin, to: view) ?? .zero
        let x = origin.x
        let y = origin.y
        
        let point = CGPoint(x: x, y: y)
        
        return point
    }
    func getAsboluteOriginPoint() -> CGPoint {
        var topMostView = self.superview
        
        while topMostView?.superview != nil {
            topMostView = topMostView?.superview
        }
        
        let origin = self.superview?.convert(self.frame.origin, to: topMostView) ?? .zero
        let center = self.superview?.convert(self.center, to: topMostView) ?? .zero
        let x = origin.x
        let y = center.y
        
        let point = CGPoint(x: x, y: y)
        
        return point
    }
}
