//
//  BisectionViewController.swift
//  BisectionViewController
//
//  Created by MiyakeAkira on 2015/06/07.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import UIKit

public class BisectionViewController: UIViewController {
    
    // MARK: - let
    
    public let currentViewMode: CurrentViewMode
    public let currentGestureState: CurrentGestureState
    
    
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
    
    private var isInitializedChildViewsLayout: Bool
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var translation: CGPoint
    
    
    // MARK: - Initialize
    
    public init(
        primaryViewController: UIViewController,
        secondaryViewController: UIViewController,
        viewMode: ViewMode)
    {
        currentViewMode = CurrentViewMode(viewMode)
        currentGestureState = CurrentGestureState()
        
        self.primaryViewController = primaryViewController
        self.secondaryViewController = secondaryViewController
        
        isInitializedChildViewsLayout = false
        
        translation = CGPointZero
        
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
        
        if !isInitializedChildViewsLayout {
            layoutChildViews(viewMode: currentViewMode.value, animated: false)
            isInitializedChildViewsLayout = true
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if isViewLoaded() && view.window == nil {
            view = nil
        }
    }
    
    
    // MARK: - Method
    
    public func setViewMode(viewMode: ViewMode, animated: Bool) {
        layoutChildViews(viewMode: viewMode, animated: animated)
    }
    
    
    // MARK: - Priavet method
    
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
    
    private func layoutChildViews(#viewMode: ViewMode, animated: Bool) {
        let width: CGFloat = view.frame.size.width
        let height: CGFloat = view.frame.size.height
        
        let primaryViewFrame: CGRect
        let secondaryViewFrame: CGRect
        
        switch viewMode {
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
                    self.currentViewMode.value = viewMode
            })
        } else {
            primaryViewController.view.frame = primaryViewFrame
            secondaryViewController.view.frame = secondaryViewFrame
            
            currentViewMode.value = viewMode
        }
    }
    
    private func updateChildViewsLayout(#difference: CGPoint) {
        let xDiff = difference.x
        let yDiff = difference.y
        
        let flag: Bool
        switch currentViewMode.value {
        case .Both:
            flag = true
        case .Primary:
            if xDiff < 0 {
                flag = true
            } else {
                flag = false
            }
        case .Secondary:
            if xDiff > 0 {
                flag = true
            } else {
                flag = false
            }
        }
        
        if flag {
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
    }
    
    
    // MARK: - Selector
    
    func handlePanGestureRecognizer(recognizer: UIPanGestureRecognizer) {
        let draggingFromTopToBottom = recognizer.velocityInView(view).y > 0
        
        switch recognizer.state {
        case .Began:
            currentGestureState.value = .Began
        case .Changed:
            let currentTranslation = recognizer.translationInView(view)
            let difference = CGPointMake(
                currentTranslation.x - translation.x,
                currentTranslation.y - translation.y)
            
            updateChildViewsLayout(difference: difference)
            
            translation = currentTranslation
            
            currentGestureState.value = .Changed
        case .Ended:
            switch currentViewMode.value {
            case .Both:
                if translation.y > 0 && draggingFromTopToBottom {
                    layoutChildViews(viewMode: .Primary, animated: true)
                } else if translation.y < 0 && !draggingFromTopToBottom {
                    layoutChildViews(viewMode: .Secondary, animated: true)
                } else {
                    layoutChildViews(viewMode: .Both, animated: true)
                }
            case .Primary:
                if translation.y < 0 && !draggingFromTopToBottom {
                    layoutChildViews(viewMode: .Both, animated: true)
                } else {
                    layoutChildViews(viewMode: .Primary, animated: true)
                }
            case .Secondary:
                if translation.y > 0 && draggingFromTopToBottom {
                    layoutChildViews(viewMode: .Both, animated: true)
                } else {
                    layoutChildViews(viewMode: .Secondary, animated: true)
                }
            }
            
            translation = CGPointZero
            recognizer.setTranslation(CGPointZero, inView: view)
            
            currentGestureState.value = .Ended
        default:
            break
        }
    }
    
}
