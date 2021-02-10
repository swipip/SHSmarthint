//
//  ModalVC.swift
//  TestApp
//
//  Created by Gautier Billard on 07/02/2021.
//

import UIKit
import SmartHint

class ModalVC: UIViewController {
    
    // MARK: UI elements 􀯱
    
    // MARK: Data Management 􀤃
    
    // MARK: View life cycle 􀐰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        button.setImage(UIImage(systemName:"checkmark.circle.fill",withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(barButtonPressed(_ :)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        let button2 = UIButton()
        button2.setImage(UIImage(systemName:"checkmark.circle.fill",withConfiguration: config), for: .normal)
        button2.addTarget(self, action: #selector(barButtonPressed(_ :)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button2)
        
    }
    
    // MARK: Navigation 􀋒
    
    // MARK: Interactions 􀛹
    @IBAction func centerButtonPressed(_ sender: UIButton) {
        let hint = Hint(style: .callout(.triangle), message: "hello")
        sh.addHint(hint: hint, to: sender)
    }
    @objc func barButtonPressed(_ sender:UIButton) {
        
        let hint = Hint(style: .callout(.triangle), message: "hello")
        sh.addHint(hint: hint, to: sender)
        
    }
    // MARK: UI construction 􀤋
    
    // MARK: Tracking 􀬱
    
}
