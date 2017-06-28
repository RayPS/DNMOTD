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

    var chooseColor: ((UIColor) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func fontSegmentedTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            chooseColor?(.red)
        case 1:
            chooseColor?(.green)
        default:
                break
        }
    }
}
