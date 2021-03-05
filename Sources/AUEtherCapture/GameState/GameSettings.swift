//
//  File.swift
//  
//
//  Created by user on 2021/03/03.
//

import Foundation
import BinaryReader

enum GameSettings: Encodable {
    case v1(V1)
    struct V1: Encodable {
        var maxMembers: UInt8
        var keywords: UInt32
        var map: UInt8
        var playerSpeed: Float
        var light: LightSettings
        struct LightSettings: Encodable {
            var crewmate: Float
            var impostor: Float
        }
        var killCooldown: Float
        var taskCounts: TaskCounts
        struct TaskCounts: Encodable {
            var common: UInt8
            var long: UInt8
            var short: UInt8
        }
        var emergencyMeetings: UInt32
        var impostors: UInt8
        var killDistance: UInt8
        var time: Time
        struct Time: Encodable {
            var discussion: UInt32
            var voting: UInt32
        }
        var isDefaults: Bool
        
        enum CodingKeys: String, CodingKey {
            case maxMembers = "max_members"
            case keywords
            case map
            case playerSpeed = "player_speed"
            case light
            case killCooldown = "kill_cooldown"
            case taskCounts = "task_counts"
            case emergencyMeetings = "emergency_meetings"
            case impostors
            case killDistance = "kill_distance"
            case time
            case isDefaults = "is_defaults"
        }
        
        init(from reader: inout BinaryReader) {
            maxMembers = reader.uint8()
            keywords = reader.uint32()
            map = reader.uint8()
            playerSpeed = reader.float32()
            light = .init(crewmate: reader.float32(), impostor: reader.float32())
            killCooldown = reader.float32()
            taskCounts = .init(common: reader.uint8(), long: reader.uint8(), short: reader.uint8())
            emergencyMeetings = reader.uint32()
            impostors = reader.uint8()
            killDistance = reader.uint8()
            time = .init(discussion: reader.uint32(), voting: reader.uint32())
            isDefaults = reader.bool()
        }
    }
    
    case v2(V1, V2)
    struct V2: Encodable {
        var emergencyCooldown: UInt8
        
        enum CodingKeys: String, CodingKey {
            case emergencyCooldown = "emergency_cooldown"
        }
        
        init(from reader: inout BinaryReader) {
            emergencyCooldown = reader.uint8()
        }
    }
    
    case v3(V1, V2, V3)
    struct V3: Encodable {
        var confirmEjects: Bool
        var visualTasks: Bool
        
        enum CodingKeys: String, CodingKey {
            case confirmEjects = "confirm_ejects"
            case visualTasks = "visual_tasks"
        }
        
        init(from reader: inout BinaryReader) {
            confirmEjects = reader.bool()
            visualTasks = reader.bool()
        }
    }
    
    case v4(V1, V2, V3, V4)
    struct V4: Encodable {
        var anonymousVotes: Bool
        var taskBarUpdates: UInt8
        
        enum CodingKeys: String, CodingKey {
            case anonymousVotes = "anonymous_votes"
            case taskBarUpdates = "task_bar_updates"
        }
        
        init(from reader: inout BinaryReader) {
            anonymousVotes = reader.bool()
            taskBarUpdates = reader.uint8()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .v4(let v1, let v2, let v3, let v4):
            try v4.encode(to: encoder)
            fallthrough
        case .v3(let v1, let v2, let v3):
            try v3.encode(to: encoder)
            fallthrough
        case .v2(let v1, let v2):
            try v2.encode(to: encoder)
            fallthrough
        case .v1(let v1):
            try v1.encode(to: encoder)
        }
    }
}

extension GameSettings {
    var v1: V1 {
        switch self {
        case .v1(let v1):
            fallthrough
        case .v2(let v1, _):
            fallthrough
        case .v3(let v1, _, _):
            fallthrough
        case .v4(let v1, _, _, _):
            return v1
        }
    }
}
