//
//  ViewController.swift
//  TestApp
//
//  Created by Gautier Billard on 07/02/2021.
//

import UIKit
import SmartHint

class ViewController: UIViewController {

    weak var hint: Hint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tap)
     
        sh.setDefaultValue(CGFloat(12), forKey: .hintViewCornerRadius)
        sh.setDefaultValue(CGFloat(8), forKey: .buttonsCornerRadius)
        sh.setDefaultValue(CGFloat(300), forKey: .alertWidth)
        sh.setDefaultValue(CGFloat(20), forKey: .alertSpacing)
        sh.setDefaultValue(CGFloat(40), forKey: .buttonsHeight)
        
        let button = UIButton()
        button.frame = CGRect(x: 20, y: 300, width: 200, height: 35)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 5
        button.setTitle("tap me", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.center = view.center
        view.addSubview(button)
        
    }
    @objc func buttonPressed() {
        sh.forceCompletionOf(hint)
    }
    @objc func tapHandler() {
//        addBannerWithButton()
        addYellowBanner()
//        addAlert()
    }
    
    func addBanner() {
        guard let targetView = navigationController?.navigationBar else {return}
        sh.addHint(hint: Hint(style: .banner(.bottom), message: "Test"), to:targetView)
    }
    
    func addBannerWithButton() {
        guard let targetView = navigationController?.navigationBar else {return}
        let hint = Hint(style: .banner(.bottom), message: "what kind of prototyping /design software do you use for your drawings for iOS such as those above? Does one exist that allows you")
        hint.animationStyle = .fromTop(0.3)
        hint.textColor = .white
        hint.timeOut = 5
        hint.size.height = 70
        hint.enableInteractiveGestureForActions = true
        hint.backgroundColor = .systemOrange
        hint.image = UIImage(systemName: "pencil.tip.crop.circle")
        hint.addAction(HintAction(title: "callouts", handler: { [weak self] _ in
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
        let hint = Hint(style: .banner(.bottom))
        hint.message = "Hey this is a modal banner !"
        hint.addAction(HintAction(title: "Understood") { _ in
            self.sh.dismissAllHints(animated: true)
        })
        hint.image = UIImage(systemName: "info.circle.fill")
        hint.buttonsColor = UIColor.white.withAlphaComponent(0.3)
        hint.textColor = .white
        hint.backgroundColor = [.systemPink, .systemBlue, .systemTeal, .systemRed, .systemYellow][Int.random(in: 0...4)]
        hint.isModal = false
        hint.animationStyle = .fromTop(0.3)
        hint.enableInteractiveGestureForActions = true
        
        self.hint = hint
        sh.addHint(hint: hint, at: CGPoint(x: 0, y: 50)) {
            print("hint complete")
        }
    }
    func addAlert() {
        
        guard let target = navigationController?.navigationBar else {return}
        let hint = Hint(style: .alert)
        hint.image = UIImage(named: "man")
        hint.backgroundColor = .white
        hint.buttonsColor = .systemGray6
        hint.hasTextField = { [weak self] textField in
            textField.delegate = self
            textField.placeholder = "adresse email"
            textField.keyboardType = .emailAddress
            return true
        }
        hint.isModal = true
        hint.message = "Mot de passe oublié"
        hint.animationStyle = .fromBottom(0.3)
        hint.addAction(HintAction(title: "changer le mot de passe", handler: { hint in
            self.sh.dismissAllHints(animated: true)
            self.pushCalloutsController()
        }))
        sh.addHint(hint: hint, to: target)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
