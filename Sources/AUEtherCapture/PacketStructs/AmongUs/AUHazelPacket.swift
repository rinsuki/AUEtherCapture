//
//  File.swift
//  
//
//  Created by user on 2021/03/01.
//

import Foundation
import BinaryReader

struct AUHazelPacket {
    var type: UInt8
    var data: Data
    
    init(from reader: inout BinaryReader) {
        let len = reader.uint16()
        type = reader.uint8()
        data = reader.bytes(count: UInt(len))
    }
}
