//
//  File.swift
//  
//
//  Created by user on 2021/03/03.
//

import Foundation

extension InnerNetObject {
    struct SpawnType: RawRepresentable, Equatable {
        static let gameData = SpawnType(rawValue: 3)
        static let playerControl = SpawnType(rawValue: 4)
        
        typealias RawValue = UInt32
        var rawValue: RawValue
    }
}
