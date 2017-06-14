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
    @IBOutlet weak var loadingEffectView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        messageLabel.layer.opacity = 0
        Loader.addLoadersTo(loadingEffectView)
        
        getMOTD { (motd) in
            if let message = motd["motds"][0]["message"].string {
                debugPrint(message)
                self.messageLabel.text = message
                self.showMessageLabel()
                Loader.removeLoadersFrom(self.loadingEffectView)
            }
        }
    }
    
    
    func showMessageLabel() {
        UIView.animate(withDuration: 0.5) { 
            self.messageLabel.layer.opacity = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

