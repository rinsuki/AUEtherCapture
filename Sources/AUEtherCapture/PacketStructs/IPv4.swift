//
//  IPv4.swift
//  
//
//  Created by user on 2021/02/28.
//

import Foundation
import BinaryReader

struct IPv4 {
    var src: Address
    var dst: Address
    var content: Content
    
    enum Content: CustomStringConvertible {
        case udp(UDP)
        case unknown(UInt8)
        
        var description: String {
            switch self {
            case .udp(let udp):
                return String(describing: udp)
            case .unknown(let prot):
                return String(format: "Unknown(%d)", prot)
            }
        }
    }
    
    struct Address: CustomStringConvertible {
        var value: (UInt8, UInt8, UInt8, UInt8)
        
        var description: String {
            String(format: "%3d.%3d.___.___", value.0, value.1, value.2, value.3)
        }
    }
    
    init(from reader: inout BinaryReader) {
        let firstPointer = reader.pointer
        let versionAndIHL = reader.uint8()

        let ihl = versionAndIHL & 0x0F
        let length = ihl << 2

        let tos = reader.uint8()
        let totalLength = reader.uint16()
        let id = reader.uint16()
        // TODO: IPフラグメンテーションを考える必要がある？
        let flagsAndFragmentOffset = reader.uint16()
        let ttl = reader.uint8()
        let prot = reader.uint8()
        let checksum = reader.uint16()
        src = reader.ipv4()
        dst = reader.ipv4()
        let newPointer = firstPointer + UInt(length)
        reader.pointer = newPointer
        switch prot {
        case 17:
            content = .udp(.init(from: &reader))
        default:
            content = .unknown(prot)
        }
    }
}

private extension BinaryReader {
    mutating func ipv4() -> IPv4.Address {
        return .init(value: (uint8(), uint8(), uint8(), uint8()))
    }
}
