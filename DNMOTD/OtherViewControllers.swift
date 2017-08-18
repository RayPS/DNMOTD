//
//  TutorialViewController.swift
//  DNMOTD
//
//  Created by Ray on 30/06/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit
import AVFoundation

class HintViewController: UIViewController {

    @IBOutlet weak var hintView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.window?.backgroundColor = UIColor.clear

        hintView.layer.cornerRadius = 128
        hintView.alpha = 0
        hintView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
            self.hintView.alpha = 1
            self.hintView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }).startAnimation()
    }

    @IBAction func viewOnPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1, animations: {
                self.hintView.alpha = 0
                self.hintView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }).startAnimation()
            dismiss(animated: true, completion: nil)
        }
    }
    
}


















import StoreKit

class AboutViewController: UIViewController {

    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var clearCacheButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        reviewButton.layer.cornerRadius = 4
        rateButton.layer.cornerRadius = 4
        clearCacheButtonSetSize()
    }


    @IBAction func panelSwiped(_ sender: UISwipeGestureRecognizer) {
            self.dismiss(animated: true)
    }

    @IBAction func websiteButtonTapped(_ sender: Any) {
        if let url = URL(string: "http://rayps.com") {
            UIApplication.shared.open(url)
        }
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

    @IBAction func clearCacheButtonTapped(_ sender: Any) {
        motdsCache.removeAll()
        usersCache.removeAll()
        clearCacheButtonSetSize()
        showToast(withTitle: "👌", inView: view)
        Haptic.impact(.light).generate()
    }

    @IBAction func exit(_ sender: Any) {
        dismiss(animated: true)
    }

    func clearCacheButtonSetSize(){
        let size = ByteCountFormatter.string(
            fromByteCount: Int64(motdsCache.size + usersCache.size),
            countStyle: ByteCountFormatter.CountStyle.decimal
        )
        let title = String(format: "↺ Clear Cache (%@)", size)
        clearCacheButton.setTitle(title, for: .normal)
    }
}


















class WidgetIntroViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!

    var playerLayer = AVPlayerLayer()

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
        playerLayer = videoPlayerLayer(fileURL: url!)
        videoView.layer.insertSublayer(playerLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        playerLayer.frame = videoView.bounds
    }


    @IBAction func panelSwiped(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func exit(_ sender: Any) {
        dismiss(animated: true)
    }
}



import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var safariOpenButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!

    @IBOutlet weak var webViewFrame: UIView!

    @IBOutlet var UIVisualEffectViews: [UIVisualEffectView]! {
        didSet {
            for v in UIVisualEffectViews {
                v.layer.cornerRadius = 8
                v.clipsToBounds = true
            }
        }
    }

    var webView: WKWebView!
    var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: webViewFrame.frame)
        view.insertSubview(webView, at: 0)

        webView.clipsToBounds = false
        webView.scrollView.clipsToBounds = false

        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    override func viewDidAppear(_ animated: Bool) {
        progressBar.setProgress(0.1, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if webView.observationInfo != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressBar.setProgress(progress, animated: true)
        }

    }

    @IBAction func openInSafari(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        UIApplication.shared.open(url)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressBar.alpha = 1
        print("Start loading URL: ", url)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.alpha = 0
        progressBar.setProgress(0.0, animated: false)
        webView.evaluateJavaScript("window.scrollTo(0, 0)")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        backButton.superview!.superview!.alpha = webView.canGoBack ? 1 : 0
    }
}

extension UIViewController {
    func browserView(withURL url: URL!) -> UIViewController {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        vc.url = url
        return vc
    }
}







