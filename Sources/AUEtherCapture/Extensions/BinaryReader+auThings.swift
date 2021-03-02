//
//  File.swift
//  
//
//  Created by user on 2021/03/01.
//

import Foundation
import BinaryReader

extension BinaryReader {
    var hasMoreData: Bool {
        return data.count > pointer
    }
    
    var remainingBytes: Int {
        data.count - Int(pointer)
    }
    
    mutating func str() -> String {
        let len = uint8()
        let data = bytes(count: UInt(len))
        return String(data: data, encoding: .utf8)!
    }
    
    mutating func packedInt32() -> Int32 {
        return .init(bitPattern: packedUInt32())
    }
    
    mutating func packedUInt32() -> UInt32 {
        var current: UInt32 = 0
        var shift = 0
        var now: UInt8 = 0x80
        while now & 0x80 != 0 {
            now = uint8()
            current += UInt32(now & 0x7F) << shift
            shift += 7
        }
        return current
    }
    
    mutating func float32() -> Float32 {
        return Float32(bitPattern: uint32())
    }
}
