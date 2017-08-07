//
//  SMRippleView
//  SMRippleView
//
//  Created by Sanjay Maharjan on 5/25/16.
//  Copyright © 2016 Sanjay Maharjan. All rights reserved.
//
// fork from https://github.com/sanjaymhj/SMRippleExample/

import UIKit

final internal class SMRippleView: UIView {
    private let originalFrame: CGRect
    private let interval: Float
    private let rippleEndScale: Float = 2
    private let color: UIColor
    private let duration: TimeInterval
    private var timer: Timer?

    init(frame: CGRect, color: UIColor, interval: Float, duration: Double) {
        self.originalFrame = frame
        self.color = color
        self.interval = interval
        self.duration = TimeInterval(duration)

        let squareRect = CGRect(x: frame.minX,
                                y: frame.minY,
                                width: max(frame.width, frame.height),
                                height: max(frame.width, frame.height))
        super.init(frame: squareRect)

        self.startRipple()
    }

    func startRipple() {
        self.timer = Timer.scheduledTimer(
            timeInterval: Double(self.interval),
            target: self,
            selector: #selector(continuousRipples),
            userInfo: nil,
            repeats: true)
        DispatchQueue.main.async {
            self.continuousRipples()
        }
    }

    func stopAnimation() {
        self.timer?.invalidate()
    }

    private func getLayer() -> RippleCALayer {
        //Minimum bounds
        let pathFrame = CGRect(x: -self.bounds.midX,
                               y: -self.bounds.midY,
                               width: self.bounds.size.width,
                               height: self.bounds.size.height)

        let path = UIBezierPath(roundedRect: pathFrame, cornerRadius: self.frame.size.height)

        let shapePosition = CGPoint(x: originalFrame.midX, y: originalFrame.midY)
        let circleShape = RippleCALayer()
        circleShape.path = path.cgPath

        // position set to Center of bounds. If set to origin, it will only expand to +x and +y
        circleShape.position = shapePosition
        circleShape.fillColor = self.color.cgColor

        // Opacity is 0 so it is invisible in initial state
        circleShape.opacity = 0

        return circleShape
    }

    private func getAnimation() -> CAAnimationGroup {
        // Scale Animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(CGFloat(self.rippleEndScale), 1, 1))

        // Alpha Animation
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0

        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = self.duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        return animation
    }

    @objc
    private func continuousRipples() {
        let layer = getLayer()
        let animation = getAnimation()
        // To remove layer from super layer after animation completes
        animation.delegate = layer
        layer.animationDelegate = self
        layer.add(animation, forKey: nil)
        self.superview?.layer.addSublayer(layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}

// Protocol and extension for removing layer from super layer after animation completes
extension SMRippleView: AnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, layer: CALayer, finished: Bool) {
        layer.removeFromSuperlayer()
    }
}

extension RippleCALayer: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.animationDelegate?.animationDidStop(anim, layer: self, finished: flag)
    }
}

final private class RippleCALayer: CAShapeLayer {
   weak var animationDelegate: AnimationDelegate?
}

private protocol AnimationDelegate: class {
    func animationDidStop(_ anim: CAAnimation, layer: CALayer, finished: Bool)
}
