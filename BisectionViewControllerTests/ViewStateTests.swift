//
//  ViewStateTests.swift
//  BisectionViewController
//
//  Created by MiyakeAkira on 2015/08/14.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import UIKit
import XCTest
import BisectionViewController

class ViewStateTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewStateEmitter() {
        let ea = expectationWithDescription("Emitter")
        let eb = expectationWithDescription("Emitter")
        
        let state = ViewState(displayState: .Both)
        
        state.emitter.on(.DidSetDisplayState) { (viewState) -> Void in
            ea.fulfill()
            XCTAssertEqual(viewState.displayState, DisplayState.Primary)
        }
        
        state.emitter.on(.DidSetGestureState) { (viewState) -> Void in
            eb.fulfill()
            XCTAssertEqual(viewState.gestureState, GestureState.Began)
        }
        
        state.displayState = DisplayState.Primary
        state.gestureState = GestureState.Began
        
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }

}
