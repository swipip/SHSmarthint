//
//  AlertViewTests.swift
//  SmartHintTests
//
//  Created by Gautier Billard on 18/02/2021.
//

import XCTest
@testable import SmartHint

class AlertViewTests: XCTestCase {

    var hint = Hint(style: .alert)
    lazy var builder = HintBuilder(hint: hint, hintRect: .zero, pointerHorizontalPosition: 0)
    
    func test_MemoryLeaks() {
        let sut = AlertView(builder)
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut)
        }
    }
    
    func test_backgroundColor() {
        hint.backgroundColor = .white
        let sut = AlertView(builder)
        XCTAssertEqual(sut.backgroundColor, .white)
    }
    
    func test_CornerRaidus() {
        let sut = AlertView(builder)
        XCTAssertEqual(sut.layer.cornerRadius, K.getValue(for: .hintViewCornerRadius))
    }
    
}
