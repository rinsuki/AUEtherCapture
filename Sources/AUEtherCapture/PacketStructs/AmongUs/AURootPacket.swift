//
//  File.swift
//  
//
//  Created by user on 2021/03/01.
//

import Foundation
import BinaryReader

enum AURootPacket {
    case normal([AUHazelPacket])
    case reliable(UInt16, [AUHazelPacket])
    case hello(UInt16, hazelVersion: UInt8, clientVersion: Int32, name: String)
    case disconnect(forced: Bool, reason: UInt8, description: String?)
    case disconnectSimple
    case ack([UInt16])
    case ping(UInt16)
    
    init?(data: Data) {
        var reader = BinaryReader(data: data)
        reader.endian = .big
        let packetType = reader.uint8()
        switch packetType {
        case 0:
            var packets = [AUHazelPacket]()
            reader.endian = .little
            while reader.hasMoreData {
                packets.append(.init(from: &reader))
            }
            self = .normal(packets)
        case 1:
            let no = reader.uint16()
            var packets = [AUHazelPacket]()
            reader.endian = .little
            while reader.hasMoreData {
                packets.append(.init(from: &reader))
            }
            self = .reliable(no, packets)
        case 8:
            let id = reader.uint16()
            reader.endian = .little
            self = .hello(id, hazelVersion: reader.uint8(), clientVersion: reader.int32(), name: reader.str())
        case 9:
//            if reader.hasMoreData {
//                let forced = reader.uint8() == 1
//                let packetlen = reader.uint16()
//                reader.pointer += 1
//                let reason = reader.uint8()
//                let description = packetlen > 1 ? reader.str() : nil
//                self = .disconnect(forced: forced, reason: reason, description: description)
//            } else {
                self = .disconnectSimple
//            }
        case 0x0A:
            self = .ack([reader.uint16()])
        case 0xC:
            self = .ping(reader.uint16())
        default:
            return nil
        }
    }
}
