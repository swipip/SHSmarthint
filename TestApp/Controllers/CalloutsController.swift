//
//  CalloutsController.swift
//  TestApp
//
//  Created by Gautier Billard on 07/02/2021.
//

import UIKit
import SmartHint

class CalloutsController: UIViewController {
    
    // MARK: UI elements 􀯱
    
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    
    // MARK: Data Management 􀤃
    
    // MARK: View life cycle 􀐰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        button.setImage(UIImage(systemName:"checkmark.circle.fill",withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(barButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        print("callout deinit")
    }
    
    // MARK: Navigation 􀋒
    
    // MARK: Interactions 􀛹
    
    @objc private func barButtonPressed() {
        let hint = Hint(style: .callout(.triangle),message: "Bar button")
        hint.backgroundColor = .systemIndigo
        hint.textColor = .white
        sh.addHint(hint: hint, to: navigationItem.rightBarButtonItem!.customView!) {
            let vc = ModalVC(nibName: "ModalVC", bundle: nil)
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapViewOne(_ sender: UITapGestureRecognizer) {
        sh.dismissAllHints(animated: true)
        addCalloutTo(sender.view!)
    }
    func addCalloutTo(_ view: UIView) {
        let hint = Hint(style: .callout(.triangle),message: "Test")
        hint.addAction(HintAction(title: "voir", handler: { [weak self] in
            self?.sh.dismissAllHints(animated: true)
        }))
        hint.backgroundColor = .systemIndigo
        hint.textColor = .white
        
        sh.addHint(hint: hint, to: view) { [weak self] in
            self?.sh.dismissAllHints(animated: true)
        }
    }
    
    
    // MARK: UI construction 􀤋
    
    // MARK: Tracking 􀬱
    
}
