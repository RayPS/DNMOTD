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
import Haptica

class ViewController: UIViewController {

    @IBOutlet weak var containerView: SpringView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var loadingEffectView: UIView!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    let screenWidth = Int(UIScreen.main.bounds.width)
    let screenHeight = Int(UIScreen.main.bounds.height)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Reachability for first launch
        // TODO: Font settings
        // TODO: About
        // TODO: Haptic feedback
        
        initial()
    }
    
    
    func initial() {
        messageLabel.layer.opacity = 0
        votesLabel.layer.opacity = 0
        dotButton.layer.opacity = 0
        userButton.layer.opacity = 0
        
        
        Loader.addLoadersTo(loadingEffectView)

        getlatestID {
            currentID = latestID
            self.renderMOTD()
        }
        
        createCircle()
    }
    
    
    func renderMOTD() {
        
        startLoadEffect()
        
        getMOTD(byID: currentID, completion: { (json) in
            
            let motd      = json["motds"][0]
            let message   = motd["message"].stringValue
            let upvotes   = motd["links"]["upvotes"]
            let downvotes = motd["links"]["downvotes"]
            let userid    = motd["links"]["user"].intValue
            
            debugPrint(message)
            
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
            
            self.userButtonSetTitle(isTriangle: false)
            
            UIView.animate(withDuration: 0.5, animations: { 
                self.userButton.layer.opacity = 1
            })
            
            self.renderUserProfile()
        })
    }
    
    
    func renderUserProfile() {
        let first_name = currentUser["first_name"].stringValue
        let last_name = currentUser["last_name"].stringValue
        let full_name = first_name + " " + last_name
        
        fullnameLabel.text = full_name
        jobLabel.text = currentUser["job"].stringValue
        
        coverImage.kf.setImage(with: URL(string: currentUser["cover_photo_url"].stringValue))
        avatarImage.kf.setImage(with: URL(string: currentUser["portrait_url"].stringValue))
    }
    
    
    
    
    
    
    
    
    
    @IBAction func userButtonTapped(_ sender: Any) {
        if containerView.frame.origin.y == 0 {
            userButtonSetTitle(isTriangle: true)
            containerView.y = -coverImage.frame.height
            containerView.animateTo()
        } else {
            userButtonSetTitle(isTriangle: false)
            containerView.y = 0
            containerView.animateTo()
        }
    }
    
    
    
    
    @IBAction func test(_ sender: Any) {
        currentID -= 1
        renderMOTD()
    }
    
    
    @IBAction func containerViewOnDrag(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        let direction = sender.direction(in: view)
        
        let coverImageHeight = coverImage.frame.height
        
        let triggerOpen = containerView.transform.ty <= -50
        let triggerClose = containerView.transform.ty >= -coverImageHeight + 50
        
        let dragEnded = sender.state == .ended
        
        let hasUp    = direction.contains(.Up)
        let hasDown  = direction.contains(.Down)
//        let hasLeft  = direction.contains(.Left)
//        let hasRight = direction.contains(.Right)
        
        let ty = containerView.transform.ty
        let isVerticalDrag = abs(velocity.y) > abs(velocity.x)
        
        
        if isVerticalDrag {
            containerView.transform = CGAffineTransform(
                translationX: 0,
                y: ty + translation.y / 1.5
            )
        } else {
            
        }
        
        if dragEnded && ty != 0 {
            if hasUp && triggerOpen || hasDown && !triggerClose {
                containerView.y = -coverImageHeight
                userButtonSetTitle(isTriangle: true)
            } else if hasDown && triggerClose || hasUp && !triggerOpen {
                containerView.y = 0
                userButtonSetTitle(isTriangle: false)
            }
            containerView.animateTo()
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }

    
    
    
    
    
    // Animation Functions:
    
    func createCircle() {
        let size: Int = 200
        let frame = CGRect(x: -size / 2, y: screenHeight / 2 - size / 2, width: size, height: size)
        let circle = SpringView(frame: frame)
        circle.backgroundColor = UIColor.black
        circle.layer.cornerRadius = CGFloat(size / 2)
        circle.scaleX = 0
        circle.scaleY = 0
        circle.duration = 0
        circle.animateTo()
        view.addSubview(circle)
        
    }

    func showMessageLabel() {
        UIView.animate(withDuration: 0.5) {
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.dotButton.layer.opacity = 1
        }
    }
    
    func startLoadEffect() {
        UIView.animate(withDuration: 0.2) { 
            self.loadingEffectView.layer.opacity = 1
            self.messageLabel.layer.opacity = 0
            self.votesLabel.layer.opacity = 0
            self.dotButton.layer.opacity = 0
            self.userButton.layer.opacity = 0
        }
    }
    
    func stopLoadEffect() {
        UIView.animate(withDuration: 0.2) {
            self.loadingEffectView.layer.opacity = 0
            self.messageLabel.layer.opacity = 1
            self.votesLabel.layer.opacity = 1
            self.dotButton.layer.opacity = 1
        }
    }
    
    func userButtonSetTitle(isTriangle: Bool) {
        if isTriangle {
            userButton.setTitle("     ▼", for: .normal)
        } else {
            userButton.setTitle(currentUser["display_name"].stringValue, for: .normal)
        }
        Haptic.impact(.light).generate()
    }
}

