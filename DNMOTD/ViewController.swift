//
//  ViewController.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var loadingEffectView: UIView!
    @IBOutlet weak var dotButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        
        // TODO: Reachability for first launch
        // TODO: Font settings
        // TODO: About
        
        
        messageLabel.layer.opacity = 0
        votesLabel.layer.opacity = 0
        dotButton.layer.opacity = 0.1
        Loader.addLoadersTo(loadingEffectView)
        
        getMOTD { (json) in
            let motd      = json["motds"][0]
            let message   = motd["message"].string!
            let upvotes   = motd["links"]["upvotes"]
            let downvotes = motd["links"]["downvotes"]
            
            
            debugPrint(message)
            self.messageLabel.text = message
            
            
            self.votesLabel.text = "+\(upvotes.count) / -\(downvotes.count)"
            self.showMessageLabel()
            Loader.removeLoadersFrom(self.loadingEffectView)
        }
    }
    
    
    func showMessageLabel() {
        UIView.animate(withDuration: 0.5) { 
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.dotButton.layer.opacity = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

