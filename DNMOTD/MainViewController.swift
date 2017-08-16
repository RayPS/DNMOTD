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
            
            self.userButton.isSelected = false
            
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
        if ty == 0 {
            userButton.isSelected = true
            containerView.y = -underView.coverImage.frame.height
        } else {
            userButton.isSelected = false
            containerView.y = 0
        }
        Haptic.impact(.light).generate()
        containerView.animateTo()
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
        
        containerView.duration = 0.5
        
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

                UIView.animate(
                    withDuration: 0.5, delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.0,
                    options: [.allowUserInteraction],
                    animations: {

                        let triggerProfileOpen = ty < -coverImageHeight / 2
                        let triggerMenuOpen    = ty > settingsViewHeight / 2

                        if triggerProfileOpen {
                            self.containerView.transform.ty = -coverImageHeight
                            self.userButton.isSelected = true
                        } else if triggerMenuOpen {
                            self.containerView.transform.ty = settingsViewHeight
                        } else {
                            self.containerView.transform.ty = 0
                            self.userButton.isSelected = false
                        }
                    }
                )

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
//            showHint(instantly: true)
            let message = "Current ID: \(currentID)\nLatest ID:\(latestID)"
            let alert = UIAlertController(title: "Go to Message by ID", message: message, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = String(currentID)
                textField.clearsOnBeginEditing = true
                textField.keyboardType = .numberPad
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { _ in

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
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController else { return nil }
//        vc.preferredContentSize = CGSize(width: 0, height: 0)
//        return vc
        let regex = "(http[s]?:\\/\\/)([^:\\/\\s]+)((\\/\\w+)*\\/)?([^\\s\\[\\]\\(\\)\\<\\>\"\']+)([^\\s\\[\\]\\(\\)\\<\\>\"'.!?~,])([?&](\\S+\\=[\\w\\d\\-_@%+;]+))?(#[\\w\\-_=]+)?"
        let urls = messageLabel.text!.regex(regex)
        if urls.count > 0, let url = URL(string: urls.first!) {
            print(url)
        }
        return nil
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        showDetailViewController(viewControllerToCommit, sender: self)
    }
}
