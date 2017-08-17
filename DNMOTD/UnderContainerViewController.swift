//
//  UnderContainerViewController.swift
//  DNMOTD
//
//  Created by ray on 28/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class UnderContainerViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!

    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var fontSegmentedControl: UISegmentedControl!
    @IBOutlet weak var fontBoldButton: UIButton!
    @IBOutlet weak var fontItalicButton: UIButton!
    
    var setFont: ((UIFont) -> Void)?
    
    let fonts = ["SF Pro Display", "Georgia", "Avenir Next", "Palatino"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    

    func customFont() {
        
        let fontIndex = Defaults[.fontIndex]!
        let fontBold = Defaults[.fontBold]!
        let fontItalic = Defaults[.fontItalic]!

        //        Another working implement:
        //        let descriptor = UIFontDescriptor(name: "Avenir Next", size: 32).withSymbolicTraits([.traitBold, .traitItalic])
        
        let descriptor = UIFontDescriptor(fontAttributes:
            [
                UIFontDescriptorFamilyAttribute: fonts[fontIndex],
                UIFontDescriptorTraitsAttribute: [
                    UIFontWeightTrait: fontBold ? UIFontWeightBold : UIFontWeightRegular,
                    UIFontSlantTrait: fontItalic ? 1.0 : 0.0
                ]
            ]
        )
        
        let font = UIFont(descriptor: descriptor, size: 32)
        
        setFont?(font)
        
        Defaults[.fontName] = font.fontName
        
        Haptic.impact(.light).generate()
    }
    
    
    
    func initialFontSettingsUIStates() {
        let fontIndex = Defaults[.fontIndex]!
        let fontBold = Defaults[.fontBold]!
        let fontItalic = Defaults[.fontItalic]!
        
        fontSegmentedControl.selectedSegmentIndex = fontIndex
        fontBoldButton.isSelected = fontBold
        fontItalicButton.isSelected = fontItalic
    }
    
    

    

    @IBAction func fontSegmentedTapped(_ sender: UISegmentedControl) {
        Defaults[.fontIndex] = sender.selectedSegmentIndex
        customFont()
    }
    
    
    @IBAction func boldButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Defaults[.fontBold] = sender.isSelected
        customFont()
    }
    
    
    @IBAction func italicButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Defaults[.fontItalic] = sender.isSelected
        customFont()
    }

    
    @IBAction func userViewOverlayButtonTapped(_ sender: Any) {
        let id = currentUser["id"].stringValue
        if let url = URL(string: dn_url + "users/" + id) {
            present(browserView(withURL: url), animated: true)
        }
    }

    
    
    
    // User View:
    
    func renderUserProfile(completion: @escaping() -> Void) {
        let first_name = currentUser["first_name"].stringValue
        let last_name = currentUser["last_name"].stringValue
        let full_name = first_name + " " + last_name
        let job = currentUser["job"].stringValue
        
        fullnameLabel.text = " \(full_name) "
        jobLabel.text = " \(job == "" ? "No Job Position" : job) "

        coverImage.image = nil
        avatarImage.image = nil
        coverImage.hnk_setImageFromURL(URL(string: currentUser["cover_photo_url"].stringValue)!)
        avatarImage.hnk_setImageFromURL(URL(string: currentUser["portrait_url"].stringValue)!)
        
//        let stories = currentUser["links"]["stories"].count
//        let comments = currentUser["links"]["comments"].count
//        let upvotes = currentUser["links"]["upvotes"].count
//        let karma = currentUser["karma"].stringValue
        
//        dataLabel.text = "\(stories) stories, \(comments) comments, \(upvotes) upvotes, \(karma) karma"
        
        completion()
    }
}
