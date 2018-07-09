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
            }
        }
    }
    
    init(type: RockType) {
        rockType = type
        
        let texture = SKTexture(imageNamed: type.rawValue + "1")

        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
