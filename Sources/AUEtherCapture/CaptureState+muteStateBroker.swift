//
//  File.swift
//  
//
//  Created by user on 2021/03/06.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension CaptureState {
    enum GameScene: UInt8, Encodable {
        case lobby = 0
        case tasks
        case discussion
        case menu
        case ended
        case unknown
    }
    
    func updateAutoMuteUsScene(scene: GameScene) {
        guard let url = muteProxyURL else {
            return
        }
        var req = URLRequest(url: url.appendingPathComponent("state/\(scene.rawValue)"))
        req.httpMethod = "POST"
        URLSession.shared.dataTask(with: req).resume()
    }
    
    func updateAutoMuteUsLobby(code: String, region: UInt8, map: UInt8) {
        guard let url = muteProxyURL else {
            return
        }
        var req = URLRequest(url: url.appendingPathComponent("lobby/\(code.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)/\(region)/\(map)"))
        req.httpMethod = "POST"
        URLSession.shared.dataTask(with: req).resume()
    }
    
    enum PlayerUpdateAction: UInt8, Encodable {
        case joined = 0
        case left
        case died
        case changedColor
        case forceUpdated
        case disconnected
        case exiled
    }
    func updateAutoMuteUsPlayer(player: Player, action: PlayerUpdateAction) {
        guard let url = muteProxyURL else {
            return
        }
        var req = URLRequest(url: url.appendingPathComponent([
            "player",
            // we should add space for empty name (that is invalid, but we should handle invalid name)
            // last character is always trimmed by auethermuteproxy
            player.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)! + " ",
            action.rawValue.description,
            player.deadAt != nil ? "1" : "0",
            player.disconnectedAt != nil ? "1" : "0",
            player.color.rawValue.description,
        ].joined(separator: "/")))
        req.httpMethod = "POST"
        URLSession.shared.dataTask(with: req).resume()
    }
    
    func updateAutoMuteUsGameOver(reason: EndReason, players: [Player]) {
        guard let url = muteProxyURL else {
            return
        }
        var req = URLRequest(url: url.appendingPathComponent([
            "gameover",
            reason.rawValue.description,
            players.map { [
                $0.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!,
                gameState.impostors.contains($0.id) ? "1" : "0",
            ].joined(separator: "_") }.joined(separator: ","),
        ].joined(separator: "/")))
        req.httpMethod = "POST"
        URLSession.shared.dataTask(with: req).resume()
    }
}
