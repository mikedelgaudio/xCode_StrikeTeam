//
//  GameViewController.swift
//  Strike Team
//
//  Created by Mike DelGaudio on 1/14/19.
//  Copyright © 2019 Mike DelGaudio. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    //If we make the audio here it will be throughout the game
    var backingAudio = AVAudioPlayer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background Audio
        let filePath = Bundle.main.path(forResource: "Backing Audio", ofType: "mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        do {
            backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL)
        }catch{
            return print("Cannot find the audio")
        }
        
        //Backing Audio will loop forever with -1
        backingAudio.numberOfLoops = -1
        //backingAudio.volume = 0 or 1 (try decimals)
        backingAudio.play()
        
        //Main Menu Screen
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            //SET THESE TO FALSE WHEN PUBLISHED
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
