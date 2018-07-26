//
//  Level.swift
//  Slingshot
//
//  Created by user139990 on 7/26/18.
//  Copyright © 2018 Anish Ali. All rights reserved.
//

import Foundation

struct LevelData {
    let rocks: [String]
    
    init?(level: Int) {
        guard let levelDictionary = Levels.levelsDictionary["Level_\(level)"] as? [String:Any] else {
            return nil
        }
        guard let rocks = levelDictionary["Rocks"] as? [String] else {
            return nil
        }
        self.rocks = rocks
    }
}
