//
//  File.swift
//  
//
//  Created by user on 2021/03/13.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct CaptureData {
    var state: GameState
    var json: Data
    var gzippedMsgpack: Data
    var name: String
    
    func output(to dir: URL) {
        do {
            let url = dir.appendingPathComponent(name + ".json")
            try json.write(to: url)
            try gzippedMsgpack.write(to: dir.appendingPathComponent(name + ".msgpack.gz"))
            print("Writed to \(url.path)")
        } catch {
            print("Error: \(error)")
        }
    }
    
    func upload(discordWebhookURL: URL?) throws {
        let uploadCredsURL = CONFIG_DIR_URL.appendingPathComponent("upload_creds.json")
        guard FileManager.default.fileExists(atPath: uploadCredsURL.path) else {
            // upload is not enabled
            print("NOTICE: Skip Upload (because upload_creds.json does not exists)")
            return
        }
        let configData = try Data(contentsOf: uploadCredsURL)
        let config = try JSONDecoder().decode(UploadCredsConfig.self, from: configData)
        var req = URLRequest(url: config.url)
        req.httpMethod = "POST"
        req.httpBody = gzippedMsgpack
        req.setValue("application/gzip", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        #if os(macOS)
        let OS_NAME = "macOS"
        #elseif os(Linux)
        let OS_NAME = "Linux"
        #elseif os(Windows)
        let OS_NAME = "Windows"
        #else
        let OS_NAME = "UnknownOS"
        #endif
        let USER_AGENT = "AUEtherCapture/0.0.0 (\(OS_NAME))"
        req.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: req) { (data, res, err) in
            guard let data = data, let res = res as? HTTPURLResponse else {
                print("Failed to upload replay (native error)", err)
                return
            }
            guard res.statusCode >= 200, res.statusCode < 300 else {
                print("Failed to upload replay (server error)", res.statusCode, String(data: data, encoding: .utf8))
                return
            }
            guard let str = String(data: data, encoding: .utf8), let url = URL(string: str) else {
                print("Failed to upload replay (not url res)", String(data: data, encoding: .utf8))
                return
            }
            print("Uploaded!", url.absoluteString)
            if let discordWebhookURL = discordWebhookURL {
                var req = URLRequest(url: discordWebhookURL)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
                struct DiscordWebhook: Codable {
                    struct Embed: Codable {
                        struct Field: Codable {
                            var name: String
                            var value: String
                            var inline: Bool = false
                        }
                        var title: String
                        var url: URL
                        var fields: [Field]
                    }
                    var content: String
                    var embeds: [Embed]
                }
                func playerToDiscordString(player: Player) -> String {
                    return "\(player.color.discordEmoji(dead: player.deadAt != nil)) \(player.name)"
                }
                let players: [Player.ID: String] = state.players.mapValues { playerToDiscordString(player: $0) }
                let formatter = DateFormatter()
                formatter.locale = .init(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let dateString = formatter.string(from: Date(timeIntervalSince1970: state.startedAt))
                do {
                    req.httpBody = try JSONEncoder().encode(DiscordWebhook(content: url.absoluteString, embeds: [.init(
                        title: "Replay (\(dateString) 〜)",
                        url: url,
                        fields: [
                            .init(name: "Duration", value: "\(Int(state.duration / 60)) min \(Int(state.duration) % 60) sec", inline: true),
                            .init(name: "Finish Reason", value: state.endReason!.string, inline: true),
                            .init(name: "Impostor (\(state.impostors.count))", value: state.impostors.map { players[$0] ?? "Unknown \($0)" }.joined(separator: "\n")),
                            .init(name: "Crewmate (\(players.count - state.impostors.count))", value: players.filter { !state.impostors.contains($0.key) }.map { $0.value }.joined(separator: "\n")),
                        ])
                    ]))
                    print(String(data: req.httpBody!, encoding: .utf8))
                } catch {
                    print("Failed to encode discord webhook", error)
                    return
                }
                URLSession.shared.dataTask(with: req, completionHandler: { data, res, error in
                    guard let data = data, let res = res as? HTTPURLResponse else {
                        print("Failed to send discord webhook (native)", error)
                        return
                    }
                    if res.statusCode >= 400 {
                        print("Failed to send discord webhook (http)", String(data: data, encoding: .utf8))
                    }
                }).resume()
            }
        }.resume()
    }
}

extension CaptureState {
    func data() throws -> CaptureData {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted]
        let json = try jsonEncoder.encode(gameState)
        let content = try JSONSerialization.jsonObject(with: json, options: [])
        var _data = Data()
        let msgpack = try _data.pack(content)
        let gzippedMsgpack = try msgpack.gzipped(level: .bestCompression)
        
        let date = Date(timeIntervalSince1970: gameState.startedAt)
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let ymd = formatter.string(from: date)
        formatter.dateFormat = "HHmmss"
        let hms = formatter.string(from: date)

        let fileName = "replay.v1.\(ymd).\(hms)"
        return .init(state: gameState, json: json, gzippedMsgpack: gzippedMsgpack, name: fileName)
    }
}
