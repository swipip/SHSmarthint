//
//  BannerView.swift
//  YMMHintManager
//
//  Created by Gautier Billard on 03/02/2021.
//

import UIKit

class BannerView: UIView, HintView, UIGestureRecognizerDelegate {
    
    // MARK: UI elements 􀯱
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    var imageViewWidthConstraint: NSLayoutConstraint?
    var imageViewCenterYConstraint: NSLayoutConstraint?
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 2
        label.isUserInteractionEnabled = false
        return label
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let collection = UICollectionView(frame: .zero ,collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        collection.delegate = self
        collection.dataSource = self
        collection.register(BannerViewButtonCell.self, forCellWithReuseIdentifier: BannerViewButtonCell.identifier)
        if hint.enableInteractiveGestureForActions {
            collection.alpha = 0
        }
        return collection
    }()
    var collectionViewHeightAnchor: NSLayoutConstraint?
    
    ///The offset to apply to the body of the banner if it has actions of not
    var bodyVerticalOffset:CGFloat {
        if hint.numberOfActions <= 2 {
            return K.getValue(for: .buttonsHeight)/2
        } else {
            return collectionViewHeight / 2
        }
    }

    var collectionViewHeight:CGFloat {
        let count = hint.actions.count
        var height: CGFloat = 0
        if count == 2 {
            height = 50
        }else{
            if hint.actions.count > 2 {
                collectionView.contentInset.bottom = 6
            }
            height = CGFloat(50 + (45) * (hint.actions.count - 1))
        }
        return hint.hasActions ? height : 0
    }
    var isCollectionViewVisible: Bool {
        return collectionView.alpha == 0 ? false : true
    }
    
    private lazy var defaultOrigin = self.frame.origin
    private lazy var compressionDistance:CGFloat = maxPan
    private let maxPan:CGFloat = 50
    
    // MARK: Data Management 􀤃
    var didExpandView:(()->())?
    var didTapView:(()->())?
    var didDismissView:(()->())?
    var hint: Hint
    // MARK: View life cycle 􀐰
    
    init(builder: HintBuilder) {
        self.hint = builder.hint
        super.init(frame: builder.hintRect)
        
        clipsToBounds = false
        layer.cornerRadius = K.getValue(for: .hintViewCornerRadius)
        backgroundColor = hint.backgroundColor
        
        addCollectionView()
        addImageView()
        addMessageLabel()
        addPanGesture()
        
        addTapGesture(to: self)
        let hint = builder.hint
        
        messageLabel.text = hint.message
        messageLabel.textColor = hint.textColor ?? .label
        imageView.tintColor = hint.textColor
        
        addImageViewIfNeeded(hint)
        displayActionsIfNeeded(hint)
        
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        self.layer.shadowColor = UIColor.systemGray4.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.5
    }
    
