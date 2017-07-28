//
//  ViewController.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import SwiftyJSON
import Spring
import ReachabilitySwift
import SwiftyUserDefaults

var currentUser: JSON = []

extension DefaultsKeys {
    static let fontIndex = DefaultsKey<Int?>("fontIndex")
    static let fontBold = DefaultsKey<Bool?>("fontBold")
    static let fontItalic = DefaultsKey<Bool?>("fontItalic")
    static let fontName = DefaultsKey<String?>("fontName")
}

class MainViewController: UIViewController {

    @IBOutlet weak var containerView: SpringView!
    @IBOutlet weak var contentView: SpringView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var loadingEffectView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    let reachability = Reachability()!
    
    var isFirstLaunch = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initial()
        load()
        
        //                    TODO: ParseMedia





    }

    func load() {
        networkCheck {
            getlatestID {
                currentID = latestID
                self.renderMOTD()
            }
        }
    }

    var underView: UnderContainerViewController!
    
    func initial() {
        messageLabel.layer.opacity = 0
        votesLabel.layer.opacity = 0
        menuButton.layer.opacity = 0
        userButton.layer.opacity = 0

        drawCircles()
        
        Loader.addLoadersTo(loadingEffectView)

        if let fontName = Defaults[.fontName] {
            messageLabel.font = UIFont(name: fontName, size: 32)
            underView.initialFontSettingsUIStates()
        } else {
            isFirstLaunch = true
            Defaults[.fontIndex] = 0
            Defaults[.fontBold] = true
            Defaults[.fontItalic] = false
        }
    }
    
    
    func networkCheck(success: @escaping() -> Void) {
        if reachability.isReachable {
            success()
        } else {
            print("else")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Network Error", message: "Please check your network configurations.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { alert in
                    self.load()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }


    func renderMOTD() {
        
        startLoadEffect()

        getMOTD(byID: currentID) { data in

            let json = JSON(data: data)

            let motd      = json["motds"][0]
            let message   = motd["message"].stringValue
            let upvotes   = motd["links"]["upvotes"]
            let downvotes = motd["links"]["downvotes"]
            let userid    = motd["links"]["user"].intValue
            
            print("#\(currentID) / \(latestID): \n\(message)\n")
            
            self.messageLabel.text = message
            self.votesLabel.text = "+\(upvotes.count) / -\(downvotes.count)"

            self.stopLoadEffect()
            
            self.renderUserButton(byID: userid)
        }
    }


    func renderUserButton(byID id: Int) {
        
        getUser(byID: id){ data in

            let json = JSON(data: data)

            currentUser = json["users"][0]
            
            self.userButtonSetTitle(isTriangle: false, haptic: false)
            
            UIView.animate(withDuration: 0.5, animations: { 
                self.userButton.layer.opacity = 1
            })
            
            self.underView.renderUserProfile {
                if self.isFirstLaunch {
                    self.showHint()
                }
            }
        }
    }


    let circles = UIView()

    func drawCircles() {

        let circleSize: CGFloat = 200.0

        view.addSubview(circles)
        circles.isUserInteractionEnabled = false

        circles.translatesAutoresizingMaskIntoConstraints = false
        circles.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: circleSize * 2).isActive = true
        circles.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
        circles.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        circles.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


        let circleLeft = UIView()
        circles.addSubview(circleLeft)
        circleLeft.backgroundColor = .black
        circleLeft.layer.cornerRadius = circleSize / 2

        circleLeft.translatesAutoresizingMaskIntoConstraints = false
        circleLeft.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
        circleLeft.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
        circleLeft.centerYAnchor.constraint(equalTo: circles.centerYAnchor).isActive = true
        circleLeft.leftAnchor.constraint(equalTo: circles.leftAnchor).isActive = true


        let circleRight = UIView()
        circles.addSubview(circleRight)
        circleRight.backgroundColor = .black
        circleRight.layer.cornerRadius = circleSize / 2

        circleRight.translatesAutoresizingMaskIntoConstraints = false
        circleRight.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
        circleRight.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
        circleRight.centerYAnchor.constraint(equalTo: circles.centerYAnchor).isActive = true
        circleRight.rightAnchor.constraint(equalTo: circles.rightAnchor).isActive = true
    }






    // IBActions
    
    
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
                        circles.transform.tx = translation.x / 4
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
                            showToast(withTitle: "This is the last one", inView: view)
                        }
                    }

                    UIView.animate(withDuration: 0.1) {
                        self.circles.transform.tx = 0
                    }
                }

                
            default:
                break
            }
        }
    }
    
    
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

    
    
    
    
    
    // Animation Functions:
    
    func startLoadEffect(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingEffectView.layer.opacity = 1
            self.messageLabel.layer.opacity = 0
            self.votesLabel.layer.opacity = 0
            self.menuButton.layer.opacity = 0
            self.userButton.layer.opacity = 0
        }) { finished in
            completion?()
        }

        delay(delay: 0.1) {
            self.loadingEffectView.layer.opacity = 1
        }
    }
    
    func stopLoadEffect(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
//            self.loadingEffectView.layer.opacity = 0
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.menuButton.layer.opacity = 1
        }) { finished in
            completion?()
        }

        delay(delay: 0.1) {
            self.loadingEffectView.layer.opacity = 0
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
    
    
    func showHint(instantly: Bool = false) {
        delay(delay: instantly ? 0 : 2) { 
            self.performSegue(withIdentifier: "Show Hint Segue", sender: self)
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showHint(instantly: true)
        }
    }
    
    
}

