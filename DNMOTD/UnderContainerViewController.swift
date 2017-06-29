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
    @IBOutlet weak var dataLabel: UILabel!

    @IBOutlet weak var fontItalicButton: UIButton!
    
    var setFont: ((UIFont) -> Void)?
    
    var fonts: [String] = []
    
    var fontIndex: Int   = 0
    var fontBold: Bool   = true
    var fontItalic: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let systemFontName = UIFont.systemFont(ofSize: 32).fontName
        fonts = [systemFontName, "Georgia", "GillSans", "Palatino"]
    }
    
    func customFont() {

        // Because System font doesn't have Italic.
        fontItalicButton.isEnabled = (fontIndex != 0)
        if fontIndex == 0 {
            fontItalic = false
            fontItalicButton.setTitle("□ Italic", for: .disabled)
            fontItalicButton.setTitle("□ Italic", for: .normal)
        }
        // ---
        
        let fontName: String = fonts[fontIndex] +
            (fontBold || fontItalic ? "-" : "") +
            (fontBold   ? "Bold"   : "")        +
            (fontItalic ? "Italic" : "")
        
        setFont?(UIFont(name: fontName, size: 32)!)
        Haptic.impact(.light).generate()
    }

    @IBAction func fontSegmentedTapped(_ sender: UISegmentedControl) {
        fontIndex = sender.selectedSegmentIndex
        customFont()
    }
    
    
    @IBAction func boldButtonTapped(_ sender: UIButton) {
        // 😅😅😅
        if sender.titleLabel?.text == "■ Bold" {
            sender.setTitle("□ Bold", for: .normal)
            fontBold = false
        } else {
            sender.setTitle("■ Bold", for: .normal)
            fontBold = true
        }
        customFont()
    }
    
    
    @IBAction func italicButtonTapped(_ sender: UIButton) {
        // 😅😅😅
        if sender.titleLabel?.text == "■ Italic" {
            sender.setTitle("□ Italic", for: .normal)
            fontItalic = false
        } else {
            sender.setTitle("■ Italic", for: .normal)
            fontItalic = true
        }
        customFont()
    }

    
    @IBAction func userPageButtonTapped(_ sender: UIButton) {
    }
}
