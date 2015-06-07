//
//  CurrentGestureState.swift
//  BisectionViewController
//
//  Created by MiyakeAkira on 2015/06/07.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation
import SwiftyEvents

public typealias CurrentGestureState = _CurrentGestureState<CurrentGestureStateEvent, GestureState>

public enum CurrentGestureStateEvent {
    case WillSet
    case DidSet
}

public class _CurrentGestureState<E: Hashable, A>: EventEmitter<CurrentGestureStateEvent, GestureState> {
    
    // MARK: - Variables
    
    public var value: GestureState {
        willSet {
            emit(.WillSet, argument: value)
        }
        
        didSet {
            emit(.DidSet, argument: value)
        }
    }
    
    
    // MARK: - Initialize
    
    public override init() {
        value = .Ended
        
        super.init()
    }
    
}