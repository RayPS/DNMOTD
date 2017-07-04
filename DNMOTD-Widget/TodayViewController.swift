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
    
    var message = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        getLatestMOTD { (message, author) in
            self.message = message
            self.messageLabel.text = message
            self.authorLabel.text = "— " + author
        }
        
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            messageLabel.numberOfLines = 2
            messageLabel.frame.size.height = messageLabel.preferredHeight(withText: "\n")
        case .expanded:
            messageLabel.numberOfLines = 0
            self.preferredContentSize.height = 16 * 4 + messageLabel.preferredHeight()
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


