//
//  MACAddress.swift
//  
//
//  Created by user on 2021/02/28.
//

import Foundation
import BinaryReader

struct MACAddress{
    var vendor0: UInt8
    var vendor1: UInt8
    var vendor2: UInt8
    var machine: UInt8
    var serial0: UInt8
    var serial1: UInt8
    
    init(from reader: inout BinaryReader) {
        vendor0 = reader.uint8()
        vendor1 = reader.uint8()
        vendor2 = reader.uint8()
        machine = reader.uint8()
        serial0 = reader.uint8()
        serial1 = reader.uint8()
    }
}

extension MACAddress: CustomStringConvertible {
    var description: String {
        String(format: "%02X:%02X:%02X:__:__:__", vendor0, vendor1, vendor2, machine, serial0, serial1)
    }
}
