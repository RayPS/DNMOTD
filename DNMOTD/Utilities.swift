//
//  Utilities.swift
//  DNMOTD
//
//  Created by Ray on 16/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit

func Modulate(input _input: CGFloat, from: [CGFloat], to: [CGFloat], limit: Bool) -> CGFloat {
    
    let input = Float(_input)
    let fromA = Float(from[0])
    let fromB = Float(from[1])
    let toA   = Float(to[0])
    let toB   = Float(to[1])
    
    let result = toA + (((input - fromA) / (fromB - fromA)) * (toB - toA))
    
    if (limit) {
        if (toA < toB) {
            if (result < toA) { return CGFloat(toA) }
            if (result > toB) { return CGFloat(toB) }
        }
        else {
            if (result > toA) { return CGFloat(toA) }
            if (result < toB) { return CGFloat(toB) }
        }
    }
    
    return CGFloat(result)
}
