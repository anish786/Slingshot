//
//  Rock.swift
//  Slingshot
//
//  Created by user139990 on 6/28/18.
//  Copyright © 2018 Anish Ali. All rights reserved.
//

import SpriteKit


enum RockType: String {
    case red, blue, yellow, gray
}
class Rock: SKSpriteNode {
    
    let rockType: RockType
    var grabbed = false
    var flying = false {
        didSet {
            if flying {
                physicsBody?.isDynamic = true
                animateFlight(active: true)
            } else {
                animateFlight(active: false)
            }
        }
    }
    
    let flyingFrames: [SKTexture]
    
    
    init(type: RockType) {
        rockType = type
        flyingFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: type.rawValue), withName: type.rawValue)
        let texture = SKTexture(imageNamed: type.rawValue + "1")

        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateFlight(active: Bool) {
        if active {
            run(SKAction.repeatForever(SKAction.animate(with: flyingFrames, timePerFrame: 0.1, resize: true, restore: true)))
        } else {
            removeAllActions()
        }
    }
}
