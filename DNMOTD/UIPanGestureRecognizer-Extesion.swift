//
//  UIPanGestureRecognizer-Extesion.swift
//  DNMOTD
//
//  Created by Ray on 16/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit

public enum PanGestureDirection {
    case up
    case right
    case down
    case left
}

var beganDirection: PanGestureDirection = .up

extension UIPanGestureRecognizer {
    
    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        if abs(velocity.y) > abs(velocity.x) {
            return velocity.y < 0.0 ? .up : .down
        } else {
            return velocity.x < 0 ? .left : .right
        }
    }
}
