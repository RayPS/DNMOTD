//
//  TutorialViewController.swift
//  DNMOTD
//
//  Created by Ray on 30/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import Spring

class TutorialViewController: UIViewController {

    @IBOutlet weak var hintView: DesignableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.window?.backgroundColor = UIColor.clear
        
        hintView.layer.opacity = 0
        hintView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hintView.opacity = 1
        hintView.scaleX = 1
        hintView.scaleY = 1
        hintView.animateTo()
    }

    @IBAction func viewOnPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            hintView.opacity = 0
            hintView.scaleX = 0.5
            hintView.scaleY = 0.5
            hintView.duration = 0.5
            hintView.animateTo()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
