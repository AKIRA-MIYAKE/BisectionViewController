//
//  BisectionViewController.swift
//  BisectionViewController
//
//  Created by MiyakeAkira on 2015/06/07.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import UIKit
import SwiftyEvents


public enum DisplayState {
    case Both
    case Primary
    case Secondary
}


public enum GestureState {
    case Began
    case Changed
    case Ended
}


public enum ViewStateEvent {
    case DidSetDisplayState
    case DidSetGestureState
}

public class ViewState {
    
    // MARK: - let
    
    public let emitter = EventEmitter<ViewStateEvent, ViewState>()
    
    
    // MARK: - Variables
    
    public var displayState: DisplayState {
        didSet {
            emitter.emit(.DidSetDisplayState, value: self)
        }
    }
    
    public var gestureState: GestureState {
        didSet {
            emitter.emit(.DidSetGestureState, value: self)
        }
    }
    
    
    // MARK: - Initialize
    
    public init(displayState: DisplayState) {
        self.displayState = displayState
        
        gestureState = GestureState.Ended
    }
    
}


public class BisectionViewController: UIViewController {
    
    // MARK: - let
    
    public let viewState: ViewState
    
    
    // MARK: - Variables
    
    public var primaryViewController: UIViewController {
        didSet {
            removeChildViewController(oldValue)
            setupChildViewController(primaryViewController)
        }
    }
    
    public var secondaryViewController: UIViewController {
        didSet {
            removeChildViewController(oldValue)
            setupChildViewController(secondaryViewController)
        }
    }
    
    
    private var isInitialized: Bool
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var panGestureTranslation: CGPoint
    
    
    // MARK: - Initialize
    
    public init(
        primaryViewController: UIViewController,
        secondaryViewController: UIViewController,
        displayState: DisplayState)
    {
        viewState = ViewState(displayState: .Both)
        
        self.primaryViewController = primaryViewController
        self.secondaryViewController = secondaryViewController
        
        isInitialized = false
        
        panGestureTranslation = CGPointZero
        
        
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View controller
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildViewController(primaryViewController)
        setupChildViewController(secondaryViewController)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGestureRecognizer:")
        panGestureRecognizer.map { view.addGestureRecognizer($0) }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isInitialized {
            layoutChildViews(displayState: viewState.displayState, animated: false)
            isInitialized = true
        }
    }
    
    
    // MARK: - Private method
    
    private func setupChildViewController(controller: UIViewController) {
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
    private func removeChildViewController(controller: UIViewController) {
        controller.willMoveToParentViewController(nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    private func layoutChildViews(#displayState: DisplayState, animated: Bool) {
        let width: CGFloat = view.frame.size.width
        let height: CGFloat = view.frame.size.height
        
        let primaryViewFrame: CGRect
        let secondaryViewFrame: CGRect
        
        switch displayState {
        case .Both:
            primaryViewFrame = CGRectMake(0, 0, width, height / 2)
            secondaryViewFrame = CGRectMake(0, height / 2, width, height / 2)
        case .Primary:
            primaryViewFrame = CGRectMake(0, 0, width, height)
            secondaryViewFrame = CGRectMake(0, height, width, 0)
        case .Secondary:
            primaryViewFrame = CGRectMake(0, 0, width, 0)
            secondaryViewFrame = CGRectMake(0, 0, width, height)
        }
        
        if animated {
            UIView.animateWithDuration(
                0.5,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.3,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: { () -> Void in
                    self.primaryViewController.view.frame = primaryViewFrame
                    self.secondaryViewController.view.frame = secondaryViewFrame
                }, completion: { (completion) -> Void in
                    self.viewState.displayState = displayState
            })
        } else {
            primaryViewController.view.frame = primaryViewFrame
            secondaryViewController.view.frame = secondaryViewFrame
            
            viewState.displayState = displayState
        }
    }
    
    private func updateChildViewsLayout(#difference: CGPoint, displayState: DisplayState) {
        let xDiff = difference.x
        let yDiff = difference.y
        
        let currentPrimaryViewFrame = primaryViewController.view.frame
        let currentSecondaryViewFrame = secondaryViewController.view.frame
        
        let primaryViewFrame = CGRectMake(
            0,
            0,
            currentPrimaryViewFrame.size.width,
            currentPrimaryViewFrame.size.height + yDiff)
        
        let secondaryViewFrame = CGRectMake(
            0,
            currentSecondaryViewFrame.origin.y + yDiff,
            currentSecondaryViewFrame.size.width,
            currentSecondaryViewFrame.size.height - yDiff)
        
        primaryViewController.view.frame = primaryViewFrame
        secondaryViewController.view.frame = secondaryViewFrame
    }
    
    
    // MARK: - Selecot
    
    func handlePanGestureRecognizer(recognizer: UIPanGestureRecognizer) {
        let draggingFromTopToBottom = recognizer.velocityInView(view).y > 0
        
        switch recognizer.state {
        case .Began:
            viewState.gestureState = GestureState.Began
        case .Changed:
            let currentTranslation = recognizer.translationInView(view)
            let difference = CGPointMake(
                currentTranslation.x - panGestureTranslation.x,
                currentTranslation.y - panGestureTranslation.y)
            
            updateChildViewsLayout(difference: difference, displayState: viewState.displayState)
            
            panGestureTranslation = currentTranslation
            
            viewState.gestureState = GestureState.Changed
        case .Ended:
            switch viewState.displayState {
            case .Both:
                if panGestureTranslation.y > 0 && draggingFromTopToBottom {
                    layoutChildViews(displayState: .Primary, animated: true)
                } else if panGestureTranslation.y < 0 && !draggingFromTopToBottom {
                    layoutChildViews(displayState: .Secondary, animated: true)
                } else {
                    layoutChildViews(displayState: .Both, animated: true)
                }
            case .Primary:
                if panGestureTranslation.y < 0 && !draggingFromTopToBottom {
                    layoutChildViews(displayState: .Both, animated: true)
                } else {
                    layoutChildViews(displayState: .Primary, animated: true)
                }
            case .Secondary:
                if panGestureTranslation.y > 0 && draggingFromTopToBottom {
                    layoutChildViews(displayState: .Both, animated: true)
                } else {
                    layoutChildViews(displayState: .Secondary, animated: true)
                }
            }
            
            panGestureTranslation = CGPointZero
            recognizer.setTranslation(CGPointZero, inView: view)
            
            viewState.gestureState = GestureState.Ended
        default:
            break
        }
    }
    
}
