//
//  GameScene.swift
//  Slingshot
//
//  Created by user139990 on 6/26/18.
//  Copyright © 2018 Anish Ali. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameCamera = SKCameraNode()
    var panRecognizer = UIPanGestureRecognizer()
    
    override func didMove(to view: SKView) {
        addCamera()
        setupGestureRecognizers()
    }
    
    func setupGestureRecognizers() {
        guard let view = view else { return }
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        view.addGestureRecognizer(panRecognizer)
    }
    func addCamera() {
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
    }
}

extension GameScene {
    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = sender.translation(in: view)
        gameCamera.position = CGPoint(x: gameCamera.position.x - translation.x, y: gameCamera.position.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
    }
}
