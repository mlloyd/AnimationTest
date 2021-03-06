//
//  ViewController.swift
//  AnimationTest
//
//  Created by Martin Lloyd on 05/10/2016.
//  Copyright © 2016 Thomson Reuters. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let box = UIView(frame:CGRect(x: 0, y: 100, width: 40, height: 40))
    
    var displayLink: CADisplayLink!
    
    var forwards = true
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(tick))
        
        box.backgroundColor = UIColor.yellow
        self.view.addSubview(box)
        
        let boxAnimation = CABasicAnimation(keyPath: "position.x")
        boxAnimation.fromValue = 0
        boxAnimation.toValue = self.view.frame.size.width - box.frame.width
        boxAnimation.duration = 1
        boxAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        box.layer.add(boxAnimation, forKey : "key")
        box.layer.speed = 0.0
        box.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
    
    func tick() {
        if box.layer.timeOffset >= 1 ||
            box.layer.timeOffset <= 0 {
            self.displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            self.panGestureRecognizer.isEnabled = true
        }
        
        box.layer.timeOffset = forwards ?
            min(box.layer.timeOffset + 0.01, 1.0):
            max(box.layer.timeOffset - 0.01, 0.0)
        
        print(box.layer.timeOffset)
    }
    
    func pan(gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        var progress = (translation.x / 200)
        
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
            
            forwards = progress > 0.5
            
            self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            self.panGestureRecognizer.isEnabled = false
            break;
        default:
            print("Unsupported")
        }
    }
}
