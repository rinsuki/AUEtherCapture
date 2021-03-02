//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation

enum GameEvent {
    case kill(KillEvent)
    struct KillEvent: Encodable {
        var impostor: Player.ID
        var victim: Player.ID
        var timestamp: Double
    }
    
    case enterVent(VentsEvent)
    case exitVent(VentsEvent)
    struct VentsEvent: Encodable {
        var player: Player.ID
        var ventID: UInt32
        var timestamp: Double

        enum CodingKeys: String, CodingKey {
            case timestamp
            case player
            case ventID = "vent_id"
        }
    }
    
    case chat(ChatEvent)
    struct ChatEvent: Encodable {
        var player: Player.ID
        var text: String
        var timestamp: Double
    }
    
    case startMeeting(StartMeetingEvent)
    struct StartMeetingEvent: Encodable {
        var player: Player.ID
        var deadBody: Player.ID?
        var timestamp: Double
        
        enum CodingKeys: String, CodingKey {
            case player
            case deadBody = "dead_body"
            case timestamp
        }
    }
    
    case voted(VotedEvent)
    struct VotedEvent: Encodable {
        var player: Player.ID
        var timestamp: Double
    }
    
    case voteFinish(VoteFinishEvent)
    struct VoteFinishEvent: Encodable {
        struct PlayerVoteState: Encodable {
            var id: Player.ID
            var didReport: Bool
            var didVote: Bool
            var votedFor: Player.ID?
            
            enum CodingKeys: String, CodingKey {
                case id
                case didReport = "did_report"
                case didVote = "did_vote"
                case votedFor = "voted_for"
            }
        }
        var states: [PlayerVoteState]
        var exiled: Player.ID?
        var isTie: Bool
        var timestamp: Double
        
        enum CodingKeys: String, CodingKey {
            case states
            case exiled
            case isTie = "is_tie"
            case timestamp
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(states.sorted(by: { $0.id < $1.id }), forKey: .states)
            try container.encode(exiled, forKey: .exiled)
            try container.encode(isTie, forKey: .isTie)
            try container.encode(timestamp, forKey: .timestamp)
        }
    }
    
    case disconnect(DisconnectEvent)
    struct DisconnectEvent: Encodable {
        var player: Player.ID
        var timestamp: Double
    }
}

extension GameEvent: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let type: String
        let content: Encodable
        switch self {
        case .kill(let event):
            type = "kill"
            content = event
        case .enterVent(let event):
            type = "enter_vent"
            content = event
        case .exitVent(let event):
            type = "exit_vent"
            content = event
        case .chat(let event):
            type = "chat"
            content = event
        case .startMeeting(let event):
            type = "start_meeting"
            content = event
        case .voted(let event):
            type = "voted"
            content = event
        case .voteFinish(let event):
            type = "vote_finish"
            content = event
        case .disconnect(let event):
            type = "disconnect"
            content = event
        }
        
        try container.encode(type, forKey: .type)
        try content.encode(to: encoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
}
