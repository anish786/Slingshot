//
//  GameScene.swift
//  Slingshot
//
//  Created by user139990 on 6/26/18.
//  Copyright © 2018 Anish Ali. All rights reserved.
//

import SpriteKit
import GameplayKit


enum RoundState {
    case ready, flying, finished, animating
}

class GameScene: SKScene {
    
    var sceneManagerDelegate: SceneManagerDelegate?
    
    var mapNode = SKTileMapNode()
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    var maxScale: CGFloat = 0
    
    var rock = Rock(type: .red)
    var rocks = [
        Rock(type: .red),
        Rock(type: .blue),
        Rock(type: .yellow)
    ]
    let anchor = SKNode()
    
    var roundState = RoundState.ready
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupLevel()
        setupGestureRecognizers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch roundState {
        case .ready:
            if let touch = touches.first {
                let location  = touch.location(in: self)
                if rock.contains(location) {
                    panRecognizer.isEnabled = false
                    rock.grabbed = true
                    rock.position = location
                }
            }
        case .flying:
            break
        case .finished:
            guard let view = view else { return }
            roundState = .animating
            let moveCameraBackAction = SKAction.move(to: CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2), duration: 2.0)
            moveCameraBackAction.timingMode = .easeInEaseOut
            gameCamera.run(moveCameraBackAction, completion: {
                self.panRecognizer.isEnabled = true
                self.addRock()
            })
        case .animating:
            break
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
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: rock)
            rock.grabbed = false
            rock.flying = true
            roundState = .flying
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
        
        for child in mapNode.children {
            if let child = child as? SKSpriteNode {
                guard let name = child.name else { continue }
                if !["wood", "strone","glass"].contains(name) { continue }
                guard let type = BlockType(rawValue: name) else { continue }
                let block = Block(type: type)
                block.size = child.size
                block.position = child.position
                block.zRotation = child.zRotation
                block.zPosition = ZPosition.obstacles
                block.createPhysicsBody()
                mapNode.addChild(block)
                child.removeFromParent()
            }
        }
        
        addCamera()
        
        let physicsRect = CGRect(x: 0, y: mapNode.tileSize.height, width: mapNode.frame.size.width, height: mapNode.frame.size.height - mapNode.tileSize.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: physicsRect)
        physicsBody?.categoryBitMask = PhysicsCategory.edge
        physicsBody?.contactTestBitMask = PhysicsCategory.rock | PhysicsCategory.block
        physicsBody?.collisionBitMask = PhysicsCategory.all
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
        if rocks.isEmpty {
            print("No more rocks")
            return
        }
        rock = rocks.removeFirst()
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.categoryBitMask = PhysicsCategory.rock
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.all
        rock.physicsBody?.collisionBitMask = PhysicsCategory.block | PhysicsCategory.edge
        rock.physicsBody?.isDynamic = false
        rock.position = anchor.position
        addChild(rock)
        rock.aspectScale(to: mapNode.tileSize, width: false, multiplier: 1.0)
        constraintToAnchor(active: true)
        roundState = .ready
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
    
    override func didSimulatePhysics() {
        guard let physicsBody = rock.physicsBody else { return }
        if roundState == .flying && physicsBody.isResting {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            rock.removeFromParent()
            roundState = .finished
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        //when rock collides with the block, damage it based on the force
        case PhysicsCategory.rock | PhysicsCategory.block, PhysicsCategory.block | PhysicsCategory.edge:
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            } else if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
        //when block collides with the block
        case PhysicsCategory.block | PhysicsCategory.block:
            if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
        case PhysicsCategory.rock | PhysicsCategory.edge:
            rock.flying = false
        default:
            break;
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
