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

public func delay(delay:Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


public enum Haptic {
    case impact(UIImpactFeedbackStyle)
    case notification(UINotificationFeedbackType)
    case selection
    
    // trigger
    public func generate() {
        switch self {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case .notification(let type):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}


extension UILabel {
    func preferredHeight(withText: String? = nil) -> CGFloat {
        let text = withText ?? self.text ?? "\n"
        let font = self.font!
        let width = self.frame.width
        let insets = UIEdgeInsets.zero
        
        let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSFontAttributeName: font]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        let height = ceil(bounds.height + insets.top + insets.bottom)
        
        return height
    }
}


extension String {
    func regex(_ regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
