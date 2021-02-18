//
//  ButtonCell.swift
//  SmartHint
//
//  Created by Gautier Billard on 07/02/2021.
//

import UIKit

class BannerViewButtonCell:UICollectionViewCell {
    static let identifier = "BannerViewButtonCell"
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = K.getValue(for: .buttonsCornerRadius)
        addMessageLabel()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addMessageLabel() {
        
        let childView: UIView = messageLabel
        let mView: UIView = self
        
        self.addSubview(childView)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [childView.leadingAnchor.constraint(equalTo: mView.leadingAnchor, constant: 0),
             childView.topAnchor.constraint(equalTo: mView.topAnchor, constant: 0),
             childView.bottomAnchor.constraint(equalTo: mView.bottomAnchor,constant: 0),
             childView.trailingAnchor.constraint(equalTo: mView.trailingAnchor,constant: 0)]
        )
        
    }
}
