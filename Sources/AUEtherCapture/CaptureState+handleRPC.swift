//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation
import BinaryReader

extension CaptureState {
    mutating func handleRPC(senderID: UInt32, rpcType: UInt8, reader: inout BinaryReader) {
        guard let sender = gameState.components[senderID]?.obj else {
            return
        }
        let timestamp = self.timestamp - gameState.startedAt
        switch RPCType(rawValue: rpcType) {
        case .setInfected: // SetInfected
            // Start Game
            gameState.start(at: timestamp)
            let impostorsCount = reader.packedUInt32()
            gameState.impostors = []
            for _ in 0..<impostorsCount {
                gameState.impostors.append(reader.uint8())
            }
            updateAutoMuteUsScene(scene: .tasks)
        case .setName:
            guard let playerID = sender.playerID, var player = gameState.players[playerID] else {
                break
            }
            player.name = reader.str()
            gameState.add(player: player)
            updateAutoMuteUsPlayer(player: player, action: .forceUpdated)
        case .setColor:
            guard let playerID = sender.playerID, var player = gameState.players[playerID] else {
                return
            }
            player.color = Player.Color(rawValue: reader.uint8())!
            gameState.add(player: player)
            updateAutoMuteUsPlayer(player: player, action: .changedColor)
        case .murderPlayer:
            let victim = gameState.components[reader.packedUInt32()]!.obj.playerID!
            let impostor = sender.playerID!
            gameState.add(event: .kill(.init(imposter: impostor, victim: victim, timestamp: timestamp)))
            gameState.modify(playerID: victim) { player in
                player.deadAt = timestamp
            }
            if let victim = gameState.players[victim] {
                updateAutoMuteUsPlayer(player: victim, action: .died)
            }
        case .sendChat:
            guard let player = sender.playerID else {
                break
            }
            gameState.add(event: .chat(.init(player: player, text: reader.str(), timestamp: timestamp)))
        case .startMeeting:
            let victim = reader.uint8()
            guard let player = sender.playerID else {
                break
            }
            gameState.add(event: .startMeeting(.init(player: player, deadBody: gameState.players[victim]?.id, timestamp: timestamp)))
            updateAutoMuteUsScene(scene: .discussion)
        case .sendChatNote:
            let player = reader.uint8()
            gameState.add(event: .voted(.init(player: player, timestamp: timestamp)))
        case .setStartCounter:
            _ = reader.packedUInt32() // nonce
            let count = reader.uint8()
            if count < 0x7F {
                print("Starting in \(count)")
            }
        case .enterVent:
            guard let player = sender.playerID else {
                break
            }
            gameState.add(event: .enterVent(.init(player: player, ventID: reader.packedUInt32(), timestamp: timestamp)))
        case .exitVent:
            guard let player = sender.playerID else {
                break
            }
            gameState.add(event: .exitVent(.init(player: player, ventID: reader.packedUInt32(), timestamp: timestamp)))
        case .snapTo:
            guard let player = sender.playerID else {
                break
            }
            let pos = Vector2(from: &reader)
            gameState.moves.append(.init(type: .vents, sequence: reader.uint16(), playerID: player, timestamp: timestamp, position: pos, velocity: .zero))
        case .votingComplete:
            var states = [GameEvent.VoteFinishEvent.PlayerVoteState]()
            let count = reader.packedUInt32()
            for i in 0..<count {
                let flags = reader.uint8()
                let didReport = (flags & 0x20) != 0
                let didVote = (flags & 0x40) != 0
                var votedFor = (flags & 0xF) == 0 ? nil : (flags & 0xF) - 1
                if !didVote {
                    votedFor = nil
                }
                if let player = gameState.players[Player.ID(i)], player.deadAt == nil, player.disconnectedAt == nil {
                    states.append(.init(id: player.id, didReport: didReport, didVote: didVote, votedFor: votedFor))
                }
            }
            let exiled = reader.uint8()
            let tie = reader.bool()
            let exiledPlayer = gameState.players[exiled]
            gameState.add(event: .voteFinish(.init(states: states, exiled: exiledPlayer?.id, isTie: tie, timestamp: timestamp)))
            updateAutoMuteUsScene(scene: .tasks)
            if let exiledPlayer = exiledPlayer {
                updateAutoMuteUsPlayer(player: exiledPlayer, action: .exiled)
            }
        case .updateGameData:
            while reader.hasMoreData {
                let player = Player(from: &reader, update: true)
                gameState.add(player: player)
                updateAutoMuteUsPlayer(player: player, action: .forceUpdated)
            }
        case .playAnimation, .completeTask: // ignore
            break
        case .syncSettings:
            _ = reader.packedUInt32() // length
            let ver = reader.uint8()
            switch ver {
            case 1:
                gameState.settings = .v1(.init(from: &reader))
            case 2:
                gameState.settings = .v2(.init(from: &reader), .init(from: &reader))
            case 3:
                gameState.settings = .v3(.init(from: &reader), .init(from: &reader), .init(from: &reader))
            case 4:
                gameState.settings = .v4(.init(from: &reader), .init(from: &reader), .init(from: &reader), .init(from: &reader))
            default:
                fatalError("Unknown GameSettings Version: \(ver)")
            }
            updateAutoMuteUsLobby(code: gameState.id.string, region: 0, map: gameState.settings!.v1.map)
        default:
            print("RPC", rpcType, senderID)
        }
    }
}
