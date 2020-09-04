//
//  ViewController.swift
//  Kea
//
//  Created by Anmol Raibhandare on 8/31/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: Variables
    
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpVideo()
    }
        
    func setUpElements() {

        // Style UI Elements
        Utilities.styleFilledButton(signUpButton)
//        Utilities.styleHollowButton(loginButton)
    }
    
    func setUpVideo() {
        
        // Get the path to the resource in the bundle
        let bundlePath = Bundle.main.path(forResource: "viewControllerVideo", ofType: "mp4")
        
        guard bundlePath != nil else {
            return
        }
        
        // Create URL
        let url = URL(fileURLWithPath: bundlePath!)
        
        // Create the video player item
        let item = AVPlayerItem(url: url)

        // Create the player
        videoPlayer = AVPlayer(playerItem: item)
        
        // Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        // Adjust size and frame
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height/2)
        
        // Insert Player layer
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        // Display and Play
        videoPlayer?.playImmediately(atRate: 0.5)
    }
}

