//
//  ViewController.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import Spring
import ReachabilitySwift
import SwiftyUserDefaults

extension DefaultsKeys {
    static let fontIndex = DefaultsKey<Int?>("fontIndex")
    static let fontBold = DefaultsKey<Bool?>("fontBold")
    static let fontItalic = DefaultsKey<Bool?>("fontItalic")
    static let fontName = DefaultsKey<String?>("fontName")
}

class ViewController: UIViewController {

    @IBOutlet weak var containerView: SpringView!
    @IBOutlet weak var contentView: SpringView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var loadingEffectView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var leftCircle: SpringView!
    @IBOutlet weak var rightCircle: SpringView!
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    let reachability = Reachability()!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initial()
        initialFont()
        initialFirstLaunch()
        
        //                    TODO: ParseMedia
        //                    TODO: UserData
        //                    TODO: TodayWidget
        
        
        
        
    }
    
    var underView: UnderContainerViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnderContainerViewSegue" {
            underView = segue.destination as? UnderContainerViewController
            underView.setFont = { [weak self] font in
                self?.contentView.animation = "fadeOut"
                self?.contentView.duration = 0.25
                self?.contentView.animateNext {
                    self?.messageLabel.font = font
                    self?.contentView.animation = "fadeIn"
                    self?.contentView.animate()
                }
            }
        }
    }
    
    
    func initial() {
        messageLabel.layer.opacity = 0
        votesLabel.layer.opacity = 0
        menuButton.layer.opacity = 0
        userButton.layer.opacity = 0
        
        leftCircle.layer.cornerRadius = 100
        rightCircle.layer.cornerRadius = 100
        
        Loader.addLoadersTo(loadingEffectView)

        networkCheck {
            getlatestID {
                currentID = latestID
                self.renderMOTD()
            }
        }
        
        
    }
    
    
    func networkCheck(success: @escaping() -> Void) {
        reachability.whenReachable = { reachability in
            // UI updates must be on the main thread
            success()
            reachability.stopNotifier()
        }
        reachability.whenUnreachable = { reachability in
            // UI updates must be on the main thread
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Network Error", message: "Please check your network configurations.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }


    func renderMOTD() {
        
        startLoadEffect()
        
        getMOTD(byID: currentID, completion: { (json) in
            
            let motd      = json["motds"][0]
            let message   = motd["message"].stringValue
            let upvotes   = motd["links"]["upvotes"]
            let downvotes = motd["links"]["downvotes"]
            let userid    = motd["links"]["user"].intValue
            
            print("#\(currentID): \n\(message)\n")
            
            self.messageLabel.text = message
            self.votesLabel.text = "+\(upvotes.count) / -\(downvotes.count)"
            
            self.showMessageLabel()
            self.stopLoadEffect()
            
            self.renderUserButton(byID: userid)
        })
    }


    func renderUserButton(byID id: Int) {
        
        getUser(byID: id, completion: { (json) in
            
            currentUser = json["users"][0]
            
            self.userButtonSetTitle(isTriangle: false, haptic: false)
            
            UIView.animate(withDuration: 0.5, animations: { 
                self.userButton.layer.opacity = 1
            })
            
            self.underView.renderUserProfile()
        })
    }
    
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        if containerView.frame.origin.y == 0 {
            containerView.y = 240
        } else {
            containerView.y = 0
        }
        containerView.animateTo()
    }
    
    
    
    @IBAction func userButtonTapped(_ sender: Any) {
        if containerView.frame.origin.y == 0 {
            userButtonSetTitle(isTriangle: true, haptic: true)
            containerView.y = -underView.coverImage.frame.height
        } else {
            userButtonSetTitle(isTriangle: false, haptic: true)
            containerView.y = 0
        }
        containerView.animateTo()
    }
    
    @IBAction func containerViewOnDrag(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
//        let direction = sender.direction(in: view)
        
        let coverImageHeight = underView.coverImage.frame.height
        let ty = containerView.transform.ty
        
        let isLoading = self.loadingEffectView.layer.opacity != 0
        let containerViewNotMoved = Int(ty) == 0
        
        containerView.duration = 0.5
        
        if !isLoading {
            switch sender.state {
            case .began:
                beganDirection = sender.direction(in: view)
            
            case .changed:
                switch beganDirection {
                case .up, .down:
                    containerView.transform = CGAffineTransform(
                        translationX: 0,
                        y: ty + translation.y / 1.5
                    )
                    sender.setTranslation(CGPoint.zero, in: view)
                case .left, .right:
                    if containerViewNotMoved {
                        leftCircle.x = translation.x / 4
                        leftCircle.duration = 0
                        leftCircle.animateTo()
                        
                        rightCircle.x = translation.x / 4
                        rightCircle.duration = 0
                        rightCircle.animateTo()
                    }
                }

            case .ended:
                
                let triggerProfileOpen  = ty <= -50
                let triggerProfileClose = ty >= -coverImageHeight + 50
                let triggerMenuOpen  = ty > 80
                let triggerMenuClose = ty < 240 - 80
                
                if ty < 0 {
                    if beganDirection == .up && triggerProfileOpen || beganDirection == .down && !triggerProfileClose {
                        containerView.y = -coverImageHeight
                        userButtonSetTitle(isTriangle: true, haptic: true)
                    } else
                    if beganDirection == .down && triggerProfileClose || beganDirection == .up && !triggerProfileOpen {
                        containerView.y = 0
                        userButtonSetTitle(isTriangle: false, haptic: true)
                    }
                    containerView.animateTo()
                } else
                if ty > 0 {
                    if beganDirection == .down && triggerMenuOpen {
                        containerView.y = 240
                    } else
                    if beganDirection == .up && triggerMenuClose {
                        containerView.y = 0
                    }
                    Haptic.impact(.light).generate()
                    containerView.animateTo()
                }
                
                
                
                if (beganDirection == .left || beganDirection == .right) && containerViewNotMoved {
                    
                    let willLoadID = currentID + Int(-translation.x / abs(translation.x))
                    let overload = willLoadID > latestID || willLoadID == 0
                    let validPanDistance = abs(translation.x) >= 120
                    
                    if validPanDistance {
                        if !overload {
                            currentID = willLoadID
                            renderMOTD()
                            Haptic.impact(.light).generate()
                        } else {
                            Haptic.notification(.error).generate()
                        }
                    }

                    leftCircle.x = -200
                    leftCircle.duration = 1
                    leftCircle.animateTo()

                    rightCircle.x = screenWidth + 200
                    rightCircle.duration = 1
                    rightCircle.animateTo()
                }

                
            default:
                break
            }
        }
    }

    
    
    
    
    
    // Animation Functions:

    func showMessageLabel() {
        UIView.animate(withDuration: 0.5) {
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.menuButton.layer.opacity = 1
        }
    }
    
    func startLoadEffect() {
        UIView.animate(withDuration: 0.2) { 
            self.loadingEffectView.layer.opacity = 1
            self.messageLabel.layer.opacity = 0
            self.votesLabel.layer.opacity = 0
            self.menuButton.layer.opacity = 0
            self.userButton.layer.opacity = 0
        }
    }
    
    func stopLoadEffect() {
        UIView.animate(withDuration: 0.2) {
            self.loadingEffectView.layer.opacity = 0
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.menuButton.layer.opacity = 1
        }
    }
    
    func userButtonSetTitle(isTriangle: Bool, haptic: Bool) {
        if isTriangle {
            userButton.setTitle("     ▼", for: .normal)
        } else {
            userButton.setTitle(currentUser["display_name"].stringValue, for: .normal)
        }
        if haptic {
            Haptic.impact(.light).generate()
        }
    }
    
    
    func initialFirstLaunch() {
        
    }
    
    func initialFont() {
        if let fontName = Defaults[.fontName] {
            messageLabel.font = UIFont(name: fontName, size: 32)
            underView.initialFontSettingsUIStates()
        } else {
            // Is first launch
            Defaults[.fontIndex] = 0
            Defaults[.fontBold] = true
            Defaults[.fontItalic] = false
        }
    }
}

