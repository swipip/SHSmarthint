//
//  HintView.swift
//  SmartHint
//
//  Created by Gautier Billard on 27/02/2021.
//

import UIKit

protocol HintView: UIView {
    var messageLabel: UILabel {get set}
    var collectionView: UICollectionView {get set}
    var hint: Hint {get set}
    var didTapView:(()->())? {get set}
}
