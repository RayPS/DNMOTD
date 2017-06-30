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
        
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        getLatestMOTD { (message, author) in
            self.messageLabel.text = message
            self.authorLabel.text = "— " + author
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .expanded:
            self.preferredContentSize.height = 200
//            self.preferredContentSize.height = messageLabel.frame.size.height + authorLabel.frame.size.height + 16 * 3
        case .compact:
            self.preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
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
