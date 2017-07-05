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
        
        getLatestMOTD { (message, author) in
            self.messageLabel.text = message
            self.authorLabel.text = "— " + author
            
            if self.messageLabel.preferredHeight() > self.messageLabel.preferredHeight(withText: "\n") {
                self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
                self.view.layer.mask = self.gradient
            } else {
                self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        gradient.frame = view.frame
        
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        
        gradient.locations = [0.0, 0.75, 0.95]
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
            
            
        UIView.animate(withDuration: 0.25, animations: {
            switch activeDisplayMode {
            case .compact:
                self.preferredContentSize = maxSize
            case .expanded:
                self.preferredContentSize = self.view.systemLayoutSizeFitting(self.view.bounds.size)
            }
        })
    
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        view.layer.mask?.bounds.size = maxSize
        
        CATransaction.commit()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.newData)
    }
    
    
    @IBAction func tapGesture(_ sender: Any) {
        if let url = URL(string: "dnmotd://") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    
    
    func getLatestMOTD(completion: @escaping(_ message: String, _ author: String) -> Void) {
        
        let url = URL(string: "https://www.designernews.co/")
        
        if let doc = HTML(url: url!, encoding: .utf8) {
            if let message = doc.at_css("#feed-motd-message"),
                let author = doc.at_css("#feed-motd-author a") {
                completion(message.text!, author.text!)
            }
        }
        
    }
    
}


