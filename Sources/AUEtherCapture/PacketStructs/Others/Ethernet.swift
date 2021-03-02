//
//  Ethernet.swift
//  
//
//  Created by user on 2021/02/28.
//

import Foundation
import BinaryReader

struct Ethernet {
    var src: MACAddress
    var dst: MACAddress
    var content: Ethernet.Content
    
    enum Content: CustomStringConvertible {
        case ipv4(IPv4)
        case ipv6
        case unknown(UInt16)
        
        var description: String {
            switch self {
            case .ipv4(let ipv4):
                return String(describing: ipv4)
            case .ipv6:
                return "IPv6"
            case .unknown(let prot):
                return String(format: "Unknown(%04x)", prot)
            }
        }
    }
    
    init(from data: Data) {
        var reader = BinaryReader(data: data, endian: .big)
        src = .init(from: &reader)
        dst = .init(from: &reader)
        let prot = reader.uint16()
        switch prot {
        case 0x0800: // IPv4
            content = .ipv4(.init(from: &reader))
        case 0x86DD: // IPv6
            content = .ipv6
        default:
            content = .unknown(prot)
        }
    }
}
