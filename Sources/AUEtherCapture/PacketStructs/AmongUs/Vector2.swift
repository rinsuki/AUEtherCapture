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

extension Vector2 {
    private static func lerp(_ input: Double) -> Double {
        let i = min(max(input, 0), 1)
        return (-40) + (80 * i)
    }
    
    init(from reader: inout BinaryReader) {
        let rawX = reader.uint16()
        let rawY = reader.uint16()
        
        x = rawX == 0x7FFF ? 0 : Self.lerp(Double(rawX) / 65535.0)
        y = rawY == 0x7FFF ? 0 : Self.lerp(Double(rawY) / 65535.0)
    }
}
