//
//  ViewController.swift
//  TestApp
//
//  Created by Gautier Billard on 07/02/2021.
//

import UIKit
import SmartHint

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tap)
        
    }
    @objc func tapHandler() {
//        addBannerWithButton()
        addYellowBanner()
    }
    
    func addBanner() {
        guard let targetView = navigationController?.navigationBar else {return}
        sh.addHint(hint: Hint(style: .banner(.bottom), message: "Test"), to:targetView)
    }
    
    func addBannerWithButton() {
        guard let targetView = navigationController?.navigationBar else {return}
        let hint = Hint(style: .banner(.bottom), message: "what kind of prototyping /design software do you use for your drawings for iOS such as those above? Does one exist that allows you")
        hint.animationStyle = .fromTop
        hint.textColor = .white
        hint.timeOut = 5
        hint.size.height = 70
        hint.enableInteractiveGestureForActions = true
        hint.backgroundColor = .systemOrange
        hint.image = UIImage(systemName: "pencil.tip.crop.circle")
        hint.addAction(HintAction(title: "callouts", handler: { [weak self] in
            self?.sh.dismissAllHints(animated: true)
            self?.pushCalloutsController()
        }))
        sh.setDefaultValue(CGFloat(10),forKey: .hintViewCornerRadius)
        sh.setDefaultValue(CGFloat(8),forKey: .buttonsCornerRadius)
        sh.addHint(hint: hint, to:targetView) {
            
        }
    }
    
    func pushCalloutsController() {
        let vc = CalloutsController(nibName: "CalloutsController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

    func addYellowBanner() {
        sh.setDefaultValue(CGFloat(12), forKey: .hintViewCornerRadius)
        sh.setDefaultValue(CGFloat(8), forKey: .buttonsCornerRadius)
        let hint = Hint(style: .alert)
        hint.backgroundColor = .white
        hint.buttonsColor = .systemGray6
//        hint.image = UIImage(systemName: "checkmark.circle.fill")
        hint.title = "Recette ajoutée au menu en cours"
        hint.message = "Tu viens d'ajouter la recette à ton menu en cours. Retrouve là à tout moment dans l'éditeur."
        hint.animationStyle = .fromTop
        hint.addAction(HintAction(title: "voir", handler: {
            self.sh.dismissAllHints(animated: true)
            self.addBannerWithButton()
        }))
//        hint.addAction(HintAction(title: "test", handler: {
//            self.sh.dismissAllHints(animated: true)
//            self.addBannerWithButton()
//        }))
        sh.addHint(hint: hint, at: .zero)
    }
    
}

