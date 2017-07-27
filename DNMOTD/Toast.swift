//
//  Toast.swift
//  DNMOTD
//
//  Created by ray on 26/07/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit

func showToast(withTitle title: String, inView view: UIView) {

    let label = PaddingLabel(8, 8, 16, 16)

    label.font = .boldSystemFont(ofSize: 16)
    label.text = title
    label.backgroundColor = .black
    label.textColor = .white
    label.textAlignment = .center
    label.layer.cornerRadius = 4
    label.clipsToBounds = true
    label.sizeToFit()

    view.addSubview(label)

    // Auto Layout
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true

    // Animation
    label.layer.opacity = 0
    label.transform = CGAffineTransform(scaleX: 0, y: 0)
    UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.0,
        options: [],
        animations: {
            label.transform = CGAffineTransform(scaleX: 1, y: 1)
            label.layer.opacity = 1
        },
        completion: { finished in
            delay(delay: 1) {
                UIView.animate(withDuration: 0.25, animations: {
                    label.transform = CGAffineTransform.identity
                    label.layer.opacity = 0
                }, completion: { finished in
                    label.removeFromSuperview()
                })
            }
        }
    )
}


class PaddingLabel: UILabel {

    var topInset: CGFloat
    var bottomInset: CGFloat
    var leftInset: CGFloat
    var rightInset: CGFloat

    required init(_ top: CGFloat, _ bottom: CGFloat,_ left: CGFloat,_ right: CGFloat) {
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}
