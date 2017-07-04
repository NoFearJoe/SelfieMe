//
//  MultiStateView.swift
//  SelfieMe
//
//  Created by Ilya Kharabet on 14.03.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import Foundation
import UIKit


protocol MultiStateViewDelegate {
    
    func multiStateView(_ view: MultiStateView, stateChangedToIndex: Int)
    
}


@IBDesignable final class MultiStateView: UIView {
    
    @IBInspectable var inactiveStateColor: UIColor = Theme.tintColor {
        didSet {
            button.iconInactiveStateColor = inactiveStateColor
        }
    }
    @IBInspectable var activeStateColor: UIColor = Theme.mainColor {
        didSet {
            button.iconActiveStateColor = activeStateColor
        }
    }
    
    
    var states: [MultiStateButtonState]!
    var currentIndex: Int = 0
    var state: MultiStateButtonState {
        return states[currentIndex]
    }
    
    var stateDelegate: MultiStateViewDelegate?
    
    fileprivate var button: MultiStateButton!
    
    
    init(frame: CGRect, states: [MultiStateButtonState]) {
        super.init(frame: frame)
        
        clipsToBounds = false
        autoresizesSubviews = true
        
        self.button = MultiStateButton(frame: frame)
        self.states = states
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        clipsToBounds = false
        autoresizesSubviews = true
        
        self.button = MultiStateButton(frame: frame)
        self.states = [MultiStateButtonState(icon: UIImage(), title: "", isActive: false)]
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        prepareStatesButton(states)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let state = button.buttonState ?? states[currentIndex]
        button.buttonState = state
    }
    
    
    fileprivate func prepareStatesButton(_ states: [MultiStateButtonState]) {
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.addTarget(self, action: #selector(MultiStateView.setNextState), for: .touchUpInside)
        button.iconInactiveStateColor = inactiveStateColor
        button.iconActiveStateColor = activeStateColor
        
        addSubview(button)
    }
    
    
    func setNextState() {
        if let _ = button.buttonState, var index = states.index(of: button.buttonState!) {
            if index + 1 >= states.count {
                index = -1
            }
            
            currentIndex = index + 1
            
            button.buttonState = states[currentIndex]
            
            stateDelegate?.multiStateView(self, stateChangedToIndex: currentIndex)
        }
    }
    
    func setState(_ index: Int) {
        currentIndex = max(min(index, states.count), 0)
        button.buttonState = states[currentIndex]
    }
    
}
