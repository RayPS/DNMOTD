//
//  TutorialViewController.swift
//  DNMOTD
//
//  Created by Ray on 30/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import Spring
import AVFoundation

class HintViewController: UIViewController {

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


















import StoreKit

class AboutViewController: UIViewController {

    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        reviewButton.layer.cornerRadius = 4
        rateButton.layer.cornerRadius = 4
    }


    @IBAction func panelSwiped(_ sender: UISwipeGestureRecognizer) {
            self.dismiss(animated: true)
    }

    @IBAction func rateButtonTapped(_ sender: UIButton) {
        SKStoreReviewController.requestReview()
    }

    @IBAction func reviewButtonTapped(_ sender: UIButton) {
        let id = "1255404339"
        if let url = URL(string: "itms-apps://itunes.apple.com/us/app/id\(id)?action=write-review") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}


















class WidgetIntroViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!

    fileprivate var player: AVPlayer? {
        didSet { player?.play() }
    }

    fileprivate var playerObserver: Any?

    deinit {
        guard let observer = playerObserver else { return }
        NotificationCenter.default.removeObserver(observer)
    }

    func videoPlayerLayer(fileURL: URL) -> AVPlayerLayer {
        let player = AVPlayer(url: fileURL)
        let resetPlayer = {
            player.seek(to: kCMTimeZero)
            player.play()
        }
        playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
            resetPlayer()
        }
        self.player = player
        return AVPlayerLayer(player: player)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        videoView.backgroundColor = UIColor.clear
        let url = Bundle.main.url(forResource: "Widget-Intro", withExtension: "mov")
        let playerLayer = videoPlayerLayer(fileURL: url!)
        playerLayer.frame = videoView.bounds
        videoView.layer.insertSublayer(playerLayer, at: 0)
    }


    @IBAction func panelSwiped(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true)
    }
}