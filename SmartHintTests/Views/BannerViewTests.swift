//
//  BannerViewTests.swift
//  SmartHintTests
//
//  Created by Gautier Billard on 07/02/2021.
//

import XCTest
@testable import SmartHint

class BannerViewTests: XCTestCase {

    let hint = Hint(style: .banner(.top))
    lazy var builder = HintBuilder(hint: hint, hintRect: CGRect(x: 0, y: 0, width: 100, height: 100), pointerHorizontalPosition: 50)
    
    func test_MemoryLeak() {
        hint.actions.append(HintAction(title: "", handler: { _ in
            //
        }))
        let sut = BannerView(builder: builder)
        sut.didTapView = { [weak sut] in
            print(sut as Any)
        }
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut)
        }
    }
    
    func test_ButtonDefaultColor() {
        hint.backgroundColor = .orange
        hint.addAction(HintAction(title:""))
        let sut = BannerView(builder: builder)
        
        let cell = sut.collectionView(sut.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! BannerViewButtonCell
        
        XCTAssertNotNil(cell.backgroundColor)
    }
    
    func test_ButtonsColor() {
        hint.buttonsColor = .orange
        hint.addAction(HintAction(title: ""))
        let sut = BannerView(builder: builder)
        
        let cell = sut.collectionView(sut.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! BannerViewButtonCell
        
        XCTAssertEqual(cell.backgroundColor, hint.buttonsColor )
    }
    
    func test_contentOffSetValue() {
        let sut = BannerView(builder: builder)
        
        XCTAssertEqual(sut.bodyVerticalOffset, 20)
        
        sut.hint.addAction(HintAction(title: "", handler: nil))
        sut.hint.addAction(HintAction(title: "", handler: nil))
        sut.hint.addAction(HintAction(title: "", handler: nil))
        
        XCTAssertEqual(sut.bodyVerticalOffset, 70)
    }
    
    func test_CollectionViewShouldAppear() {
        hint.addAction(HintAction(title: "ok", handler: {_ in}))
        
        let sut = BannerView(builder: builder)
        
        XCTAssertTrue(sut.hint.hasActions)
    }
    
    func test_ShouldDisplayActions() {
        
        let hint = Hint(style: .banner(.top))
        hint.enableInteractiveGestureForActions = true
        let sut = BannerView(builder: builder)
        
        sut.displayActionsIfNeeded(hint)
        XCTAssertEqual(sut.messageLabel.numberOfLines, 2)
        
        hint.enableInteractiveGestureForActions = false
        sut.displayActionsIfNeeded(hint)
        XCTAssertEqual(sut.messageLabel.numberOfLines, 0)
        
    }
    
    func test_CollectionViewShouldnotAppear() {
        let sut = BannerView(builder: builder)
        
        XCTAssertFalse(sut.hint.hasActions)
    }
    
    func test_bannerState() {
        var state: BannerState = .origin
        
        let sutOne = BannerView(builder: builder)
        state =  BannerState.getState(for: sutOne, andDefaultOrigin: .zero)
        
        switch state {
        case .origin:
            break
        default:
            XCTFail("case: \(state)")
        }
        
        hint.addAction(HintAction(title: ""))
        let sutTwo = BannerView(builder: builder)
        sutTwo.frame = CGRect(x: 0, y: 30, width: 200, height: 100)
        state =  BannerState.getState(for: sutTwo, andDefaultOrigin: .zero)
        
        switch state {
        case .expand(let on):
            XCTAssertTrue(on)
        default:
            XCTFail("case: \(state)")
        }
        
        sutTwo.collectionView.alpha = 1
        sutTwo.frame = CGRect(x: 0, y: 30, width: 200, height: 100)
        state =  BannerState.getState(for: sutTwo, andDefaultOrigin: .zero)
        
        switch state {
        case .expand(let on):
            XCTAssertFalse(on)
        default:
            XCTFail("case: \(state)")
        }
        
        sutTwo.frame = CGRect(x: 0, y: 10, width: 200, height: 100)
        state =  BannerState.getState(for: sutTwo, andDefaultOrigin: .zero)
        
        switch state {
        case .origin:
            break
        default:
            XCTFail("case: \(state)")
        }
        
        sutTwo.frame = CGRect(x: 0, y: -30, width: 200, height: 100)
        state =  BannerState.getState(for: sutTwo, andDefaultOrigin: .zero)
        
        switch state {
        case .dismiss:
            break
        default:
            XCTFail("case: \(state)")
        }
        
        hint.enableInteractiveGestureForActions = false
        let sutThree = BannerView(builder: builder)
        sutThree.frame = CGRect(x: 0, y: 30, width: 200, height: 100)
        state =  BannerState.getState(for: sutThree, andDefaultOrigin: .zero)
        
        switch state {
        case .origin:
            break
        default:
            XCTFail("case: \(state)")
        }
        
    }
    
    func test_ImageViewWidthConstraint() {
        
        let hint = Hint(style: .banner(.top))
        
        let sut = BannerView(builder: builder)
        sut.addImageViewIfNeeded(hint)
        XCTAssertEqual(sut.imageViewWidthConstraint?.constant, 0)
        
        hint.image = UIImage()
        sut.addImageViewIfNeeded(hint)
        XCTAssertEqual(sut.imageViewWidthConstraint?.constant, 40)
    }
    
    func test_NumberOfButtons() {
        hint.addAction(HintAction(title: "message", handler: {_ in}))
        let sut = BannerView(builder: builder)
        XCTAssertEqual(sut.collectionView.numberOfItems(inSection: 0), 1)
    }
    
    func test_CollectionViewHeight() {
        
        let sutZeroAction = BannerView(builder: builder)
        XCTAssertEqual(sutZeroAction.collectionViewHeight, 0)
        
        hint.addAction(HintAction(title: "", handler: nil))
    
        let sutOneAction = BannerView(builder: builder)
        XCTAssertEqual(sutOneAction.collectionViewHeight, 50)
        
        hint.addAction(HintAction(title: "", handler: nil))
        
        let sutTwoActions = BannerView(builder: builder)
        XCTAssertEqual(sutTwoActions.collectionViewHeight, 50)
        
        hint.addAction(HintAction(title: "", handler: nil))
        
        let sutThreeActions = BannerView(builder: builder)
        XCTAssertEqual(sutThreeActions.collectionViewHeight, 140)
    }
}
