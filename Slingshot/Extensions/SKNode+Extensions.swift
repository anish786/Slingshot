//
//  SKNode+Extensions.swift
//  Slingshot
//
//  Created by user139990 on 7/9/18.
//  Copyright © 2018 Anish Ali. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    func aspectScale(to size: CGSize, width: Bool, multiplier: CGFloat) {
        let scale = width ? (size.width * multiplier) / self.frame.size.width : (size.height * multiplier) / self.frame.size.height
        self.setScale(scale)
    }
    
}
