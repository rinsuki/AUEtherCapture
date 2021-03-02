//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation

struct GameID: Encodable, RawRepresentable {
    private static let DIC = Array("QWXRTYLPESDFGHUJKZOCVBINMA")
    typealias RawValue = Int32
    var rawValue: Int32
    
    var string: String {
        if rawValue < 0 {
            var str = ""
            let firstTwo = rawValue & 0x3FF
            let lastFour = (rawValue >> 10) & 0xFFFFF
            str.append(GameID.DIC[Int(firstTwo % 26)])
            str.append(GameID.DIC[Int(firstTwo / 26)])
            str.append(GameID.DIC[Int(lastFour % 26)])
            str.append(GameID.DIC[Int(lastFour / 26 % 26)])
            str.append(GameID.DIC[Int(lastFour / (26*26) % 26)])
            str.append(GameID.DIC[Int(lastFour / (26*26*26) % 26)])
            return str
        }
        return "(NUM:\(rawValue))"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}
