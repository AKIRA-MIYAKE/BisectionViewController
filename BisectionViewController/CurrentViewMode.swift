//
//  CurrentViewMode.swift
//  BisectionViewController
//
//  Created by MiyakeAkira on 2015/06/07.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation
import SwiftyEvents

public typealias CurrentViewMode = _CurrentViewMode<CurrentViewModeEvent, ViewMode>

public enum CurrentViewModeEvent {
    case WillUpdate
    case DidUpdate
}

public class _CurrentViewMode<E: Hashable, A>: EventEmitter<CurrentViewModeEvent, ViewMode> {
    
    // MARK: - Variables
    
    public var value: ViewMode {
        willSet {
            if newValue != value {
                emit(.WillUpdate, argument: value)
            }
        }
        
        didSet {
            if oldValue != value {
                emit(.DidUpdate, argument: value)
            }
        }
    }
    
    
    // MARK: - Initialize
    
    public init(_ value: ViewMode) {
        self.value = value
    }
    
}