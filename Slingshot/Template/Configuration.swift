//
//  Configuration.swift
//  Slingshot
//
//  Created by user139990 on 6/28/18.
//  Copyright © 2018 Anish Ali. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    
    static public func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
}
