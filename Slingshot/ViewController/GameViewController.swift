//
//  GameViewController.swift
//  Slingshot
//
//  Created by user139990 on 6/26/18.
//  Copyright © 2018 Anish Ali. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol SceneManagerDelegate {
    func presentMenuScene()
    func presentLevelScene()
    func presentGameSceneFor(level: Int)
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        presentMenuScene()
    }
}

extension GameViewController: SceneManagerDelegate {
    func presentMenuScene() {
        let menuScene = MenuScene()
        menuScene.sceneManagerDelegate = self
        present(scene: menuScene)
    }
    
    func presentLevelScene() {
        let levelScene = LevelScene()
        levelScene.sceneManagerDelegate = self
        present(scene: levelScene)
    }
    
    func presentGameSceneFor(level: Int) {
        let sceneName = "GameScene_\(level)"
        if let gameScene = SKScene(fileNamed: sceneName) as? GameScene {
            gameScene.sceneManagerDelegate = self
            gameScene.level = level
            present(scene: gameScene)
        }
    }
    
    func present(scene: SKScene) {
        if let view = self.view as! SKView? {
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }
    }
    
}
