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
    
    var mapNode = SKTileMapNode()
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    var maxScale: CGFloat = 0
    
    var rock = Rock(type: .red)
    let anchor = SKNode()
    
    override func didMove(to view: SKView) {
        setupLevel()
        setupGestureRecognizers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location  = touch.location(in: self)
            if rock.contains(location) {
                panRecognizer.isEnabled = false
                rock.grabbed = true
                rock.position = location
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if rock.grabbed {
                let location = touch.location(in: self)
                rock.position = location
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if rock.grabbed {
            rock.grabbed = false
            rock.flying = true
            constraintToAnchor(active: false)
            let dx = anchor.position.x - rock.position.x
            let dy = anchor.position.y - rock.position.y
            let impulse = CGVector(dx: dx, dy: dy)
            rock.physicsBody?.applyImpulse(impulse)
            rock.isUserInteractionEnabled = false
        }
    }
    
    func setupGestureRecognizers() {
        guard let view = view else { return }
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        view.addGestureRecognizer(panRecognizer)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func setupLevel() {
        if let mapNode = childNode(withName: "Tile Map Node") as? SKTileMapNode {
            self.mapNode = mapNode
            maxScale = mapNode.mapSize.width/frame.size.width
        }
        
        addCamera()
        anchor.position = CGPoint(x: mapNode.frame.midX/2, y: mapNode.frame.midY/2)
        addChild(anchor)
        addRock()
    }
    
    func addCamera() {
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
        gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
    }
    
    func addRock() {
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.categoryBitMask = PhysicsCategory.rock
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.all
        rock.physicsBody?.collisionBitMask = PhysicsCategory.block | PhysicsCategory.edge
        rock.physicsBody?.isDynamic = false
        rock.position = anchor.position
        addChild(rock)
        constraintToAnchor(active: true)
    }
    
    func constraintToAnchor(active: Bool) {
        if active {
            let slingRange = SKRange(lowerLimit: 0.0, upperLimit: rock.size.width*3)
            let positionConstraint = SKConstraint.distance(slingRange, to: anchor)
            rock.constraints = [positionConstraint]
        } else {
            rock.constraints?.removeAll()
        }
    }
}

extension GameScene {
    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = sender.translation(in: view) * gameCamera.yScale
        gameCamera.position = CGPoint(x: gameCamera.position.x - translation.x, y: gameCamera.position.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        guard let view = view else { return }
        if sender.numberOfTouches == 2 {
            let locationInView = sender.location(in: view)
            let location = convertPoint(fromView: locationInView)
            if sender.state == .changed {
                let convertedScale = 1/sender.scale
                let newScale = gameCamera.yScale*convertedScale
                if newScale < maxScale && newScale > 0.5 {
                    gameCamera.setScale(newScale)
                }
                
                let locationAfterScale = convertPoint(fromView: locationInView)
                let locationDelta = location - locationAfterScale
                let newPosition = gameCamera.position + locationDelta
                gameCamera.position = newPosition
                sender.scale = 1.0
                gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            }
        }
    }
}
