//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation

struct GameState: Encodable {
    private let replayVersion = 1

    var id: GameID = .init(rawValue: 0)
    var startedAt: Double = 0
    var duration: Double = 0
    var events = [GameEvent]()
    var moves = [PlayerMove]()
    var impostors = [Player.ID]()
    private(set) var players = [Player.ID: Player]()
    
    private(set) var objects = [InnerNetObject]()
    private(set) var components = [UInt32: InnerNetComponent]()
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(1, forKey: .replayVersion)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encode(duration, forKey: .duration)
        try container.encode(Array(players.values).sorted(by: { $1.id > $0.id }), forKey: .players)
        try container.encode(impostors, forKey: .impostors)
        try container.encode(events, forKey: .events)
        try container.encode(moves, forKey: .moves)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case replayVersion = "replay_version"
        case startedAt = "started_at"
        case duration
        case events
        case players
        case moves
        case impostors
    }
    
    mutating func start(at startedAt: Double) {
        self.startedAt = startedAt
        moves = []
        events = []
    }
    
    mutating func finish(at timestamp: Double) {
        duration = timestamp
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        guard let data = try? encoder.encode(self) else {
            return
        }
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.aureplay.json")
        try? data.write(to: url)
        print("Writed to \(url.path)")
    }
    
    mutating func add(object: InnerNetObject) {
        objects.append(object)
        for component in object.components {
            components[component.netID] = component
        }
    }
    
    mutating func add(player: Player) {
        players[player.id] = player
    }
    
    mutating func add(event: GameEvent) {
        events.append(event)
    }
    
    mutating func remove(object: InnerNetObject) {
        objects.removeAll(where: { $0.components[0].netID == object.components[0].netID })
        for component in object.components {
            components[component.netID] = nil
        }
        if let playerID = object.playerID {
            players[playerID] = nil
        }
    }
    
    mutating func modify(playerID: Player.ID, callback: (inout Player) -> Void) {
        if var player = players[playerID] {
            callback(&player)
            players[player.id] = player
        }
    }
}