    // MARK: Interactions 􀛹
    @objc private func tapHandler(_ recognizer: UITapGestureRecognizer) {
        didTapView?()
    }
    private func addTapGesture(to view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    @objc private func panHandler(_  recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self).y
        recognizer.setTranslation(.zero, in: self)
        
        switch recognizer.state {
        case .changed:
            if self.frame.origin.y > (defaultOrigin.y + maxPan + translation) {
                compressionDistance += translation
                let coef = max(0.01,1 - compressionDistance/150)
                self.frame.origin.y += translation * coef
            }else{
                self.frame.origin.y += translation
            }
            break
        case .ended:
            compressionDistance = maxPan
            
            let animationSpeed: Double = K.getValue(for: .interactionAnimationSpeed)
            let bannerState = BannerState.getState(for: self, andDefaultOrigin: defaultOrigin)
            
            switch bannerState {
            case .origin:
                animateBackToOriginalPosition()
            case .expand(let expand):
                didExpandView?()
                if expand{
                    UIView.animate(withDuration: animationSpeed) {
                        self.frame.origin.y = self.defaultOrigin.y
                        self.frame.size.height = self.getBannerMaximumSize()
                        self.collectionView.alpha = 1
                        self.collectionViewHeightAnchor?.constant = self.collectionViewHeight
                        self.imageViewCenterYConstraint?.constant -= self.bodyVerticalOffset
                        self.layoutIfNeeded()
                    }
                    UIView.transition(with: messageLabel, duration: animationSpeed, options: .transitionCrossDissolve) {
                        self.messageLabel.numberOfLines = 0
                    }
                }else{
                    UIView.animate(withDuration: 0.2) {
                        self.frame.origin.y = self.defaultOrigin.y
                        self.frame.size.height = self.hint.height
                        self.collectionView.alpha = 0
                        self.collectionViewHeightAnchor?.constant = 0
                        self.imageViewCenterYConstraint?.constant += self.bodyVerticalOffset
                        self.layoutIfNeeded()
                    }
                    UIView.transition(with: messageLabel, duration: animationSpeed, options: .transitionCrossDissolve) {
                        self.messageLabel.numberOfLines = 2
                    }
                }
            case .dismiss:
                let velocity = recognizer.velocity(in: self).y
                let distance = min(-200,0.3 * velocity)
                UIView.animate(withDuration: animationSpeed) {
                    self.frame.origin.y += distance
                } completion: { [weak self] _ in
                    self?.didDismissView?()
                }
            }
        default:
            break
        }
        
    }
    private func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler( _:)))
        self.addGestureRecognizer(pan)
    }
    
    // MARK: Animations 􀢅
    func animateBackToOriginalPosition() {
        UIView.animate(withDuration: K.getValue(for: .interactionAnimationSpeed)) {
            self.frame.origin.y = self.defaultOrigin.y
        }
    }
    // MARK: UI construction 􀤋
    
    func getBannerMaximumSize() -> CGFloat {
        let messageLines = messageLabel.calculateMaxLines() + 1
        let lineHeight = messageLabel.font.lineHeight
        return (collectionViewHeight + CGFloat(messageLines) * lineHeight)
    }
    
    func displayActionsIfNeeded(_ hint: Hint) {
        if hint.enableInteractiveGestureForActions == false {
            layoutIfNeeded()
            messageLabel.numberOfLines = 0
            frame.size.height = getBannerMaximumSize()
        }
    }
    
    func addImageViewIfNeeded(_ hint: Hint) {
        if let image = hint.image {
            imageView.image = image
            imageViewWidthConstraint?.constant = min(40,frame.height * 0.5)
        }
    }
    
    private func addCollectionView() {
        
        let childView: UIView = collectionView
        let mView: UIView = self
        
        self.addSubview(childView)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [childView.leadingAnchor.constraint(equalTo: mView.leadingAnchor, constant: 0),
             childView.bottomAnchor.constraint(equalTo: mView.bottomAnchor,constant: 0),
             childView.trailingAnchor.constraint(equalTo: mView.trailingAnchor,constant: 0)]
        )
            
        let height = hint.enableInteractiveGestureForActions ? 0 : collectionViewHeight
        collectionViewHeightAnchor = childView.heightAnchor.constraint(equalToConstant: height)
        collectionViewHeightAnchor?.isActive = true
    }
    
    private func addImageView() {
        
        let childView: UIView = imageView
        let mView: UIView = self
        
        self.addSubview(childView)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        let yOffSet:CGFloat = (hint.hasActions && hint.enableInteractiveGestureForActions == false) ? -20 : 0
        
        NSLayoutConstraint.activate(
            [childView.leadingAnchor.constraint(equalTo: mView.leadingAnchor, constant: 10),
             childView.heightAnchor.constraint(equalToConstant: min(40,frame.height * 0.5))]
        )
        
        imageViewCenterYConstraint = childView.centerYAnchor.constraint(equalTo: mView.centerYAnchor, constant: yOffSet)
        imageViewCenterYConstraint?.isActive = true
        
        imageViewWidthConstraint = childView.widthAnchor.constraint(equalToConstant: frame.height * 0)
        imageViewWidthConstraint?.isActive = true
    }
    
    private func addMessageLabel() {
        
        let childView: UIView = messageLabel
        let mView: UIView = self
        
        self.addSubview(childView)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [childView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
             childView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0),
             childView.trailingAnchor.constraint(equalTo: mView.trailingAnchor,constant: -8)]
        )
        
    }
    
    // MARK: Recognizer delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if collectionView.frame.contains(touch.location(in: self)) && collectionView.alpha == 1{
            return false
        }
        return true
    }
    
}
extension BannerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hint.actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerViewButtonCell.identifier, for: indexPath) as! BannerViewButtonCell
        
        let action = hint.actions[indexPath.item]
        cell.messageLabel.text = action.title
        cell.messageLabel.textColor = hint.textColor
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width:CGFloat
        if hint.actions.count != 2 {
            width = (frame.width - 10)
        }else{
            width = (frame.width - 15)/2
        }
        return CGSize(width: width, height: K.getValue(for: .buttonsHeight))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = hint.actions[indexPath.item]
        action.handler?()
    }
    
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let label = UILabel(frame: CGRect(origin: .zero, size: maxSize))
        label.numberOfLines = 0
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let font = self.font ?? UIFont.systemFont(ofSize: 17)
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

enum BannerState {
    case origin
    case expand(Bool)
    case dismiss
    
    static func getState(for view: BannerView, andDefaultOrigin origin: CGPoint) -> BannerState {
        let currentVerticialPosition = view.frame.origin.y
        let hasActions = view.hint.hasActions
        if currentVerticialPosition < origin.y - 20 {
            return .dismiss
        }else if view.hint.enableInteractiveGestureForActions == false {
            return .origin
        }else if hasActions == false{
            return .origin
        }else if currentVerticialPosition > origin.y + 20  {
            var expand: Bool
            if view.isCollectionViewVisible == false && hasActions {
                expand = true
            }else{
                expand = false
            }
            return .expand(expand)
        }else{
            return .origin
        }
    }
}
