//
//  SmartHintTests.swift
//  SmartHintTests
//
//  Created by Gautier Billard on 10/02/2021.
//

import XCTest
@testable import SmartHint

class SmartHintTests: XCTestCase {

    func test_ClearInstances() {
        
        let controller = UIViewController()
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        controller.view.addSubview(subView)
        
        for i in 1...10 {
            subView.frame.origin.x = CGFloat(i*10)
            let hint = Hint(style: .callout(.triangle))
            controller.sh.addHint(hint: hint, to: subView)
            let instances = SmartHint.instances
            XCTAssertEqual(instances.count, i)
        }
        
        controller.sh.dismissAllHints(animated: false)
        
        XCTAssertEqual(SmartHint.instances.count, 0)
    
        addTeardownBlock { [weak controller] in
            XCTAssertNil(controller)
        }
        
    }

}
