//
//  ViewController.swift
//  DNMOTD
//
//  Created by ray on 31/05/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import SwiftyJSON
import ReachabilitySwift
import SwiftyUserDefaults

var currentUser: JSON = []

extension DefaultsKeys {
    static let fontIndex = DefaultsKey<Int?>("fontIndex")
    static let fontBold = DefaultsKey<Bool?>("fontBold")
    static let fontItalic = DefaultsKey<Bool?>("fontItalic")
    static let fontName = DefaultsKey<String?>("fontName")
    static let isLaunchedBefore = DefaultsKey<Bool?>("isLaunchedBefore")
}

class MainViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var loadingEffectView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    let reachability = Reachability()!

    var ty: CGFloat {
        get { return containerView.transform.ty }
        set { containerView.transform.ty = newValue}
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initial()
        load()
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

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: containerView)
        }

        if let fontName = Defaults[.fontName] {
            messageLabel.font = UIFont(name: fontName, size: 32)
            underView.initialFontSettingsUIStates()
        } else {
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
            
            self.userButton.isSelected = false
            
            UIView.animate(withDuration: 0.5, animations: { 
                self.userButton.layer.opacity = 1
            })
            
            self.underView.renderUserProfile {
                if !Defaults["isLaunchedBefore"].boolValue {
                    self.showHint()
                    Defaults[.isLaunchedBefore] = true
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
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
            self.ty = self.ty == 0 ? 240 : 0
        }).startAnimation()
    }
    
    
    
    @IBAction func userButtonTapped(_ sender: Any) {
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
            self.userButton.isSelected = self.ty == 0
            self.ty = self.ty == 0 ? -self.underView.coverImage.frame.height : 0
        }).startAnimation()
        Haptic.impact(.light).generate()
    }


    @IBAction func messageLabelDidLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            UIPasteboard.general.string = messageLabel.text
            showToast(withTitle: "Copied", inView: view)
            Haptic.notification(.success).generate()
        }
    }

    @IBAction func containerViewOnDrag(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        let coverImageHeight = underView.coverImage.frame.height
        let settingsViewHeight = underView.settingsView.frame.maxY
        
        let isLoading = self.loadingEffectView.layer.opacity != 0
        let containerViewNotMoved = ty == 0.0
        
        if !isLoading {
            switch sender.state {
            case .began:
                beganDirection = sender.direction(in: view)
            
            case .changed:
                switch beganDirection {
                case .up, .down:
                    ty += translation.y / 1.2
                    sender.setTranslation(CGPoint.zero, in: view)
                case .left, .right:
                    if containerViewNotMoved {
                        circles.transform.tx = translation.x / 4
                    }
                }

            case .ended:

                let triggerProfileOpen = ty < -coverImageHeight / 2
                let triggerMenuOpen    = ty > settingsViewHeight / 2

                UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
                    if triggerProfileOpen {
                        self.ty = -coverImageHeight
                        self.userButton.isSelected = true
                    } else if triggerMenuOpen {
                        self.ty = settingsViewHeight
                    } else {
                        self.ty = 0
                        self.userButton.isSelected = false
                    }
                }).startAnimation()

                Haptic.impact(.light).generate()


                
                
                if (beganDirection == .left || beganDirection == .right) && containerViewNotMoved {
                    navigateDireaction = Int(-translation.x / abs(translation.x))
                    let willLoadID = currentID + navigateDireaction
                    let validPanDistance = abs(translation.x) >= 120
                    
                    if validPanDistance {
                        switch willLoadID {
                        case 0:
                            Haptic.notification(.error).generate()
                            showToast(withTitle: "This is the first one", inView: view)
                        case latestID + 1:
                            Haptic.notification(.error).generate()
                            showToast(withTitle: "This is the latest one", inView: view)
                        default:
                            currentID = willLoadID
                            renderMOTD()
                            Haptic.impact(.light).generate()
                        }
                    }

                    UIViewPropertyAnimator(duration: 0.1, dampingRatio: 1, animations: {
                        self.circles.transform.tx = 0
                    }).startAnimation()
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
                UIView.animate(withDuration: 0.2, animations: {
                    self?.contentView.alpha = 0
                }) { _ in
                    self?.messageLabel.font = font
                    UIView.animate(withDuration: 0.2) {
                        self?.contentView.alpha = 1
                    }
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
    }
    
    func stopLoadEffect(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingEffectView.layer.opacity = 0
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.menuButton.layer.opacity = 1
        }) { finished in
            completion?()
        }
    }
    
    
    func showHint(instantly: Bool = false) {
        delay(delay: instantly ? 0 : 2) { 
            self.performSegue(withIdentifier: "Show Hint Segue", sender: self)
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let message = "Current ID: \(currentID)\nLatest ID:\(latestID)"
            let alert = UIAlertController(title: "Go to Message by ID", message: message, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = String(currentID)
                textField.clearsOnBeginEditing = true
                textField.keyboardType = .numberPad
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { _ in
//                self.showHint(instantly: true)
            })
            let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
                let textField = alert.textFields!.first
                if let number = Int(textField!.text!), (1...latestID).contains(number) {
                    currentID = number
                    self.renderMOTD()
                    Haptic.impact(.light).generate()
                }
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}


extension MainViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        let regex = "(http[s]?:\\/\\/)([^:\\/\\s]+)((\\/\\w+)*\\/)?([^\\s\\[\\]\\(\\)\\<\\>\"\']+)([^\\s\\[\\]\\(\\)\\<\\>\"'.!?~,])([?&](\\S+\\=[\\w\\d\\-_@%+;]+))?(#[\\w\\-_=]+)?"
        let urls = messageLabel.text!.regex(regex)
        if urls.count > 0, let url = URL(string: urls.first!) {
            browserViewOpen(url: url)
        }
        return nil
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        showDetailViewController(viewControllerToCommit, sender: self)
    }
}
