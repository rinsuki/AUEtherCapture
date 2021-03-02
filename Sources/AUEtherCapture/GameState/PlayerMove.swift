//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation

struct PlayerMove: Encodable {
    var type: MoveType
    var sequence: UInt16
    var playerID: Player.ID
    var timestamp: Double
    var position: Vector2
    var velocity: Vector2
    
    enum CodingKeys: String, CodingKey {
        case type
        case sequence = "seq"
        case playerID = "player"
        case timestamp
        case position
        case velocity
    }
}

extension PlayerMove {
    enum MoveType: String, Encodable {
        case normal
        case vents
    }
}
