//
//  HintView.swift
//  YMMHintManager
//
//  Created by Gautier Billard on 03/02/2021.
//

import UIKit


internal class Callout: UIView, HintView {
    
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
        collection.alpha = 1
        return collection
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var collectionViewHeight:CGFloat {
        let count = hint.actions.count
        var height: CGFloat = 0
        if count == 0 {
            height = 0
        }else if count == 2 || count == 1{
            height = K.getValue(for: .buttonsHeight) + 10
        }else{
            if !triangleOnTop {
                collectionView.contentInset.bottom = 6
            }else{
                collectionView.contentInset.top = 6
            }
            let baseHeight:CGFloat = K.getValue(for: .buttonsHeight)
            height = baseHeight + 10 + (baseHeight + 5) * CGFloat((hint.actions.count - 1))
        }
        return height
    }
    
    var didTapView:(()->())?
    var hint: Hint
    private var hintColor: UIColor?
    private var shapeLayer: CAShapeLayer?
    private var triangleOnTop: Bool
    private var triangleHeight: CGFloat {
        self.bounds.height*0.1
    }
    
    init(with builder: HintBuilder) {
        self.triangleOnTop = builder.pointsUpward
        self.hint = builder.hint
        super.init(frame: builder.hintRect)
        
        let hint = builder.hint
        messageLabel.text = hint.message
        messageLabel.textColor = hint.textColor ?? .label
        hintColor = hint.backgroundColor
        
        applyShapeLayer(builder.pointerHorizontalPosition, triangleOnTop: triangleOnTop)
        
        addCollectionView()
        addMessageLabel()
        addTapGesture()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func tapHandler(_ recognizer:UITapGestureRecognizer) {
        didTapView?()
    }

    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    private func addCallOut(_ head: CGFloat,triangleOnTop: Bool) -> CGPath{
        let height = self.bounds.height - triangleHeight
        let minX = self.bounds.origin.x
        let minY = self.bounds.height - height
        let maxX = self.bounds.width
        let maxY = self.frame.height
        let head = max(25,min(maxX - 25, head))
        
        var rect:CGRect
        if !triangleOnTop {
            rect = CGRect(x: minX, y: minY, width: maxX, height: height)
        }else{
            rect = CGRect(x: minX, y: 0, width: maxX, height: height)
        }
        
        let cornerRadius: CGFloat = K.getValue(for: .hintViewCornerRadius)
        let path = CGMutablePath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        switch hint.style.associatedValue as! CallOutPointerStyle {
        case .triangle:
            if !triangleOnTop {
                path.move(to: CGPoint(x: minX, y: minY))
                path.addLine(to: CGPoint(x: head - 15, y: minY))
                path.addArc(tangent1End: CGPoint(x: head, y: 0), tangent2End: CGPoint(x: head + 15, y: minY), radius: min(5,cornerRadius))
                path.addLine(to: CGPoint(x: head + 15, y: minY))
                
            }else{
                path.move(to: CGPoint(x: minX, y: height))
                path.addLine(to: CGPoint(x: head - 15, y: height))
                path.addArc(tangent1End: CGPoint(x: head, y: maxY), tangent2End: CGPoint(x: head + 15, y: maxY), radius: min(5,cornerRadius))
                path.addLine(to: CGPoint(x: head + 15, y: height))
            }
        case .noPointer:
            break
        }
            
        return path
    }
    
    private func applyShapeLayer(_ head: CGFloat,triangleOnTop: Bool) {
        let path = addCallOut(head, triangleOnTop: triangleOnTop)
        shapeLayer = CAShapeLayer()
        shapeLayer?.fillColor = (hintColor ?? .white).cgColor
        shapeLayer?.path = path
        shapeLayer?.opacity = 1

        self.layer.addSublayer(shapeLayer!)
        
        addShadowToCallOut()
    }
    
    private func addShadowToCallOut() {
        self.layer.shadowPath = shapeLayer?.path
        self.layer.shadowColor = UIColor.systemGray4.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.5
    }
    
    private func addCollectionView() {
        
        let childView: UIView = collectionView
        let mView: UIView = self
        
        self.addSubview(childView)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [childView.leadingAnchor.constraint(equalTo: mView.leadingAnchor, constant: 0),
             childView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
             childView.trailingAnchor.constraint(equalTo: mView.trailingAnchor,constant: 0)]
        )
        
        if !triangleOnTop {
            childView.bottomAnchor.constraint(equalTo: mView.bottomAnchor,constant: 0).isActive = true
        }else{
            childView.topAnchor.constraint(equalTo: mView.topAnchor,constant: 0).isActive = true
        }
        
    }
    
    private func addMessageLabel() {
        
        let childView: UIView = messageLabel
        let mView: UIView = self
        
        self.addSubview(childView)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        var yOffset: CGFloat
        if !triangleOnTop {
            yOffset = 0 + triangleHeight/2 - collectionViewHeight/2
        }else{
            yOffset = 0 - triangleHeight/2 + collectionViewHeight/2
        }
        
        NSLayoutConstraint.activate(
            [childView.leadingAnchor.constraint(equalTo: mView.leadingAnchor, constant: 8),
             childView.centerYAnchor.constraint(equalTo: mView.centerYAnchor, constant: yOffset),
             childView.trailingAnchor.constraint(equalTo: mView.trailingAnchor,constant: -5)]
        )
        
    }
    
}

extension Callout: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hint.actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerViewButtonCell.identifier, for: indexPath) as! BannerViewButtonCell
        
        let action = hint.actions[indexPath.item]
        cell.messageLabel.text = action.title
        cell.messageLabel.textColor = hint.textColor
        cell.backgroundColor = hint.buttonsColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width:CGFloat
        if hint.actions.count == 2 {
            width = (collectionView.frame.width - 15)/2
        }else{
            width = collectionView.frame.width - 10
        }
        return CGSize(width: width, height: K.getValue(for: .buttonsHeight))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hint.actions[indexPath.row].handler?(hint)
    }
    
}

extension Callout :UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if collectionView.frame.contains(touch.location(in: self)) && collectionView.alpha == 1{
            return false
        }
        return true
    }
}
