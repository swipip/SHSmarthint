//
//  AlertView.swift
//  SmartHint
//
//  Created by Gautier Billard on 18/02/2021.
//

import UIKit
import Combine
class AlertView: UIView, HintView {
    
    // MARK: UI elements 􀯱
    
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = K.getValue(for: .alertSpacing)
        return stack
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collection = UICollectionView(frame: .zero ,collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(BannerViewButtonCell.self, forCellWithReuseIdentifier: BannerViewButtonCell.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.isScrollEnabled = false
        return collection
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = hint.textColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = K.getValue(for: .titleFont)
        return label
    }()
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = hint.textColor
        label.font = K.getValue(for: .messageFont)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = hint.textColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: Data Management 􀤃
    var cancellables = Set<AnyCancellable>()
    static var shouldDisplayTextField = false
    var hint: Hint
    var didTapView: (() -> ())?
    var distanceForOrigin: CGFloat = 0
    // MARK: View life cycle 􀐰
    init(_ hintBuilder: HintBuilder) {
        self.hint = hintBuilder.hint
        super.init(frame: hintBuilder.hintRect)
        
        backgroundColor = hint.backgroundColor
        layer.cornerRadius = K.getValue(for: .hintViewCornerRadius)
        clipsToBounds = false
        
        imageView.image = hint.image
        titleLabel.text = hintBuilder.hint.title
        messageLabel.text = hintBuilder.hint.message
        collectionView.reloadData()
        
        addVStack()
        setUpVStack()
        
        addTapGesture()
        
        NotificationCenter.Publisher.init(center: .default, name: UIResponder.keyboardWillShowNotification)
            .sink { [unowned self] (notification) in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.distanceForOrigin = self.frame.origin.y
                    self.frame.origin.y = frame.origin.y - 10 - self.frame.size.height
                    self.distanceForOrigin -= self.frame.origin.y
                }
            }.store(in: &cancellables)
        NotificationCenter.Publisher.init(center: .default, name: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] (notification) in
                self?.frame.origin.y += (self?.distanceForOrigin ?? 0)
            }.store(in: &cancellables)
        
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.systemGray4.cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.6
    }
    // MARK: Navigation 􀋒
    
    // MARK: Interactions 􀛹
    @objc private func tapHandler() {
        didTapView?()
    }
    // MARK: Animations 􀢅
    
    // MARK: UI construction 􀤋
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    func calculateCollectionViewHeight() -> CGFloat{
        45
    }
    private func setUpVStack() {
        if hint.title != nil {
            vStack.addArrangedSubview(titleLabel)
        }
        if hint.image != nil {
            imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            vStack.addArrangedSubview(imageView)
        }
        if hint.message != nil {
            vStack.addArrangedSubview(messageLabel)
        }
        if AlertView.shouldDisplayTextField {
            hint.textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
            vStack.addArrangedSubview(hint.textField)
        }
        if hint.hasActions {
            vStack.addArrangedSubview(collectionView)
        }
    }
    private func addVStack() {
        
        let childView: UIView = vStack
        let mView: UIView = self
        
        self.addSubview(childView)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [childView.leadingAnchor.constraint(equalTo: mView.leadingAnchor, constant: 10),
             childView.topAnchor.constraint(equalTo: mView.topAnchor, constant: K.getValue(for: .alertSpacing)),
             childView.bottomAnchor.constraint(equalTo: mView.bottomAnchor,constant: -K.getValue(for: .alertSpacing)),
             childView.trailingAnchor.constraint(equalTo: mView.trailingAnchor,constant: -10)]
        )
        
    }
    
}

extension AlertView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hint.numberOfActions
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerViewButtonCell.identifier, for: indexPath) as! BannerViewButtonCell
        cell.messageLabel.text = hint.actions[indexPath.item].title
        cell.messageLabel.textColor = hint.textColor
        cell.backgroundColor = hint.buttonsColor ?? UIColor.white.withAlphaComponent(0.2)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: K.getValue(for: .buttonsHeight))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hint.actions[indexPath.item].handler?(hint)
    }
}
extension AlertView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if collectionView.frame.contains(touch.location(in: self)) && collectionView.alpha == 1{
            return false
        }
        return true
    }
}
// MARK: Helpers
extension AlertView {
    static func getHestimatedHeight(_ hint: Hint) -> CGFloat{
        let instance = AlertView(HintBuilder(hint: hint, hintRect: .zero, pointerHorizontalPosition: 0))
        let alertWidth:CGFloat = K.getValue(for: .alertWidth) - 20
        
        var messageHeight:CGFloat = 0
        var collectionViewHeight: CGFloat = 0
        var titleHeight: CGFloat = 0
        var textFieldHeight: CGFloat = 0
        
        instance.titleLabel.frame = CGRect(x: 0, y: 0, width: alertWidth, height: CGFloat.infinity)
        instance.titleLabel.text = hint.title
        if hint.title != nil {
            titleHeight = CGFloat(instance.titleLabel.calculateMaxLines())*instance.titleLabel.font.lineHeight
        }
        
        instance.messageLabel.frame = CGRect(x: 0, y: 0, width: alertWidth, height: CGFloat.infinity)
        instance.messageLabel.text = hint.message
        if hint.message != nil {
            messageHeight = CGFloat(instance.messageLabel.calculateMaxLines())*instance.messageLabel.font.lineHeight
        }

        if (hint.hasTextField?(hint.textField) ?? false) {
            textFieldHeight = 50
            shouldDisplayTextField = true
        }else{
            shouldDisplayTextField = false
        }
        
        if hint.hasActions {
            let buttonHeight: CGFloat = K.getValue(for: .buttonsHeight) + 5
            collectionViewHeight = CGFloat(hint.numberOfActions) * buttonHeight - 5
        }
        let imageHeight:CGFloat = hint.image == nil ? 0 : 50
        let height = messageHeight + titleHeight + (K.getValue(for: .alertSpacing) * 2) + collectionViewHeight + imageHeight + textFieldHeight
        
        
        let numberOfItems = (hint.title != nil ? 1 : 0) +
                            (hint.message != nil ? 1 : 0) +
                            (hint.image != nil ? 1 : 0) +
                            (hint.hasActions ? 1 : 0) +
                            (textFieldHeight > 0 ? 1 : 0)
        let margins: CGFloat = K.getValue(for: .alertSpacing) * CGFloat((numberOfItems - 1))
        
        return height + margins
    }
}

extension AlertView {
    
}
