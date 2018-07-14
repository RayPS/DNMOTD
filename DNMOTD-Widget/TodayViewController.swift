//
//  TodayViewController.swift
//  DNMOTD-Widget
//
//  Created by ray on 02/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import NotificationCenter
import Kanna

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    let gradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.messageLabel.text = "\n"
        self.authorLabel.text = ""
        cardView.layer.cornerRadius = 8

        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]

        gradient.locations = [0.0, 0.75, 0.95]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let mode = extensionContext?.widgetActiveDisplayMode,
           let maxSize = extensionContext?.widgetMaximumSize(for: mode) {
            gradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: maxSize)
        }
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

        let hasShowMoreButton = extensionContext?.widgetLargestAvailableDisplayMode == .expanded

        let expandedHeight = view.systemLayoutSizeFitting(view.bounds.size).height

        if hasShowMoreButton {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.4)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))

            gradient.frame.origin = CGPoint.zero
            gradient.frame.size.width = maxSize.width

            switch activeDisplayMode {
            case .compact:
                self.preferredContentSize.height = maxSize.height
                gradient.frame.size.height = maxSize.height
            case .expanded:
                self.preferredContentSize.height = expandedHeight
                gradient.frame.size.height = expandedHeight + expandedHeight * 0.25
            }

            // NOTE: gradient == view.layer.mask
            // view.layer.mask?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: maxSize)

            CATransaction.commit()
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        getLatestMOTD { (message, author) in

            if message == self.messageLabel.text {
                completionHandler(NCUpdateResult.noData)
            } else {
                self.messageLabel.text = message
                self.authorLabel.text = "— " + author

                completionHandler(NCUpdateResult.newData)

                if self.messageLabel.preferredHeight() > self.messageLabel.preferredHeight(withText: "\n") {
                    self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
                    self.view.layer.mask = self.gradient
                } else {
                    self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
                }
            }
        }


    }
    
    
    @IBAction func tapGesture(_ sender: Any) {
        if let url = URL(string: "dnmotd://") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    
    
    func getLatestMOTD(completion: @escaping(_ message: String, _ author: String) -> Void) {
        
        let url = URL(string: "https://www.designernews.co/")

        do {
            let doc = try HTML(url: url!, encoding: .utf8)
            if let message = doc.at_css("#feed-motd-message"),
                let author = doc.at_css("#feed-motd-author a") {
                completion(message.text!, author.text!)
            }
        } catch {
            print(error)
        }
    }
    
}


