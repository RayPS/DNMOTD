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
        
        initial()
    }
    
    
    func initial() {
        messageLabel.layer.opacity = 0
        votesLabel.layer.opacity = 0
        dotButton.layer.opacity = 0.1
        
        Loader.addLoadersTo(loadingEffectView)

        getlatestID {
            currentID = latestID
            self.renderMOTD()
        }
    }
    
    
    func renderMOTD() {
        
        showLoadEffect()
        
        getMOTD(byID: currentID, completion: { (json) in
            let motd      = json["motds"][0]
            let message   = motd["message"].string!
            let upvotes   = motd["links"]["upvotes"]
            let downvotes = motd["links"]["downvotes"]
            
            debugPrint(message)
            
            self.messageLabel.text = message
            self.votesLabel.text = "+\(upvotes.count) / -\(downvotes.count)"
            
            self.showMessageLabel()
            self.hideLoadEffect()
        })
    }
    
    
    
    
    
    // Animation Functions:
    
    
    func showMessageLabel() {
        UIView.animate(withDuration: 0.5) {
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.dotButton.layer.opacity = 1
        }
    }
    
    func showLoadEffect() {
        UIView.animate(withDuration: 0.2) { 
            self.loadingEffectView.layer.opacity = 1
        }
    }
    
    func hideLoadEffect() {
        UIView.animate(withDuration: 0.2) {
            self.loadingEffectView.layer.opacity = 0
        }
    }
}

