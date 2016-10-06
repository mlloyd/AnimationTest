//
//  ViewController.swift
//  AnimationTest
//
//  Created by Martin Lloyd on 05/10/2016.
//  Copyright © 2016 Thomson Reuters. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var box: UIView!
    
    var displayLink: CADisplayLink!
    
    var forwards = true
    
    var step: CGFloat = 0.01
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(tick))
        
        self.box = UIView(frame: self.view.bounds)
        self.box.backgroundColor = UIColor.yellow
        self.view.addSubview(self.box)
        
        self.box.layer.shadowColor = UIColor.black.cgColor
        self.box.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        self.box.layer.shadowOpacity = 0.25
        self.box.layer.shadowRadius = 1.0
        
        let boxAnimation = CABasicAnimation(keyPath: "position.y")
        boxAnimation.fromValue = 0
        boxAnimation.toValue   = -(self.box.frame.size.height - 80)
        boxAnimation.duration  = 1
        boxAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let zAnimation = CABasicAnimation(keyPath: "zPosition")
        zAnimation.fromValue = 0
        zAnimation.toValue   = 100
        zAnimation.duration  = 1
        zAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        
        let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
        alphaAnimation.values    = [1,0.75,0.5]
        alphaAnimation.keyTimes  = [0.25,0.5,1]
        alphaAnimation.duration  = 1
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        box.layer.add(alphaAnimation, forKey: nil)
        box.layer.add(boxAnimation, forKey: nil)
        box.layer.add(zAnimation, forKey: nil)
        
        box.layer.speed = 0.0
        box.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
    }
    
    func tick() {
        if box.layer.timeOffset >= 1 ||
            box.layer.timeOffset <= 0 {
            self.displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            self.panGestureRecognizer.isEnabled = true
        }
        
        let step = CFTimeInterval(self.step)
        
        box.layer.timeOffset = forwards ?
            min(box.layer.timeOffset + step, 1.0):
            max(box.layer.timeOffset - step, 0.0)
    }
    
    func pan(gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        var progress = (-translation.y / 400)
        
        if forwards == false {
            progress = 1 + progress
        }
        
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        print("progress", progress)
        
        switch gestureRecognizer.state {
            
        case .began:
            
            forwards = (box.layer.timeOffset < 0.5)
            print("began", forwards)
        case .changed:
            
            box.layer.timeOffset = CFTimeInterval(progress)
            print("changed ", box.layer.timeOffset)
        case .cancelled:
            print("cancelled")
            break;
        case .ended:
            print("ended")
            
            let velocity = gestureRecognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 400
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2
            self.step = max(CGFloat(0.01 * slideMultiplier), 0.01)    //Increase for more of a slide
            
            print(self.step)
            
            forwards = progress > 0.5            
            
            self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            self.panGestureRecognizer.isEnabled = false
            break;
        default:
            print("Unsupported")
        }
    }
}
