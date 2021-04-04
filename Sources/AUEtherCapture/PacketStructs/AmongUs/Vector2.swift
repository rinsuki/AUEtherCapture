//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation
import BinaryReader

struct Vector2: Encodable {
    var x: Double
    var y: Double
    
    static let zero = Vector2(x: 0, y: 0)
}

let VECTOR2_FLOAT_RANGES_CHANGED_VERSION = 50530650 // maybe more old

extension Vector2 {
    private static func lerp(_ input: Double, clientVersion: Int32) -> Double {
        let i = min(max(input, 0), 1)
        if clientVersion >= VECTOR2_FLOAT_RANGES_CHANGED_VERSION || clientVersion == 0 /* clientVersion == 0 fallback to latest version */ {
            return (-50) + (100 * i)
        } else {
            return (-40) + (80 * i)
        }
    }
    
    init(from reader: inout BinaryReader, clientVersion: Int32) {
        let rawX = reader.uint16()
        let rawY = reader.uint16()
        
        x = rawX == 0x7FFF ? 0 : Self.lerp(Double(rawX) / 65535.0, clientVersion: clientVersion)
        y = rawY == 0x7FFF ? 0 : Self.lerp(Double(rawY) / 65535.0, clientVersion: clientVersion)
    }
}
