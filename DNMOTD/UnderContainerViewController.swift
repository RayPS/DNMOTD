//
//  UnderContainerViewController.swift
//  DNMOTD
//
//  Created by ray on 28/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit

class UnderContainerViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!

    var setFont: ((UIFont) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func fontSegmentedTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setFont?(UIFont.systemFont(ofSize: 32, weight: UIFontWeightBold))
        case 1:
            setFont?(UIFont(name: "Georgia-Bold", size: 32)!)
        case 2:
            setFont?(UIFont(name: "Georgia-BoldItalic", size: 32)!.)
        case 3:
            setFont?(UIFont(name: "Palatino-Bold", size: 32)!)
        default:
            break
        }
    }
}
