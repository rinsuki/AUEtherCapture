//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation
import BinaryReader

struct Player: Encodable {
    typealias ID = UInt8
    let id: ID
    var name: String = "???"
    var color: Color
    var deadAt: Double?
    var disconnectedAt: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
        case deadAt = "dead_at"
        case disconnectedAt = "disconnected_at"
    }
    
    func shouldNotifyToAutoMuteUs(old: Player) -> Bool {
        return id != old.id || name != old.name || color != old.color || deadAt != old.deadAt || disconnectedAt != old.disconnectedAt
    }
}

extension Player {
    init(from reader: inout BinaryReader, update: Bool) {
        let len = update ? reader.uint16() : 0
        let endPointer = update ? reader.pointer + UInt(len + 1) : nil
        id = reader.uint8()
        name = reader.str()
        let colorID = reader.packedInt32()
        if colorID < 0 {
            color = .unknown
        } else {
            color = Player.Color(rawValue: .init(colorID))!
        }
        _ = reader.packedUInt32() // hat
        _ = reader.packedUInt32() // pet
        _ = reader.packedUInt32() // skin
        _ = reader.uint8() // flags
        let tasksLength = reader.uint8()
        for _ in 0..<tasksLength {
            _ = reader.packedUInt32() // task id
            _ = reader.bool() // completed?
        }
        if let pointer = endPointer {
            reader.pointer = pointer
        }
    }
}
