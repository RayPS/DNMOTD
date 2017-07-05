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


@IBDesignable class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(
                with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
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
