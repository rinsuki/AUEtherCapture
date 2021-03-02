//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation
import BinaryReader

class InnerNetObject {
    internal init(spawnType: UInt32, ownerID: Int32, spawnFlag: UInt8) {
        self.spawnType = .init(rawValue: spawnType)
        self.ownerID = ownerID
        self.spawnFlag = spawnFlag
    }
    
    var spawnType: SpawnType
    var ownerID: Int32
    var spawnFlag: UInt8
    var components = [InnerNetComponent]()
    
    var playerID: Player.ID? {
        guard spawnType == .playerControl else {
            return nil
        }
        var reader = BinaryReader(data: components[0].spawnData)
        reader.pointer += 1
        return reader.uint8()
    }
}
