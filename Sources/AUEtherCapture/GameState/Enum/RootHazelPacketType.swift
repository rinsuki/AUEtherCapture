//
//  File.swift
//  
//
//  Created by user on 2021/03/03.
//

import Foundation

enum RootHazelPacketType: UInt8 {
    case gameData = 0x05
    case gameDataTo = 0x06
    case joinedGame = 0x07
    case endGame = 0x08
}
