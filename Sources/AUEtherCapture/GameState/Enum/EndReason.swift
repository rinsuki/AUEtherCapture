//
//  File.swift
//  
//
//  Created by user on 2021/03/03.
//

import Foundation

struct EndReason: RawRepresentable, Equatable, Encodable {
    typealias RawValue = UInt8
    var rawValue: RawValue
    
    static let CREWMATES_BY_VOTE = EndReason(rawValue: 0)
    static let CREWMATES_BY_TASK = EndReason(rawValue: 1)
    static let IMPOSTORS_BY_VOTE = EndReason(rawValue: 2)
    static let IMPOSTORS_BY_KILL = EndReason(rawValue: 3)
    static let IMPOSTORS_BY_SABOTAGE = EndReason(rawValue: 5)
    static let IMPOSTOR_DISCONNECT = EndReason(rawValue: 6)
    static let CREWMATE_DISCONNECT = EndReason(rawValue: 7)
    
    var string: String {
        switch self {
        case .CREWMATES_BY_VOTE:
            return "CREWMATES_BY_VOTE"
        case .CREWMATES_BY_TASK:
            return "CREWMATES_BY_TASK"
        case .IMPOSTORS_BY_VOTE:
            return "IMPOSTORS_BY_VOTE"
        case .IMPOSTORS_BY_KILL:
            return "IMPOSTORS_BY_KILL"
        case .IMPOSTORS_BY_SABOTAGE:
            return "IMPOSTORS_BY_SABOTAGE"
        case .IMPOSTOR_DISCONNECT:
            return "IMPOSTOR_DISCONNECT"
        case .CREWMATE_DISCONNECT:
            return "CREWMATE_DISCONNECT"
        default:
            return rawValue.description
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}
