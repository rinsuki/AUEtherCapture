//
//  File.swift
//  
//
//  Created by user on 2021/03/01.
//

import Foundation
import BinaryReader

struct Ack: Hashable {
    var pair: UDPPair
    var no: UInt16
}

struct GameState {
    var id: Int32 = 0
}

struct CaptureState {
    var ackStore = Set<Ack>()
    var callAfterFinishCurrentPacket = [() -> Void]()
    var timestamp: Double = 0
    var gameState = GameState()
    
    mutating func handleACK(ack: Ack) -> Bool {
        if ackStore.contains(ack) {
            return false
        }
        ackStore.insert(ack)
        return true
    }
    
    mutating func handle(data: Data, pair: UDPPair) {
        guard let packet = AURootPacket(data: data) else {
            print(data.map { String(format: "%02X", $0) }.joined())
            return
        }
        defer {
            while let fn = callAfterFinishCurrentPacket.popLast() {
                fn()
            }
        }
        switch packet {
        case .reliable(let ack, let packets):
            guard handleACK(ack: .init(pair: pair, no: ack)) else {
                break
            }
            fallthrough
        case .normal(let packets):
            for packet in packets {
                handleHazel(packet: packet)
            }
        case .hello(let ack, hazelVersion: let hazelVersion, clientVersion: let clientVersion, name: let name):
            guard handleACK(ack: .init(pair: pair, no: ack)) else {
                break
            }
            print(packet)
//        case .disconnect(forced: let forced, reason: let reason, description: let description):
//            <#code#>
//        case .disconnectSimple:
//            <#code#>
        case .ack(let ack):
            for ack in ack {
                let ack = Ack(pair: pair.reversed(), no: ack)
                if !ackStore.contains(ack) {
                    print("ACK BUT NOT RECEIVED", ack.no)
                }
                ackStore.remove(ack)
            }
        case .ping(let ack):
            handleACK(ack: .init(pair: pair, no: ack))
        default:
            print(packet)
        }
    }
    
    mutating func handleHazel(packet: AUHazelPacket) {
        var reader = BinaryReader(data: packet.data)
        switch packet.type {
        case 5:
            let id = reader.int32()
            gameState.id = id
            handleGameDataArray(&reader)
        case 6:
            let id = reader.int32()
            let targetID = reader.packedInt32()
            gameState.id = id
            handleGameDataArray(&reader)
        case 7: // JoinedGame
            print("Reset State")
            gameState = .init()
        default:
            print(packet)
        }
    }
    
    mutating func handleGameDataArray(_ reader: inout BinaryReader) {
        while reader.hasMoreData {
            let hazel = AUHazelPacket(from: &reader)
            print("GameData", hazel)
            handleGameData(hazel)
        }
    }
    
    mutating func handleGameData(_ packet: AUHazelPacket) {
        switch packet.type {
        
        default:
            print(packet)
        }
    }
}
