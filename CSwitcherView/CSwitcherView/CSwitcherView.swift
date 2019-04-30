//
//  CSwitcherView.swift
//  CSwitcherView

import UIKit

class CSwitcherView: UIView {
    enum SwitcherState {
        case on
        case off
    }
    
    var state: SwitcherState = .off {
        didSet {
            toggleAnimation()
        }
    }
    
    private var leftSwitchCenter: CGPoint {
        return CGPoint(x: bounds.height / 2, y: bounds.height / 2)
    }
    
    private var rightSwitchCenter: CGPoint {
        return CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
    }
    
    private var minRadius: CGFloat {
        return bounds.height / 6
    }
    
    private var maxRadius: CGFloat {
        return bounds.width
    }
    
    private var durationForAnimation: CFTimeInterval {
        return 0.3
    }
    
    private let bgLayer = CAShapeLayer()
    
    private weak var target: NSObject?
    private var action: Selector?
    
    private lazy var onLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()
    
    private let offLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    private let maskLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleHandler)))
        
        bgLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath
        layer.insertSublayer(bgLayer, at: 0)
        
        switch state {
        case .on:
            bgLayer.fillColor = onLayer.fillColor
        case .off:
            bgLayer.fillColor = offLayer.fillColor
        }
        
        toggleAnimation()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)
        maskLayer.frame = rect
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    private func toggleAnimation() {
        switch state {
        case .on:
            animationFromOffToOn()
        case .off:
            animationFromOnToOff()
        }
    }
    
    private func animationFromOnToOff() {
        let beginTimeForAnimation = CACurrentMediaTime()
        
        bgLayer.fillColor = offLayer.fillColor
        
        let animationStepOne = bgAnimation()
        animationStepOne.beginTime = beginTimeForAnimation
        
        onLayer.add(animationStepOne, forKey: "1")
        layer.insertSublayer(onLayer, at: 1)
        
        let animationStepTwo = switchAnimation()
        animationStepTwo.beginTime = beginTimeForAnimation + durationForAnimation
        
        offLayer.add(animationStepTwo, forKey: "1")
        layer.insertSublayer(offLayer, at: 2)
    }
    
    private func animationFromOffToOn() {
        let beginTimeForAnimation = CACurrentMediaTime()
        
        bgLayer.fillColor = onLayer.fillColor
        
        let animationStepOne = bgAnimation()
        animationStepOne.beginTime = beginTimeForAnimation
        
        offLayer.add(animationStepOne, forKey: "1")
        layer.insertSublayer(offLayer, at: 1)
        
        let animationStepTwo = switchAnimation()
        animationStepTwo.beginTime = beginTimeForAnimation + durationForAnimation
        
        onLayer.add(animationStepTwo, forKey: "1")
        layer.insertSublayer(onLayer, at: 2)
    }
    
    private func bgAnimation() -> CABasicAnimation {
        var arcCenter: CGPoint = rightSwitchCenter
        
        switch state {
        case .on:
            arcCenter = leftSwitchCenter
        case .off:
            arcCenter = rightSwitchCenter
        }
        
        let animationStepOne = CABasicAnimation(keyPath: "path")
        animationStepOne.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationStepOne.isRemovedOnCompletion = false
        animationStepOne.fillMode = .forwards
        animationStepOne.duration = durationForAnimation
        
        animationStepOne.fromValue = UIBezierPath(arcCenter: arcCenter, radius: minRadius, startAngle: 0, endAngle: CGFloat(Float(2) * Float.pi), clockwise: true).cgPath
        animationStepOne.toValue = UIBezierPath(arcCenter: arcCenter, radius: maxRadius, startAngle: 0, endAngle: CGFloat(Float(2) * Float.pi), clockwise: true).cgPath
        
        return animationStepOne
    }
    
    private func switchAnimation() -> CAKeyframeAnimation {
        var arcCenter: CGPoint = rightSwitchCenter
        
        switch state {
        case .on:
            arcCenter = rightSwitchCenter
        case .off:
            arcCenter = leftSwitchCenter
        }
        
        let path1 = UIBezierPath(arcCenter: arcCenter, radius: 0, startAngle: 0, endAngle: CGFloat(Float(2) * Float.pi), clockwise: true).cgPath
        let path2 = UIBezierPath(arcCenter: arcCenter, radius: (minRadius * 1.2) , startAngle: 0, endAngle: CGFloat(Float(2) * Float.pi), clockwise: true).cgPath
        let path3 = UIBezierPath(arcCenter: arcCenter, radius: minRadius, startAngle: 0, endAngle: CGFloat(Float(2) * Float.pi), clockwise: true).cgPath
        
        let animationStepTwo = CAKeyframeAnimation(keyPath: "path")
        animationStepTwo.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationStepTwo.isRemovedOnCompletion = false
        animationStepTwo.fillMode = .forwards
        animationStepTwo.duration = durationForAnimation
        animationStepTwo.values = [path1, path2, path3]
        
        return animationStepTwo
    }
    
    func toggle() {
        state = state == .on ? .off : .on
    }
    
    func addTarget(target: Any?, action: Selector, for: UIControl.Event) {
        if let target = target as? NSObject {
            self.target = target
            self.action = action
        }
    }
}

@objc private extension CSwitcherView {
    func toggleHandler() {
        toggle()
        if action != nil {
            target?.perform(action!)
        }
    }
}
